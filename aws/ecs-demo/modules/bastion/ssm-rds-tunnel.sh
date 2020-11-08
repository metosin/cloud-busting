#!/usr/bin/env bash

set -eu -o pipefail

usage() {
    echo "Creates a tunnel to the RDS instance through a EC2 (bastion) instance in that can connect to the RDS instance."
    echo "The jump host is accessed via the AWS SSM service, so it does not need to be publicly reachable, although in this demo, we also create a traditional, publicly reachable bastion instance."
    echo ""
    echo "Binds local port 7432 by default"
    echo ""
    echo "Install the session manager plugin before use, see instructions at: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html"
    echo ""
    echo "Usage:"
    echo "./rds_proxy [-h] [-p PORT]"
    echo ""
    echo "Options:"
    echo "-h                    Show help"
    echo "-p PORT               Local port for the tunnel"
}

if ! command -v session-manager-plugin >/dev/null 2>&1
then
    echo ""
    echo "Please install the session manager plugin"
    echo "See instructions at: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html"
    echo ""
    exit 1
fi

# Setup folder for temporary SSH keys and the control socket
KEY_FOLDER=$HOME/.ssh/cloud-busting
mkdir -p $KEY_FOLDER
SSH_KEY_FILE_BASE="$KEY_FOLDER/proxy-key"
# Socket for controlling the SSH connection
CONTROL_SOCKET="$KEY_FOLDER/proxy.sock"

LOCAL_PORT=7432
while getopts ":hi:" opt; do
    case $opt in
        h)
            usage
            exit 1
            ;;
        p)
            LOCAL_PORT=$OPTARG
            ;;
    esac
done

# Disable pager on aws cli v2
export AWS_PAGER=""

# Fetch database endpoint
pushd ../rds > /dev/null
RDS_ADDRESS=$(terraform output rds_address)
popd > /dev/null

# Remove old key files if present
rm -f $SSH_KEY_FILE_BASE
rm -f $SSH_KEY_FILE_BASE.pub

# Generate temporary SSH key
ssh-keygen -t rsa \
           -f $SSH_KEY_FILE_BASE \
           -N '' \
           -q

# Get bastion EC2 instance ID and AZ, for sending public SSH key
INSTANCE_ID=$(terraform output ec2_instance_id)
AVAILABILITY_ZONE=$(terraform output ec2_instance_az)

# Send the public key to AWS, for use via instance metadata
aws ec2-instance-connect send-ssh-public-key \
    --instance-id $INSTANCE_ID \
    --availability-zone $AVAILABILITY_ZONE \
    --instance-os-user ssm-user \
    --ssh-public-key "file://$SSH_KEY_FILE_BASE.pub" > /dev/null

# Use the SSH keypair and SSM proxying for making a connection the SSHD on the instance, and create a tunnel to RDS
ssh -i $SSH_KEY_FILE_BASE \
    -4 \
    -f \
    -N \
    -M \
    -S $CONTROL_SOCKET \
    -L $LOCAL_PORT:$RDS_ADDRESS:5432 \
    -o "UserKnownHostsFile=/dev/null" \
    -o "StrictHostKeyChecking=no" \
    -o "IdentitiesOnly=yes" \
    -o ProxyCommand="aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'" \
    ssm-user@$INSTANCE_ID

echo "RDS proxy started on localhost at port $LOCAL_PORT"

# Wait for termination
read -rsn1 -p "Press any key to close session."; echo
ssh -O exit -S $CONTROL_SOCKET *
# Remove the key files
rm $SSH_KEY_FILE_BASE
rm $SSH_KEY_FILE_BASE.pub
