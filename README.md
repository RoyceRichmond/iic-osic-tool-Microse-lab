# IIC-OSIC Tools

## Installation
Download and uncompress the file and get into the main folder and type this commmand

```shell
source iic-osic-setup.sh
```
And now we wait, this script will install everything for you, just wait a little bit. after the installation is completed we proceed to

## Initialization of SKY130 PDK and tools

The setup script creates also an initialization script in the user's home directory. Use it to set up the environment by running

```shell
source ./iic-init.sh
```
this command must be run before executing Xschem, it gives the right routes for the installation to identify the elements, typical usage looks like this.

-New terminal
-type
```shell
source iic-init.sh
xschem
```
