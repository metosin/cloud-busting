# network


## WIP

    terraform init \
    -backend-config="encrypt=true" \
    -backend-config="bucket=cb-kimmo-terraform" \
    -backend-config="dynamodb_table=cb-kimmo-terraform" \
    -backend-config="kms_key_id=arn:aws:kms:eu-west-1:678497885140:key/fd1a09ea-dfa7-456d-98ce-21f83a36f20f"
