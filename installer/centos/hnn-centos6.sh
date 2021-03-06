# this whole script probably needs to be run with root permissions to avoid sudo timeouts

# start with this since it gets input needed
sudo yum -y install git
# HNN repo from github - moved to github on April 8, 2018
git clone https://github.com/jonescompneurolab/hnn.git

sudo yum -y install epel-release
sudo yum -y install python34-devel
sudo yum -y install gcc-c++
sudo yum -y install libX11-devel
sudo yum -y groupinstall "Development tools"
sudo yum -y install xorg-x11-fonts-100dpi 
sudo yum -y install python34-Cython
sudo yum -y install python34-setuptools
sudo easy_install-3.4 pip
pip3 install --upgrade matplotlib --user
pip3 install --upgrade nlopt scipy --user
sudo yum -y install ncurses-devel
sudo yum -y install openmpi openmpi-devel
sudo yum -y install libXext libXext-devel
export PATH=$PATH:/usr/lib64/openmpi/bin
sudo PATH=$PATH:/usr/lib64/openmpi/bin pip3 install mpi4py

# save dir installing hnn to
startdir=$(pwd)
echo $startdir

git clone https://github.com/neuronsimulator/nrn
cd nrn
#git checkout be2997e
./build.sh
./configure --with-nrnpython=python3 --with-paranrn --disable-rx3d \
    --without-iv --without-nrnoc-x11 --with-mpi --prefix=$startdir/nrn/build
make -j4
PATH=$PATH:/usr/lib64/openmpi/bin make install -j4
cd src/nrnpython
python3 setup.py install --user

# move outside of nrn directories
cd $startdir

# setup HNN itself
cd hnn
# make compiles the mod files
export CPU=$(uname -m)
export PATH=$PATH:$startdir/nrn/build/$CPU/bin
make
cd ..

# create the global session variables, make available for all users
echo '# these lines define global session variables for HNN' | sudo tee -a /etc/profile.d/hnn.sh
echo 'export CPU=$(uname -m)' | sudo tee -a /etc/profile.d/hnn.sh
echo "export PATH=\$PATH::/usr/lib64/openmpi/bin:$startdir/nrn/build/\$CPU/bin" | sudo tee -a /etc/profile.d/hnn.sh

# qt, pyqt, and supporting packages - needed for GUI
# SIP unforutnately not available as a wheel for Python 3.4, so have to compile
wget https://sourceforge.net/projects/pyqt/files/sip/sip-4.19.2/sip-4.19.2.tar.gz
tar -zxf sip-4.19.2.tar.gz
cd sip-4.19.2
sudo python3 configure.py
make -j4
sudo make install -j4
cd ..
sudo rm -rf sip-4.19.2
rm -f sip-4.19.2.tar.gz

sudo yum -y install qt-devel
sudo yum -y install qt5-qtbase
sudo yum -y install qt5-qtbase-devel

wget https://sourceforge.net/projects/pyqt/files/PyQt5/PyQt-5.8.2/PyQt5_gpl-5.8.2.tar.gz
tar -xvf PyQt5_gpl-5.8.2.tar.gz
cd PyQt5_gpl-5.8.2
python3 configure.py --qmake=/usr/lib64/qt5/bin/qmake --confirm-license
make -j4
sudo make install -j4
cd ..
rm -rf PyQt5_gpl-5.8.2
rm -f PyQt5_gpl-5.8.2.tar.gz

# used by pqtgraph - for visualization
sudo pip3 install PyOpenGL PyOpenGL_accelerate

# pyqtgraph - only used for visualization
sudo pip3 install pyqtgraph

# needed for matplotlib
sudo yum -y install python34-tkinter

pip3 install psutil --user