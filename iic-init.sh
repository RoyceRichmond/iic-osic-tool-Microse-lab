#!/bin/sh
#
# (c) 2021-2022 Harald Pretl
# Institute for Integrated Circuits
# Johannes Kepler University Linz
#
export PDK_ROOT=$HOME/pdk
export PDK=sky130B
export STD_CELL_LIBRARY=sky130_fd_sc_hd
cp -f $PDK_ROOT/$PDK/libs.tech/xschem/xschemrc $HOME/.xschem
cp -f $PDK_ROOT/$PDK/libs.tech/magic/$PDK.magicrc $HOME/.magicrc
#add a user customizable project path, this will be added when opening and inserting elements
#
# $HOME/Desktop/Xschem can be anything e.g. $HOME/Downloads/Mysims
#
#only mofidy this part of the script
export custom_dir=$HOME/Desktop/Xschem

#this line adds a mounted disk in this case a google drive to the explorer of xschem
#export custom_dir="/mnt/g"
#
#to acomplish the mount of a google drive the fstab is modified first
# sudo gedit /etc/fstab
# G: /mnt/g drvfs defaults 0 0
###############
# the .bashrc has to be modified with this one
#
#  if ! mount | grep /mnt/g; then
#      sudo mount -a
#  fi
#
# this will esentially mount the g if it has not already been mounted on each terminal
#
#
#
#####################


if [ -d "$custom_dir" ]; then
  echo "append XSCHEM_LIBRARY_PATH :$custom_dir" >> $HOME/.xschem/xschemrc
  echo "$custom_dir does exist adding it to the path."
else
  echo "the directory does not exist, do you want to create it ? y/n"
  
  read -r -p "[y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
  then
    mkdir $custom_dir
    echo "$custom_dir was created"
    echo "append XSCHEM_LIBRARY_PATH :$custom_dir" >> $HOME/.xschem/xschemrc
  else
    echo "continue without modifications"
  fi
  
fi
echo "set netlist_dir $custom_dir/Raw" >> $HOME/.xschem/xschemrc
#echo "set local_netlist_dir 1" >> $HOME/.xschem/xschemrc




