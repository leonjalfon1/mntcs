# mntcs

![mntcs](https://github.com/leonjalfon1/mntcs/workflows/mntcs/badge.svg)


## Description

**mntcs** (Mount Centralized System) is a tool that allows you to mange filesystem mounts in a centralized and easy way.
It was created to to answer the following use case: Manage filesystem mounts in several ubuntu servers using a single configuration file allowing users without previous knowledge on Linux mounts to use the system.

<br/>

## How it Works

**mntcs** uses a very simple configuration file to determine which mounts have to be configured. 

<kbd>
  <img src="/docs/basic-architecture.png" width="600">
</kbd>

<br/> The "mntcs.conf" file contain a set of source and target paths for each mount like shown below:

```
10.10.10.10:/source/path /target/path/one
servername:/source/path /target/path/two
dns:/source/path /target/path/three
```

Then the **mntcs** binary read the file and configure the specified mounts (it should be configured to run as a service in order to run on server boots)

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

**mntcs** can be used on a single server although in that case it would be better to use tools like fstab. However, its true use is to manage the mounts for several servers centrally as shown below.

<kbd>
  <img src="/docs/centralized-architecture.png" width="600">
</kbd>

<br/> To achieve this, the "mntcs.conf" file should be mounted into the server and should be managed in a central location.
Then **mntcs** will be able to read the configuration file and set the required mounts.
In addition, **mntcs** should be configured as a service to run it at boot (and not only manually)

<br/>

## Considerations & Limitations

- **mntcs** was designed to run only as "root" only so it doesn't support mounts with specific users (at least not for now)
- The purpose of **mntcs** is not to replace fstab, it was developed to solve a specific use case (without affecting the regular fstab usage)
- At the moment **mntcs** only uses the "mount" command defaults (does not support specifying flags as -r, -w, etc)
- **mntcs** was developed and tested for ubuntu
- Note that even though **mntcs** is currently being used in production it was created for a poc

<br/>

## Build & Package

### Prerequisites

- Install the following packages (on ubuntu):
  - shc (version => 4.0.1)
  - dh-make
  - devscripts
  - libc6-dev 

```
sudo add-apt-repository ppa:neurobin/ppa
sudo apt-get update
sudo apt-get install libc6-dev shc dh-make devscripts
```

### Build Debian Package

- Run the build script from the build directory:

```
cd ./build
./build.sh
```

<br/>

## Installation

### Single Mode

Use mntcs to configure mounts with a configuration file stored in your server (not recommended, instead use fstab that is better)

- Download the **mntcs** package (or build it from sources)
```
wget https://github.com/leonjalfon1/mntcs/releases/download/v1.0/mntcs.deb
```

- Install the package:
```
sudo apt install ./mntcs.deb
```

- Configure the required mounts:
```
sudo vi /etc/mntcs/mntcs.conf
```

- Test your mounts manually:
```
sudo mntcs
```

- Check the logs:
```
cat /var/log/mntcs.log
```

- Enable the service on boot:
```
sudo systemctl enable mntcs
```

### Shared Mode

Use **mntcs** to configure mounts with a configuration file stored in a central place and mounted to your server

- Download the **mntcs** package (or build it from sources)
```
wget https://github.com/leonjalfon1/mntcs/releases/download/v1.0/mntcs.deb 
```

- Install the package:
```
sudo apt install ./mntcs.deb
```

- Mount the configuration file using [fstab](https://linuxconfig.org/how-fstab-works-introduction-to-the-etc-fstab-file-on-linux)

```
sudo vi /etc/fstab
```   

```
# For example, for a nfs mount add a line like this:

10.128.0.59:/sharedstorage/mntcs/conf /etc/mntcs  nfs        defaults    0       0
```

```
sudo mount /etc/mntcs
```

- Use the following command to get the service name of the generated mount:
```
systemctl list-units --type=mount | grep mntcs
```

- Edit the service file to add the configuration mount as a dependency of the service:
```
vi /lib/systemd/system/mntcs.service
```

```
# Add the following line in the [Unit] section (with your service mount name)

After=etc-mntcs.mount
```

- Test your mounts manually:
```
sudo mntcs
```

- Enable the service on boot:
```
sudo systemctl enable mntcs
```

<br/>

## Uninstall

- Delete **mntcs** using the following command:

```
sudo apt remove mntcs
```
