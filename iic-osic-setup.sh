#!/bin/sh
# ==============================================================
# Initialization of IIC Open-Source EDA Environment
#
# (c) 2021-2022 Harald Pretl
# Institute for Integrated Circuits
# Johannes Kepler University Linz
#
# This script installs OpenLane, xschem, ngspice, magic, netgen,
# and a few other tools for use with SkyWater Technology SKY130.
# ==============================================================

# Define setup environment
# ------------------------
export MY_PDK=/usr/local/share/pdk
export MY_STDCELL=sky130_fd_sc_hd
export SRC_DIR="$HOME/src"
export OPENLANE_DIR="$HOME/OpenLane"
export SCRIPT_DIR=$(dirname $(realpath "$0"))
export NGSPICE_VERSION=36

# ---------------
# Now go to work!
# ---------------

# Update Ubuntu/Xubuntu installation
# ----------------------------------
# the sed is needed for xschem build
echo ">>>> Update packages"
sudo sed -i 's/# deb-src/deb-src/g' /etc/apt/sources.list
sudo apt -qq update -y
sudo apt -qq upgrade -y


# Optional removal of unneeded packages to free up space, important for VirtualBox
# --------------------------------------------------------------------------------
echo ">>>> Removing packages to free up space"
# FIXME could improve this list
sudo apt -qq remove -y libreoffice-* pidgin* thunderbird* transmission* xfburn* \
	gnome-mines gnome-sudoku sgt-puzzles parole gimp*
sudo apt -qq autoremove -y


# Install all the packages available via apt
# ------------------------------------------
echo ">>>> Installing required (and useful) packages via APT"
# FIXME ngspice installed separately, as APT version in LTS is too old
sudo apt -qq install -y docker.io git klayout iverilog gtkwave ghdl \
	verilator yosys xdot python3 python3-pip \
	build-essential automake autoconf gawk m4 flex bison \
	octave octave-signal octave-communications octave-control \
	xterm csh tcsh htop mc vim vim-gtk3 kdiff3 \
	tcl8.6 tcl8.6-dev tk8.6 tk8.6-dev \
	graphicsmagick ghostscript mesa-common-dev libglu1-mesa-dev \
	libxpm-dev libx11-6 libx11-dev libxrender1 libxrender-dev \
	libxcb1 libx11-xcb-dev libcairo2 libcairo2-dev  \
	libxpm4 libxpm-dev libgtk-3-dev


# Add user to Docker group
# ------------------------
sudo usermod -aG docker $USER


# Create PDK directory if it does not yet exist
# ---------------------------------------------
if [ ! -d "$MY_PDK" ]; then
	echo ">>>> Creating PDK directory $MY_PDK"
	
	sudo mkdir "$MY_PDK"
	sudo chown $USER:staff "$MY_PDK"
fi


# Install/update OpenLane from GitHub
# -----------------------------------
export PDK_ROOT="$MY_PDK"
export STD_CELL_LIBRARY="$MY_STDCELL"
if [ -d "$OPENLANE_DIR" ]; then
	echo ">>>> Updating OpenLane"
	cd "$OPENLANE_DIR"
	git pull
else
	echo ">>>> Pulling OpenLane from GitHub"
	git clone https://github.com/The-OpenROAD-Project/OpenLane.git "$OPENLANE_DIR"
fi


# Update OpenLane
# ---------------
cd "$OPENLANE_DIR"
echo ">>>> Pulling latest OpenLane version"
make pull-openlane
echo ">>>> Creating/updating PDK"
rm -rf "$PDK_ROOT/skywater-pdk" # FIXME WA otherwise `git clone` fails
make pdk


# Apply SPICE modellib reducer
# ----------------------------
echo ">>>> Applying SPICE model library reducer"
cd "$PDK_ROOT/sky130A/libs.tech/ngspice"
$SCRIPT_DIR/iic-spice-model-red.py sky130.lib.spice tt
$SCRIPT_DIR/iic-spice-model-red.py sky130.lib.spice ss
$SCRIPT_DIR/iic-spice-model-red.py sky130.lib.spice ff


# Add IIC custom bindkeys to magicrc file
# ---------------------------------------
echo ">>>> Add custom bindkeys to magicrc"
echo "# Custom bindkeys for IIC" 		>> "$PDK_ROOT/sky130A/libs.tech/magic/sky130A.magicrc"
echo "source $SCRIPT_DIR/iic-magic-bindkeys" 	>> "$PDK_ROOT/sky130A/libs.tech/magic/sky130A.magicrc"


# Install/update xschem
# ---------------------
if [ ! -d "$SRC_DIR/xschem" ]; then
	echo ">>>> Installing xschem"
	sudo apt build-dep -y xschem
	git clone https://github.com/StefanSchippers/xschem.git "$SRC_DIR/xschem"
	cd "$SRC_DIR/xschem"
	./configure
else
	echo ">>>> Updating xschem"
	cd "$SRC_DIR/xschem"
	git pull
fi
make -j$(nproc) && sudo make install


