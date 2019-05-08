#!/bin/bash
# Run as normal user

echo 'Be sure to install appropriate graphics driver.'
sudo pacman -S xorg-server xorg-xinit xorg-apps pulseaudio pulseaudio-alsa pulsemixer ttf-dejavu otf-font-awesome i3-gaps i3blocks i3lock dmenu termite compton sysstat htop acpi lxappearance neofetch xclip xdotool libnotify dunst xwallpaper bc firefox

WORKDIR=$(pwd | sed 's/dotfiles.*/dotfiles/')
LOCAL="$HOME/.local"
CONFIG="$HOME/.config"

echo 'Creating folders...'
mkdir -vp $LOCAL/bin $LOCAL/share $LOCAL/aur
mkdir -vp $CONFIG/i3 $CONFIG/termite $CONFIG/nvim $CONFIG/dunst $CONFIG/compton $CONFIG/i3blocks

#echo 'Enabling touchpad for x...'
#sudo mkdir -vp /etc/X11/xorg.conf.d
#sudo cat > /etc/X11/xorg.conf.d/90-touchpad.conf << 'EOF'
#Section "InputClass"
#    Identifier "touchpad"
#    MatchIsTouchpad "on"
#    Driver "libinput"
#    Option "Tapping" "on"
#    Option "TappingButtonMap" "lmr"
#    Option "NaturalScrolling" "on"
#    Option "ScrollMethod" "twofinger"
#EndSection
#EOF

echo 'Copying config files...'
cat /etc/X11/xinit/xinitrc | sed -e "/^xclock\|^twm\|xterm\|^$/d" > $HOME/.xinitrc
cat >> $HOME/.xinitrc << 'EOF'
eval $(/usr/bin/gnome-keyring/daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK
exec i3
EOF

cp /etc/xdg/compton.conf $CONFIG/compton/
# TODO: make termite config file available
cp /etc/xdg/termite/config $CONFIG/termite/
cat $WORKDIR/arch/termite-gruvbox.txt >> $CONFIG/termite/config
cp /usr/share/dunst/dunstrc $CONFIG/dunst/

# Installing bash config
echo 'Removing old bash config...'
rm -f $HOME/\.bash*

cp $WORKDIR/shell/profile $HOME/.profile && echo '~/.profile copied'
cp $WORKDIR/shell/bash/bashrc $HOME/.bashrc && echo '~/.bashrc copied'
cp $WORKDIR/shell/bash/aliases $HOME/.aliases && echo '~/.aliases copied'

# Installing nvim config
echo 'Installing nvim configs...'
cp $WORKDIR/vim/init.vim $CONFIG/nvim/init.vim
echo 'Installing vim-plug...'
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
mkdir -vp ~/.local/share/nvim/site/plugged
nvim +:PlugInstall +:qall

# Install i3
echo 'Installing i3 config...'
cp $WORKDIR/i3/config $CONFIG/i3/config
cp $WORKDIR/i3/i3blocks/* $CONFIG/i3blocks/

# Install scripts
echo 'Installing scripts...'
cp $WORKDIR/scripts/* $LOCAL/bin/
cp $WORKDIR/scripts/res/* $LOCAL/share/