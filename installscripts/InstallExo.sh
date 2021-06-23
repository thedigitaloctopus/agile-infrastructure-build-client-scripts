exoscale_cli_archive="`/usr/bin/curl https://github.com/exoscale/cli/releases/ | /bin/grep tar.gz | /bin/grep amd | /bin/grep download | /bin/grep linux | /usr/bin/head -1 | /bin/sed 's/.*exoscale-cli/exoscale-cli/g' | /usr/bin/awk -F'"' '{print $1}'`"
version="`/bin/echo ${exoscale_cli_archive} | /bin/sed 's/.*exoscale-cli_//g' | /bin/sed 's/_linux.*//g'`"
/usr/bin/wget https://github.com/exoscale/cli/releases/download/v${version}/${exoscale_cli_archive}