# Install/update xschem-gaw
# -------------------------
if [ ! -d "$SRC_DIR/xschem-gaw" ]; then
	echo ">>>> Installing gaw"
        git clone https://github.com/StefanSchippers/xschem-gaw.git "$SRC_DIR/xschem-gaw"
        cd "$SRC_DIR/xschem-gaw"
        aclocal && automake --add-missing && autoconf
	./configure
	# FIXME this is just a WA
	sed -i 's/GETTEXT_MACRO_VERSION = 0.20/GETTEXT_MACRO_VERSION = 0.19/g' po/Makefile

else
	echo ">>>> Updating gaw"
        cd "$SRC_DIR/xschem-gaw"
        git pull
fi
make -j$(nproc) && sudo make install


# Install/update magic
# --------------------
if [ ! -d "$SRC_DIR/magic" ]; then
	echo ">>>> Installing magic"
        git clone https://github.com/RTimothyEdwards/magic.git "$SRC_DIR/magic"
        cd "$SRC_DIR/magic"
        git checkout magic-8.3
	./configure
else
	echo ">>>> Updating magic"
        cd "$SRC_DIR/magic"
        git pull
fi
make -j$(nproc) && sudo make install


# Install/update netgen
# ---------------------
if [ ! -d "$SRC_DIR/netgen" ]; then
	echo ">>>> Installing netgen"
        git clone https://github.com/RTimothyEdwards/netgen.git "$SRC_DIR/netgen"
        cd "$SRC_DIR/netgen"
	git checkout netgen-1.5
        ./configure
else
	echo ">>>> Updating netgen"
        cd "$SRC_DIR/netgen"
        git pull
fi
make -j$(nproc) && sudo make install


# Install/update ngspice
# ----------------------
if [ ! -d  "$SRC_DIR/ngspice-$NGSPICE_VERSION" ]; then
	echo ">>>> Installing ngspice-$NGSPICE_VERSION"
	cd "$SRC_DIR"
	wget https://sourceforge.net/projects/ngspice/files/ng-spice-rework/$NGSPICE_VERSION/ngspice-$NGSPICE_VERSION.tar.gz
	gunzip ngspice-$NGSPICE_VERSION.tar.gz
	tar xf ngspice-$NGSPICE_VERSION.tar
	rm ngspice-$NGSPICE_VERSION.tar
	cd "$SRC_DIR/ngspice-$NGSPICE_VERSION"
	sudo apt install -y libxaw7-dev libfftw3-dev libreadline-dev
	./configure
	make -j$(nproc) && sudo make install
fi


# Install/update spyci
# --------------------
if [ ! -d "$SRC_DIR/spyci" ]; then
	echo ">>>> Installing spyci"
	git clone https://github.com/gmagno/spyci.git "$SRC_DIR/spyci"
	cd "$SRC_DIR/spyci"
else
	echo ">>>> Updating spyci"
	cd "$SRC_DIR/spyci"
	git pull
fi
sudo python3 setup.py install


# Fix paths in xschemrc to point to correct PDK directory
# -------------------------------------------------------
sed -i 's/^set SKYWATER_MODELS/# set SKYWATER_MODELS/g' "$PDK_ROOT/sky130A/libs.tech/xschem/xschemrc"
echo 'set SKYWATER_MODELS $env(PDK_ROOT)/sky130A/libs.tech/ngspice' >> "$PDK_ROOT/sky130A/libs.tech/xschem/xschemrc"
sed -i 's/^set SKYWATER_STDCELLS/# set SKYWATER_STD_CELLS/g' "$PDK_ROOT/sky130A/libs.tech/xschem/xschemrc"
echo 'set SKYWATER_STDCELLS $env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/spice' >> "$PDK_ROOT/sky130A/libs.tech/xschem/xschemrc"


# Create .spiceinit
# -----------------
echo "set num_threads=2" 							>  "$HOME/.spiceinit"
echo "set ngbehavior=hsa" 							>> "$HOME/.spiceinit"
echo "set ng_nomodcheck" 							>> "$HOME/.spiceinit"


# Create iic-init.sh
# ------------------
if [ ! -d "$HOME/.xschem" ]; then
	mkdir "$HOME/.xschem"
fi
echo '#!/bin/sh' 								>  "$HOME/iic-init.sh"
echo '#' 									>> "$HOME/iic-init.sh"
echo '# (c) 2021-2022 Harald Pretl'						>> "$HOME/iic-init.sh"
echo '# Institute for Integrated Circuits' 					>> "$HOME/iic-init.sh"
echo '# Johannes Kepler University Linz' 					>> "$HOME/iic-init.sh"
echo '#' 									>> "$HOME/iic-init.sh"
echo "export PDK_ROOT=$MY_PDK" 							>> "$HOME/iic-init.sh"
echo "export STD_CELL_LIBRARY=$MY_STDCELL" 					>> "$HOME/iic-init.sh"
echo 'cp -f $PDK_ROOT/sky130A/libs.tech/xschem/xschemrc $HOME/.xschem' 		>> "$HOME/iic-init.sh"
echo 'cp -f $PDK_ROOT/sky130A/libs.tech/magic/sky130A.magicrc $HOME/.magicrc' 	>> "$HOME/iic-init.sh"
chmod 750 "$HOME/iic-init.sh"


# Finished
# --------
echo ''
echo '>>>> All done. Please test the OpenLane install by running'
echo '>>>> make test'
echo ''
echo 'Remember to run `source ./iic-init.sh` to initialize environment!'

