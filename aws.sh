aws ec2 run-instances \
    --image-id ami-0ac80df6eff0e70b5 \
    --instance-type t2.micro \
    --subnet-id subnet-05d6195a \
    --security-group-ids sg-0219d74c4c801bcc9 \
    --associate-public-ip-address \
    --key-name EC2 \
    --region us-east-1
    ip=`aws ec2 describe-instances --region us-east-1 --query "Reservations[*].Instances[*].PublicIpAddress" --output=text | tail -1`
    ssh ubuntu@$ip
    
    
