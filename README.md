# mntcs

![mntcs](https://github.com/leonjalfon1/mntcs/workflows/mntcs/badge.svg)


## Description

**mntcs** (Mount Centralized System) is a tool that allows you to mange filesystem mounts in a centralized and easy way.
It was created to to answer the following use case: Manage filesystem mounts (using cifs) in several ubuntu servers using a single configuration file stored in a shared folder location allowing users without previous knowledge on Linux mounts to use the system.

<br/>

## How it Works

**mntcs** uses a very simple configuration file to determine which mounts have to be configured. 

<kbd>
  <img src="/docs/basic-architecture.png" width="600">
</kbd>

<br/> The "mntcs.conf" file contain a set of source and target paths for each mount like shown below:

```
10.10.10.10:/source/path /target/path/one linuxuser1,linuxuser2,linuxuser3 /path/to/credentials/file
servername:/source/path /target/path/two linuxuser1,linuxuser2 /path/to/credentials/file
dns:/source/path /target/path/three linuxuser2,linuxuser3 /path/to/credentials/file
```

Then the **mntcs** binary read the file and configure the specified mounts (it should be configured to run as a service in order to run on server boots)

Note that a credential file is used for the mount operation to ensure that only root is able to access and configure the mount permissions

<br/>

## Components

<kbd>
  <img src="/docs/components.png" width="600">
</kbd>

<br/>The **mntcs** utility is composed of the following:

 - /etc/mntcs/mntcs.conf: configuration file
 - /bin/mntcs: binary
 - /var/log/mntcs.log: logs
 - /lib/systemd/system/mntcs.service: service file

<br/>

## Centralized Configuration

**mntcs** allows you to manage the mounts centrally as shown in the image below:

can be used on a single server although in that case it would be better to use tools like fstab. However, its true use is to manage the mounts for several servers centrally as shown below.

<kbd>
  <img src="/docs/centralized-architecture.png" width="600">
</kbd>

<br/> To achieve this, the "mntcs.conf" file should be mounted into the server and should be managed in a central location.
Then **mntcs** will be able to read the configuration file and set the required mounts (including the permissions for each user).
In addition, **mntcs** should be configured as a service to run it at boot (and not only manually)

Note that **mntcs** can be used on a single server as well but in that case probably would be better to use tools like fstab

<br/>

## Considerations & Limitations

- The purpose of **mntcs** is not to replace fstab, it was developed to solve a specific use case (without affecting the regular fstab usage)
- At the moment **mntcs** only uses the "mount" command defaults (does not support specifying flags)
- Currently **mntcs** doesn't do any validation to the configuration file
- **mntcs** was developed and tested for ubuntu only
- Note that **mntcs** is currently being used in some production environments
- **mntcs** was designed to perform the mounts using cifs only

<br/>

## Installation

### Prerequisites

1. **mntcs** require the "cifs-utils" package, to install it you can use the command below:

```
sudo apt update
sudo apt install -y cifs-utils
```

### Create the Credentials File

1. Create the credentials file which will be used to perform the mounts (you can create multiples files if required)

```
sudo touch /etc/mntcs.cred
```

2. Configure the credentials file with the following details

```
vi /etc/mntcs.cred
```

```
username=MyUser
password=MyPassword
domain=mydomain.com
```

3. Set the file readable only for root

```
sudo chown root: /etc/mntcs.cred
sudo chmod 600 /etc/mntcs.cred
```

### Create the Configuration File

1. Create the configuration file in a shared storage location, for example:

```
# config file location

\\netapp\mydirectory\mntcs.conf
```

```
# example config file

//100.1.1.0/myshareddirectory/myfoldertomount1 /mnt/mount1 linuxuser1,linuxuser2 /etc/mntcs.cred
//100.1.1.0/myshareddirectory/myfoldertomount2 /mnt/mount2 linuxuser2 /etc/mntcs.cred
//100.1.1.0/myshareddirectory/myfoldertomount3 /mnt/mount3 linuxuser1,linuxuser3 /etc/mntcs.cred
```

2. Create the directory to mount the configuration file

```
sudo mkdir /etc/mntcs
```

3. Mount the configuration file using "fstab" by adding the following line to the "/etc/fstab" file:

```
sudo vi /etc/fstab
```

```
# NOTE: CHANGE THE SOURCE PATH BELOW WITH THE PATH WHERE YOUR CONFIG FILE IS STORED
//100.1.1.0/myshareddirectory/myfoldertomount1 /etc/mntcs cifs credentials=/etc/mntcs.cred 0 0
```

4. Trigger the mount and ensure that it success

```
sudo mount /etc/mntcs
```

```
ls /etc/mntcs
cat /etc/mntcs/mntcs.conf
```

### Install the Binary

1. Download the mntcs binary

```
wget https://github.com/leonjalfon1/mntcs/releases/download/v1.0/mntcs
```

2. Grant execution permissions for the binary

```
sudo chmod +x ./mntcs
```

3. Move the mntcs binary to the "/bin" directory

```
sudo mv ./mntcs.sh /bin/mntcs
```

4. Ensure that the mntcs binary is located in the bin directory

```
ls /bin | grep mntcs
```

5. Ensure that the binary is accessible by running

```
mntcs --help
```

### Configure the Service

1. Use the command below to retrieve the service name of the generated mount used to mount the mntcs configuration (you should get: etc-mntcs.mount)

```
sudo systemctl list-units --type=mount | grep mntcs
```

2. Create the service file with the following configuration

```
sudo vi /lib/systemd/system/mntcs.service
```

```
[Unit]
Description=Mount Centralized System (mntcs)
## Add a mount dependency as below if you use fstab to mount the configuration into the server
## Use the command "systemctl list-units --type=mount" to get the generated mount service name
After=etc-mntcs.mount

[Service]
ExecStart=/bin/mntcs

[Install]
WantedBy=multi-user.target
```

3. Test your mounts manually

```
sudo mntcs
```

4. Enable the service to run automatically on boot

```
sudo systemctl enable mntcs
```
