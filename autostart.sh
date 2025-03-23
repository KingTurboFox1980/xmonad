#!/bin/bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

#Set your native resolution IF it does not exist in xrandr
#More info in the script
#run $HOME/.xmonad/scripts/set-screen-resolution-in-virtualbox.sh

#Find out your monitor name with xrandr or arandr (save and you get this line)
#xrandr --output VGA-1 --primary --mode 1360x768 --pos 0x0 --rotate normal
#xrandr --output DP2 --primary --mode 1920x1080 --rate 60.00 --output LVDS1 --off &
#xrandr --output LVDS1 --mode 1366x768 --output DP3 --mode 1920x1080 --right-of LVDS1
#xrandr --output HDMI2 --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output VIRTUAL1 --off

#change your keyboard if you need it
#setxkbmap -layout be

(sleep 2; run /home/j3ll0/.config/polybar/launch.sh) &

#cursor active at boot
xsetroot -cursor_name left_ptr &

#start ArcoLinux Welcome App
run dex $HOME/.config/autostart/arcolinux-welcome-app.desktop

#Some ways to set your wallpaper besides variety or nitrogen
#feh --bg-fill /usr/share/backgrounds/archlinux/arch-wallpaper.jpg &
#feh --bg-fill /usr/share/backgrounds/arco/1920x1080_Neon.jpg &


run variety &
run nm-applet &
#run pamac-tray &
run xfce4-power-manager &
run volumeicon &
numlockx on &
blueberry-tray &
run copyq &
run mons -e left &
run /home/j3ll0/.config/polybar/launch.sh &
run trayer --margin 2 --distancefrom left --distance 1920 --edge top --align right --SetDockType false --SetPartialStrut true --expand true --width 10 --widthtype request --height 25 --heighttype pixel --transparent false --alpha 240 --padding 3 &
run picom --config $HOME/.xmonad/scripts/picom.conf &
run redshift -P -l 43.8:-79.3 -O 4000 &
#run "xmobar &"
#run "$HOME/.xmonad/scripts/onedrive.sh &"
run conky -c /home/j3ll0/.xmonad/scripts/system-overview.conkyrc &
run conky -c /home/j3ll0/.xmonad/scripts/AUR-Allinone.conkyrc &

/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
/usr/lib/xfce4/notifyd/xfce4-notifyd &


#nitrogen --restore &
#run caffeine &
#run vivaldi-stable &
#run firefox &
#run thunar &
#run spotify &
#run atom &

#run telegram-desktop &
#run discord &
#run dropbox &
#run insync start &
#run ckb-next -b &
