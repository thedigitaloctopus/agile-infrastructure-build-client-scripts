        #########Added 
        
        /bin/cp /dev/null ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_configuration_settings.dat
        
        command="/usr/bin/scp ${OPTIONS}"
        while read scpparam
        do
             scpparam1="`eval /bin/echo ${scpparam}`"
             if ( [ "${scpparam1}" != "" ] )
             then
                 /bin/echo ${scpparam1} >> ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_configuration_settings.dat
             done
        done < ${BUILD_HOME}/builddescriptors/webserverscp.dat
        
        command="${commmand} \"${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_configuration_settings.dat ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh >/dev/null 2>&1\""
        eval ${command}
        
        /bin/cp /dev/null ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_configuration_settings.dat
        
        command="/usr/bin/scp ${OPTIONS}"
        while read scpparam
        do
             scpparam1="`eval /bin/echo ${scpparam}`"
             if ( [ "${scpparam1}" != "" ] )
             then
                 /bin/echo ${scpparam1} >> ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_configuration_settings.dat
             done
        done < ${BUILD_HOME}/builddescriptors/webserverscp.dat
        
        command="${commmand} \"${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/database_configuration_settings.dat ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh >/dev/null 2>&1\""
        eval ${command}
        
                /bin/cp /dev/null ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/database_configuration_settings.dat
        
        command="/usr/bin/scp ${OPTIONS}"
        while read scpparam
        do
             scpparam1="`eval /bin/echo ${scpparam}`"
             if ( [ "${scpparam1}" != "" ] )
             then
                 /bin/echo ${scpparam1} >> ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/database_configuration_settings.dat
             done
        done < ${BUILD_HOME}/builddescriptors/webserverscp.dat
        
        command="${commmand} \"${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_configuration_settings.dat ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh >/dev/null 2>&1\""
        eval ${command}
        

        ##########Added
