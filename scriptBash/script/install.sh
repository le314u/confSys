#!/bin/bash

#Shufle

#Snap
sudo apt-get install -y snap

#Navegador chrome
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y google-chrome-stable

#Peek
sudo add-apt-repository ppa:peek-developers/stable
sudo apt-get update
sudo apt-get install -y peek

#VsCode
wget "https://go.microsoft.com/fwlink/?LinkID=620884" -O vscode.tar.gz
sudo tar -vzxf vscode.tar.gz -C /opt/
sudo mv /opt/VSCode*/ /opt/vscode/
sudo ln -sf /opt/vscode/code /usr/bin/code
echo -e '[Desktop Entry]\n Version=1.0\n Name=vscode\n Exec=/opt/vscode/code\n Icon=/opt/vscode/resources/app/resources/linux/code.png\n Type=Application\n Categories=Application' | sudo tee /usr/share/applications/vscode.desktop

#NodeJs
wget https://nodejs.org/dist/v12.16.3/node-v12.16.3-linux-x64.tar.xz -O node.tar.xz
sudo tar -xvf node.tar.gz -C /opt/
sudo ln -sf /opt/node-v12.16.3-linux-x64/bin/node /usr/bin/node

#Python3
sudo apt-get install -y python3
sudo apt-get install -y python3-pip

#R
sudo apt-get install -y r-cran-littler

#Tex
sudo apt-get install -y texlive texlive-latex-extra texlive-lang-portuguese

#Plank
sudo add-apt-repository ppa:docky-core/stable
sudo apt-get update
sudo apt-get install -y plank

#Youtube-dl
sudo apt-get install -y youtube-dl

#VirtualBox
wget https://download.virtualbox.org/virtualbox/6.1.6/virtualbox-6.1_6.1.6-137129~Ubuntu~eoan_amd64.deb -O virtualBox.deb
sudo dpkg -i virtualBox.deb

#FlameShot
sudo apt-get install -y flameshot

#Vim
sudo apt-get install -y vim

#Htop
sudo apt-get install -y htop

#Gparted
sudo apt-get install -y gparted

#Git
sudo apt-get install -y git

#Discord
wget https://dl.discordapp.net/apps/linux/0.0.10/discord-0.0.10.deb -O discord.deb
sudo dpkg -i discord.deb

#Mysql Work Bench
wget https://downloads.mysql.com/archives/get/p/8/file/mysql-workbench-community_8.0.19-1ubuntu19.10_amd64.deb -O mysqlWorkbench.deb
sudo dpkg -i mysqlWorkbench.deb

#whatsApp
sudo apt-get install -y whatsapp-desktop

#Httrack
sudo apt-get install -y webhttrack

#Syncthing
sudo apt-get install syncthin

#Git Kraken
wget https://release.gitkraken.com/linux/gitkraken-amd64.deb -O gitKraken.deb
sudo dpkg -i gitKraken.deb

