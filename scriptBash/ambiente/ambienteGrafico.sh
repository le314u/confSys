sudo apt-get install -y openbox     # gerenciador de janelas  
sudo apt-get install -y obconf      # temas para openBox
sudo apt-get install -y xcompmgr    # composite manager | efeitos nas janelas
sudo apt-get install -y tint2       # painel | barra
sudo apt-get install -y easy-logout 
sudo apt-get install -y parcellite  # gerenciamento de clipboard
sudo apt-get install -y volumeicon-alsa #gerenciamento de audio
sudo apt-get install -y lxappearance # temas para gtk
sudo apt-get install -y gmrun # launcher
sudo apt-get isntall -y xfce4-appfinder # search
sudo apt-get install -y nitrogen
sudo apt-get install -y xdotool
sudo apt-get install -y gnome-screenshot
sudo apt-get install -y lxrandr
sudo apt-get install -y gnome-calculator
sudo apt-get install -y gnome-calendar

obconf --install ./themes/openbox-3/dracula.obt
echo "
xcompmgr -scfFr 10 -D 5 -o 0.3 &
tint2 &
volumeicon &
parcellite &
nitrogen --restore &
"> ~/.config/openbox/autostart


