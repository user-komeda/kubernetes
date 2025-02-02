sudo curl -LO https://github.com/openssl/openssl/releases/download/openssl-3.0.15/openssl-3.0.15.tar.gz
sudo tar xvf openssl-3.0.15.tar.gz
sudo dnf -y install perl perl-FindBin perl-Module-Load-Conditional perl-Test-Harness perl-CPAN
cd openssl-3.0.15
sudo ./config enable-md2
sudo make -j4 && sudo make install
echo "export LD_LIBRARY_PATH=/usr/local/lib64" >> ~/.bashrc
source ~/.bashrc
echo $(openssl version)
