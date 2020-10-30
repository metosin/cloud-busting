#!/usr/bin/env bash

if [ $# -ne 1 ]
then
    echo "Usage: AWS_PROFILE=YOUR_PROFILE ./create-ssh-rds-tunnel.sh <local-port>"
    echo "Example: AWS_PROFILE=YOUR_PROFILE ./create-ssh-rds-tunnel.sh 6666"
    exit 1
fi

check_if_empty () {
  MY_VARIABLE=$1
  MY_VALUE=$2
  if [ -z "$MY_VALUE" ]
  then
    echo "Variable $MY_VARIABLE is empty"
    exit 1
  fi
}

LOCAL_PORT=$1
check_if_empty "LOCAL_PORT" $LOCAL_PORT

TF_WORKSPACE=$(terraform workspace show)
if [ "$TF_WORKSPACE" == "default" ]; then
    WP="-"
else
    WP="-${TF_WORKSPACE}-"
fi
PREFIX=${TF_VAR_prefix}${WP}
check_if_empty "PREFIX" $PREFIX

BASTION_NAME="${PREFIX}bastion"
check_if_empty "BASTION_NAME" $BASTION_NAME
echo "BASTION name: $BASTION_NAME"

RDS_NAME="${PREFIX}database"
check_if_empty "RDS_NAME" $RDS_NAME
echo "RDS name: $RDS_NAME"

CMD="aws ec2 describe-instances --filters \"Name=tag:Name,Values=${BASTION_NAME}\" --query \"Reservations[*].Instances[*].PublicIpAddress\" --output=text"
BASTION_IP=$(eval $CMD)
check_if_empty "BASTION_IP" $BASTION_IP
echo "BASTION IP: $BASTION_IP"

CMD="aws rds describe-db-instances --db-instance-identifier ${RDS_NAME} --query \"DBInstances[*].DBName\" --output=text"
DB_NAME=$(eval $CMD)
check_if_empty "DB_NAME" $DB_NAME
echo "DB_NAME: $DB_NAME"

CMD="aws rds describe-db-instances --db-instance-identifier ${RDS_NAME} --query \"DBInstances[*].MasterUsername\" --output=text"
DB_USER=$(eval $CMD)
check_if_empty "DB_USER" $DB_USER
echo "DB_USER: $DB_USER"

CMD="aws rds describe-db-instances --db-instance-identifier ${RDS_NAME} --query \"DBInstances[*].Endpoint.Address\" --output=text"
RDS_ENDPOINT=$(eval $CMD)
check_if_empty "RDS_ENDPOINT" $RDS_ENDPOINT
echo "RDS_ENDPOINT: $RDS_ENDPOINT"

CMD="aws rds describe-db-instances --db-instance-identifier ${RDS_NAME} --query \"DBInstances[*].Endpoint.Port\" --output=text"
RDS_PORT=$(eval $CMD)
check_if_empty "RDS_PORT" $RDS_PORT
echo "RDS_PORT: $RDS_PORT"

SSH_KEY=".ssh/ec2_id_rsa"

COMMAND="ssh -i $SSH_KEY -L ${LOCAL_PORT}:${RDS_ENDPOINT}:${RDS_PORT} ec2-user@${BASTION_IP}"
echo "Starting ssh tunnel with command: ${COMMAND}"
echo ""
echo "NOTE *******************************************************************************"
echo "After the ssh tunnel is ready, you can try to connect to the RDS using psql client"
echo "Example command: psql -h localhost -p $LOCAL_PORT -U $DB_USER $DB_NAME"
echo "NOTE *******************************************************************************"
echo ""
eval $COMMAND

