#!/bin/bash
echo "## Installation de syncthing"

CURRENT_USER=ubuntu
HOME=/home/${CURRENT_USER}

sudo sysctl -w fs.inotify.max_user_watches=204800
sudo sysctl --system

# Add the release PGP keys:
curl -s https://syncthing.net/release-key.txt | sudo apt-key add -

# Add the "stable" channel to your APT sources:
SYNCTHING_APT_CONF="deb https://apt.syncthing.net/ syncthing candidate"  # candidate channel instead of stable for inotify support
SYNCTHING_APT_CONF_FILE="/etc/apt/sources.list.d/syncthing.list"
grep -q -F "$SYNCTHING_APT_CONF" "$SYNCTHING_APT_CONF_FILE" || echo "$SYNCTHING_APT_CONF" | sudo tee "$SYNCTHING_APT_CONF_FILE"

# Update and install syncthing:
sudo apt-get update -y
sudo apt-get install syncthing syncthing-inotify -y

if [ ! -f "$HOME/.config/syncthing" ]; then
    syncthing -generate="$HOME/.config/syncthing"
    sed -i "s|<address>127.0.0.1:8384</address>|<address>0.0.0.0:8384</address>|g" "$HOME/.config/syncthing/config.xml"
    sed -i "s|<startBrowser>true</startBrowser>|<startBrowser>false</startBrowser>|g" "$HOME/.config/syncthing/config.xml"
    sed -i "s|<globalAnnounceEnabled>true</globalAnnounceEnabled>|<globalAnnounceEnabled>false</globalAnnounceEnabled>|g" "$HOME/.config/syncthing/config.xml"
    sed -i "s|<natEnabled>true</natEnabled>|<natEnabled>false</natEnabled>|g" "$HOME/.config/syncthing/config.xml"
    sed -i "s|<relaysEnabled>true</relaysEnabled>|<relaysEnabled>false</relaysEnabled>|g" "$HOME/.config/syncthing/config.xml"
    sed -i "s|<autoUpgradeIntervalH>.*?</autoUpgradeIntervalH>|<autoUpgradeIntervalH>0</autoUpgradeIntervalH>|g" "$HOME/.config/syncthing/config.xml"
fi

sudo systemctl enable syncthing@$CURRENT_USER.service
sudo systemctl enable syncthing-inotify@$CURRENT_USER.service

# Start the Services
sudo service syncthing start
sudo service syncthing-inotify start