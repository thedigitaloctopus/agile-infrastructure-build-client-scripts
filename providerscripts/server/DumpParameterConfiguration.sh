        #########Added 
        
        /bin/cp /dev/null ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_configuration_settings.dat
        
        while read scpparam
        do
             scpparam1="`eval /bin/echo ${scpparam}`"
             if ( [ "${scpparam1}" != "" ] )
             then
                 /bin/echo ${scpparam1} >> ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_configuration_settings.dat
             fi
        done < ${BUILD_HOME}/builddescriptors/webserverscp.dat
        
        /bin/cp /dev/null ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_configuration_settings.dat
        
        while read scpparam
        do
             scpparam1="`eval /bin/echo ${scpparam}`"
             if ( [ "${scpparam1}" != "" ] )
             then
                 /bin/echo ${scpparam1} >> ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_configuration_settings.dat
             fi
        done < ${BUILD_HOME}/builddescriptors/webserverscp.dat
       
        
        /bin/cp /dev/null ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/database_configuration_settings.dat
        
        while read scpparam
        do
             scpparam1="`eval /bin/echo ${scpparam}`"
             if ( [ "${scpparam1}" != "" ] )
             then
                 /bin/echo ${scpparam1} >> ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/database_configuration_settings.dat
             fi
        done < ${BUILD_HOME}/builddescriptors/webserverscp.dat
        

        ##########Added
