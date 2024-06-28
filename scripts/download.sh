#!/usr/bin/env bash

VERSION=$1

echo -n "Version ${VERSION} will be downloaded. Old worlds may become unusable, please search for compatibility information on Terraria wiki or create a VPS backup. Proceed? (y/n) [default n] > "
read -n1 ans

if [ "$ans" == "y" ];
then
	echo -e "\nDownload in progress. Please wait..."
	VERSION_URL=$(curl -s https://terraria.wiki.gg/wiki/Server | grep -E "/pc-dedicated-server/terraria-server-${VERSION}.zip" | awk -F '"' '{print $6}' | uniq)
	
	if [ -n "${VERSION_URL}" ];
	then
		wget -q -O game.zip "${VERSION_URL}" 
		unzip -qq game.zip && cp -R "${VERSION}"/Linux/* /usr/lib/terraria/ && rm -rf "${VERSION}" && rm game.zip

		chmod +x /usr/lib/terraria/TerrariaServer && chmod +x /usr/lib/terraria/TerrariaServer.bin.x86_64
		chown -R terraria:terraria /usr/lib/terraria

		nver=$(awk '{print $2}' < /usr/lib/terraria/proc/version)
        echo "${VERSION}" "${nver}" > /usr/lib/terraria/proc/version

        /usr/lib/terraria/scripts/version_check.sh
	fi
fi