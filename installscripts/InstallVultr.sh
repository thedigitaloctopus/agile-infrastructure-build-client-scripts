#!/bin/sh

        latest="`/usr/bin/curl https://github.com/JamesClonk/vultr/releases/latest | /bin/sed 's/.*tag\///g' | /bin/sed 's/\".*//g' | /bin/sed 's/v//g'`"
        /usr/bin/wget https://github.com/JamesClonk/vultr/releases/download/${latest}/vultr_linux_386.tar.gz
        /bin/tar xvfz ${BUILD_HOME}/vultr_linux_386.tar.gz
        /bin/cp ${BUILD_HOME}/vultr_linux_386/vultr /usr/bin
        /bin/rm -r ${BUILD_HOME}/vultr_linux_386
        /bin/rm ${BUILD_HOME}/vultr_linux_386.tar.gz
