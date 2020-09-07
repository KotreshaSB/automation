ip=`aws ec2 describe-instances  --region us-east-1 --query 'sort_by(Reservations[].Instances[], &LaunchTime)[].[InstanceId,PublicIpAddress,LaunchTime]' --output text | tail -1 | awk '{ print  $2 }'`

ipr=`aws ec2 describe-instances  --region us-east-1 --query 'sort_by(Reservations[].Instances[], &LaunchTime)[].[InstanceId,PrivateIpAddress,LaunchTime]' --output text | tail -1 | awk '{ print  $2 }'`
sleep 60
ssh -i "/home/ubuntu/EC2.pem" ubuntu@$ip '
sudo apt-get update
sudo apt-get install apache2 -y
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo systemctl restart apache2
sudo apt-get install mysql-server mysql-client -y
sudo systemctl restart mysql
sudo chmod 644 /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i "31i server-id              = 2"  /etc/mysql/mysql.conf.d/mysqld.cnf 
sudo sed -i '44d' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i "44i bind-address  =  0.0.0.0 "  /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i "107i log_bin = /var/log/mysql/mysql-bin.log "  /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i "108i log_bin_index =/var/log/mysql/mysql-bin.log.index "  /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i "109i relay_log = /var/log/mysql/mysql-relay-bin "  /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i "110i relay_log_index = /var/log/mysql/mysql-relay-bin.index "  /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql
sudo echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDjkTIqKLe8RzDuDL0aDu6rmH6RmjnMT8TU8/tp18yqafXRFO6NJdymUJyMScnK2cig2FLxv4YVVkwaIVW6J0dJT4lJOALe4i7qNeAxRz+fKHlXtAwtw8DmDD9p3OlN3Fyw2FNP0T5zZ799GptpnqwN4ZvhF7aiReLAjsBpPBB3zzjxu5i3glgeD2JKmU+AS2GKO/HPdQzqiyOl2GwpvX3oXfnmYVnVWXykVnfz+O0oxGVGa/vgsM5Z+q6nB6QaYZSTfQpl/Bx9XlinGqgtS1aLjaUuUY3QgXUNh+FN0bUYL7+UDjZPD08EPtFYM7VSj1aaxH1zZBc5n3jL3QC+7d3D ubuntu@MASTER
" >> /home/ubuntu/.ssh/authorized_keys
'

ip=`aws ec2 describe-instances  --region us-east-1 --query 'sort_by(Reservations[].Instances[], &LaunchTime)[].[InstanceId,PublicIpAddress,LaunchTime]' --output text | tail -1 | awk '{ print  $2 }'`

ipr=`aws ec2 describe-instances  --region us-east-1 --query 'sort_by(Reservations[].Instances[], &LaunchTime)[].[InstanceId,PrivateIpAddress,LaunchTime]' --output text | tail -1 | awk '{ print  $2 }'`
ssh -i "/home/ubuntu/EC2.pem" ubuntu@172.31.56.152 '
sudo mysql -u root -e "CREATE USER '"'slave08'"'@'"'$ipr'"' IDENTIFIED BY '"'Shivasali@16'"';"
sudo mysql -u root -e "GRANT REPLICATION SLAVE ON *.* TO '"'slave08'"'@'"'$ipr'"';"
sudo systemctl restart mysql
sudo mysqldump -u root --all-databases --master-data > masterdump07.sql
scp -o StrictHostKeyChecking=no masterdump07.sql '$ip':
'
ip=`aws ec2 describe-instances  --region us-east-1 --query 'sort_by(Reservations[].Instances[], &LaunchTime)[].[InstanceId,PublicIpAddress,LaunchTime]' --output text | tail -1 | awk '{ print  $2 }'`

ipr=`aws ec2 describe-instances  --region us-east-1 --query 'sort_by(Reservations[].Instances[], &LaunchTime)[].[InstanceId,PrivateIpAddress,LaunchTime]' --output text | tail -1 | awk '{ print  $2 }'`

ssh -i "/home/ubuntu/EC2.pem" ubuntu@$ip ' 
sudo systemctl restart mysql
sudo mysql -u root -e "STOP SLAVE;"
sudo mysql -u root -e "CHANGE MASTER TO MASTER_HOST ='"'172.31.56.152'"', MASTER_USER ='"'slave08'"', MASTER_PASSWORD ='"'Shivasali@16'"';"
sudo mysql -u root < masterdump07.sql
sudo mysql -u root -e "START SLAVE;"
'
