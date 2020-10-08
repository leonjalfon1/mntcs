# mntcs
A Mount Centralized System


## Description

The **mntcs** tool is a utility that allow you to mange filesystem mounts in a centralized and easy way.
It was created to to answer the following use case: Manage filesystem mounts in several ubuntu servers using a single configuration file allowing users without previous knowledge on Linux mounts to use the system.

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

## Components

<kbd>
  <img src="/docs/components.png" width="600">
</kbd>

<br/>The **mntcs** utility is composed of the following:

 - /etc/mntcs/mntcs.conf: configuration file
 - /bin/mntcs: binary
 - /var/log/mntcs.log: logs
 - /lib/systemd/system/mntcs.service: service file

## Centralized Configuration

**mntcs** can be used on a single server although in that case it would be better to use tools like fstab. However, its true use is to manage the mounts for several servers centrally as shown below.

<kbd>
  <img src="/docs/centralized-architecture.png" width="600">
</kbd>

<br/> To achieve this, the "mntcs.conf" file should be mounted into the server and should be managed in a central location.
Then **mntcs** will be able to read the configuration file and set the required mounts.
In addition, **mntcs** should be configured as a service to run it at boot (and not only manually)

## Considerations & Limitations

- **mntcs** was designed to run only as "root" only so it doesn't support mounts with specific users (at least not for now)
- The purpose of **mntcs** is not to replace fstab, it was developed to solve a specific use case (without affecting the regular fstab usage)
- **mntcs** was developed and tested for ubuntu

## Installation

