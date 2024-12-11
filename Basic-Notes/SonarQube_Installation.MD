# SonarQube Installation

SonarQube provides the capability to not only show health of an application but also to highlight issues newly introduced. With a Quality Gate in place, you can fix the leak and therefore improve code quality systematically.


### Prerequisites
1. EC2 instance with Java installed
2. Use t2.large with atleast 20gb memory to run sonarqube.
1. MySQL Database Server or MyQL RDS instance.

### Installation

Install java 1.8 version
```sh
yum install java-1.8*
```

Add mysql rpm Repository

 ```sh
yum update
sudo wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
sudo yum localinstall mysql57-community-release-el7-11.noarch.rpm
rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
 
sudo yum install mysql-community-server
sudo systemctl start mysqld.service


 ```

Start MySQL and Enable Start at Boot Time
 
 ```sh
 systemctl start mysqld
 systemctl enable mysqld
 ```
 
 Check if mysql is running or not
 
  ```sh
netstat -na | grep 3306
 ```
 
 Configure the MySQL Root Password 
 You will see default MySQL root password
 
 ```sh
grep 'temporary' /var/log/mysqld.log
 ```
 Login to mysql using the default password
 ```sh
mysql -u root -p
 ```
 
 Now replace the default password with a new and strong password
 
 ```sh
ALTER USER 'root'@'localhost' IDENTIFIED BY 'Admin@123';
flush privileges;
 ```
 Test Using new password
 
 ```sh
mysql -u root -p
 ```
  
Download stable SonarQube version from below website. 
- Website: https://www.sonarqube.org/downloads/
- Note: This Article written for SonarQube6.0  

Download & unzip SonarQube 6.0
```sh
# cd /opt
# wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-6.6.zip
# unzip sonarqube-6.6.zip
# mv /opt/sonarqube-6.6 /opt/sonar
```


Login to mysql
```sh 
mysql -u root -p
```
Create a new sonar database
```sh
CREATE DATABASE sonar CHARACTER SET utf8 COLLATE utf8_general_ci;
```

Create a local and a remote user
```sh
CREATE USER sonar@localhost IDENTIFIED BY 'Sonar@123';
CREATE USER sonar@'%' IDENTIFIED BY 'Sonar@123';
```

Grant database access permissions to users 
```sh
GRANT ALL ON sonar.* TO sonar@localhost;
GRANT ALL ON sonar.* TO sonar@'%';
```

check users and databases 
```sh
show databases;
SELECT User FROM mysql.user;
FLUSH PRIVILEGES;
QUIT
```
So for you have configured required database information on mysql. Let’s Jump back to your EC2 instance and enable SonarQube properties file to connect his Database.

### ON EC2 Instance
Edit sonar properties file to uncomment and provide required information for below properties. 

- File Name: /opt/sonar/conf/sonar.properties
  - sonar.jdbc.username=`sonar`
  - sonar.jdbc.password=`Sonar@123`
  - sonar.jdbc.url=jdbc:mysql://`localhost:3306`/sonar?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true&useConfigs=maxPerformance&useSSL=false
  - sonar.web.host=`0.0.0.0`
  - sonar.web.context=`/sonar`
  
# Sonar version 7 and higher cannot be run using root user,please switch to any other user and change the permissions to sonar directory and start sonar.

Create new user

```sh
# useradd sabear
# passwd sabear
```
Add user sabear to sudoers file
```sh
vi /etc/sudoers

## Same thing without a password
# %wheel        ALL=(ALL)       NOPASSWD: ALL
sabear          ALL=(ALL)       NOPASSWD: ALL
```
Restart the sshd service
```sh
# systemctl restart sshd
```
Switch to newly created user
```sh
# sudo su sabear
```
Start SonarQube service 
```sh
# cd /opt/sonar/bin/linux-x86-64/
# ./sonar.sh start
```

##### Run SonarQube as a default service 

Implement SonarQube server as a service
```sh
Copy sonar.sh to etc/init.d/sonar and modify it according to your platform.
# sudo cp /opt/sonar/bin/linux-x86-64/sonar.sh /etc/init.d/sonar
# sudo vi /etc/init.d/sonar
```

Add below values to your /etc/init.d/sonar file
```sh
Insert/modify below values
SONAR_HOME=/opt/sonar
PLATFORM=linux-x86-64

WRAPPER_CMD="${SONAR_HOME}/bin/${PLATFORM}/wrapper"
WRAPPER_CONF="${SONAR_HOME}/conf/wrapper.conf"
PIDDIR="/var/run"
```

Start SonarQube server
```sh
# service sonar start
```
SonarQube application uses port 9000. access SonarQube from browser
```sh
  http://<EC2_PUBLIC_IP>:9000/sonar
```
Default credentials for sonarqube.
Username : admin
Password: admin
###  NOTES
1) Check whether you enabled port 9000 in EC2 instance security group

### Important Points:

1) mysql port number : 3306
2) sonarqube port: 9000
3) sonarqube logs : /opt/sonar/logs
4) We can find four different logs
 a)access.log
 b)es.log aka elastic search
 c)sonar.log
 d)web.log
   
 
### Videos for reference: 
### sonarqube installation: 
https://www.youtube.com/watch?v=zRQrcAi9UdU
#### mysql rds instance aws: 
https://www.youtube.com/watch?v=vLaW6b441x0
