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

```shell
source iic-init.sh
xschem
```
## Notes on folder system and error on symbols
Altho the installation program works on any machine, with any user name, carefull atention must be payed when working with different folders.

The following is an example, when trying to open a schematic file (.sch) and the terminal returns an error, where it states it can't find a symbol used in the simulation.

![alt text](https://github.com/RoyceRichmond/iic-osic-tool-Microse-lab/blob/main/Ref_md/img1.png?raw=true)

this means that xschem couldn't find a file necessary for the simulation at the specified path, it can be seen that the path repetes a folder like the following

```shell
/home/royce/Downloads/Downloads/mos_sym_spdt.sym
```
the correct form woul be

```shell
/home/royce/Downloads/mos_sym_spdt.sym
```
### Why does this happens ?

this happens because the files store the route where they where stored originally

if we go to out folder and open the sch file(the one we tried to open with xschem and returned an error), and scroll all the way to the bottom we would see a line somehting like this

```shell
C {Downloads/mos_sym_spdt.sym} 110 -410 0 0 {name=x1}
```

#### yeah, quite clear, say what ?

so bare with me.

1. We created a schematic of something (lets say an inverter)
2. For practicity then we create a symbol.
3. We stored said symbol in a location, lets say Downloads (/home/user/downloads)
4. Then we create a new schematic, in which we import the symbol (the inverter in this example)
5. We run simulations, all good and fine and hit Save.
6. Now what happens is that the new schematic which has the symbol, stores with a relative path (for compatibility) the location of the elements used in the simulation.
7. If we save this file to lets say Home (here is where the problem beggins) and then change the location of this file (lets say to downloads) the program searches the prior location.

The problem occurs because we change the file from location, and the file does not update, this path is actually hardcoded on the file.

A proper management of routes will solve this issue.

Desktop
* Xschem
  * Symbols
  * Schematics
  * Raw

A folder system like this one will owrk across many systems and avoid the cumbersome management of routes

#### How do i fix it ?
You will see something like this

![alt text](https://github.com/RoyceRichmond/iic-osic-tool-Microse-lab/blob/main/Ref_md/img3.png?raw=true)

Double left click on the missing symbol and then hit the browse button, then you can look for the route of the symbol, this will update the relative path.
Now it will appear on the schematic and we can save the file with the updated route

![alt text](https://github.com/RoyceRichmond/iic-osic-tool-Microse-lab/blob/main/Ref_md/img2.png?raw=true)

# Google Drive and WSL
WSL is actually able to access the google drive folders as a normal unit, this can help with a more consistent workflow and avoid error with paths with different users etc, the first step to achieve this is to modify the fstab file

```shell
sudo gedit /etc/fstab
```
inside the file add this entry, the letter G: corresponds to the letter assigned to the google drive folder on your windows installation, the /mnt/g has the same value
```shell
G: /mnt/g drvfs defaults 0 0
```

After this step we modify the bashrc to load the configurations automatically each time a new terminal is open
```shell
gedit .bashrc
```
The .bashrc file is modified with these code
```shell
source /home/user_0/iic-init.sh
if ! mount | grep /mnt/g; then
    sudo mount -a
fi
```
Finally the iic-init.sh file has to be modify with these values, this will check if the Google Drive storage is already mounted, if so it adds it to the path in xschem otherwise a message will pop up showing that it is not mounted
```shell
export custom_dir="/mnt/g/Mi unidad/Xschem"

# Replace space with \ in the path
escaped_custom_dir="${custom_dir// /\\ }"

echo "Checking directory: $custom_dir"

if [ -d "$custom_dir" ]; then
  # Append with the escaped space
  echo "append XSCHEM_LIBRARY_PATH :$escaped_custom_dir" >> $HOME/.xschem/xschemrc
  echo "$custom_dir does exist, adding it to the path."
else
  echo "the directory does not exist, you sure it is mounted ?"
fi
```
