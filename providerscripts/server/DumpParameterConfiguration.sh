  
  if ( [ "${1}" = "autoscaler" ] )
  then
      /bin/cp /dev/null ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_configuration_settings.dat
        
        while read param
        do
             param1="`eval /bin/echo ${param}`"
             if ( [ "${param1}" != "" ] )
             then
                 /bin/echo ${param1} >> ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_configuration_settings.dat
             fi
        done < ${BUILD_HOME}/builddescriptors/autoscalerscp.dat
  fi  
        ##########
  if ( [ "${1}" = "webserver" ] )
  then
        /bin/cp /dev/null ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_configuration_settings.dat
        
        while read param
        do
             param1="`eval /bin/echo ${param}`"
             if ( [ "${param1}" != "" ] )
             then
                 /bin/echo ${param1} >> ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_configuration_settings.dat
             fi
        done < ${BUILD_HOME}/builddescriptors/webserverscp.dat
  fi  
        #############
        
  if ( [ "${1}" = "database" ] )
  then
        /bin/cp /dev/null ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/database_configuration_settings.dat
        
        while read param
        do
             param1="`eval /bin/echo ${param}`"
             if ( [ "${param1}" != "" ] )
             then
                 /bin/echo ${param1} >> ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/database_configuration_settings.dat
             fi
        done < ${BUILD_HOME}/builddescriptors/databasescp.dat
fi
