






#It is envisaged that in the future, more langauges will be supported. Java and so on.
status "##################################################################"
status "What language do you need for your deployment? Currently we support:"
status "1) Just HTML/JAVASCRIPT 2) PHP"
status "##################################################################"

response=""

while (  [ "${response}" = "" ] || [ "`/bin/echo '1 2' | /bin/grep ${response}`" = "" ] )
do
    status "Please enter 1) or 2) to select"
    read response
done

if ( [ "${response}" = "1" ] )
then
    APPLICATION_LANGUAGE="HTML"
elif ( [ "${response}" = "2" ] )
then
    APPLICATION_LANGUAGE="PHP"

    status "#######################################################################################################################"
    status "Which version of PHP do you want to install? Available versions are: 7.0,7.1,7.2,7.3,7.4"
    status "#######################################################################################################################"
    status "Please enter one of 7.0 7.1 7.2 7.3 7.4"

    read PHP_VERSION

    while ( [ "`/bin/echo '7.0 7.1 7.2 7.3 7.4' | /bin/grep ${PHP_VERSION}`" = "" ] )
    do
        status "Sorry, that's not a valid selection, please try again"
        status "Please enter one of 7.0 7.1 7.2 7.3 7.4"
        read PHP_VERSION
    done
    
    status "#################################################################################################################################"
    status "Hi, you have chosen to install PHP, there's some additional configuration options you can set"
    status "These values are to do with how the PHP server will respond to requests and if you search for, static, dynamic or ondemand for php"
    status "you will find more information about it. If you are unsure, just enter N below to accept default values"
    status "##################################################################################################################################"
    status "If you want to use the default values enter N else if you want to reconfigure them here, enter Y"
    read response
    
    if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
    then
         status "Please select whether you want to use"
         status "1)static"
         status "2)dynamic"
         status "3)on demand" 
         status "for your server configuration"
         status "Please enter one of 1, 2 or 3"
         read response
         while ( [ "`/bin/echo "1 2 3" | /bin/grep ${response}`" = "" ] )
         do
             status "That's an invalid response, please try again"
             status "Please enter one of 1,2 or 3"
             read response
         done

         if ( [ "${response}" = "1" ] )
         then
             PHP_MODE="static"
         elif ( [ "${response}" = "2" ] )
         then
             PHP_MODE="dynamic"
         elif ( [ "${response}" = "3" ] )
         then
             PHP_MODE="ondemand"
         fi

         if ( [ "${PHP_MODE}" = "static" ] || [ "${PHP_MODE}" = "dynamic" ] || [ "${PHP_MODE}" = "ondemand" ] )
         then
             status "Please enter the value for the configuration value max_children"
             read response
             while ( [ 1 ] )
             do
                 if ( [ "${response}" -eq "${response}" 2>/dev/null ] )
                 then
                     PHP_MAX_CHILDREN="${response}"
                     break
                 else
                     status "Input must be a number, please try again:"
                     read response
                 fi
             done
         fi

         if ( [ "${PHP_MODE}" = "dynamic" ] )
         then
             status "Please enter the value for the configuration value start_servers"
             read response
             while ( [ 1 ] )
             do
                 if ( [ "${response}" -eq "${response}" 2>/dev/null ] )
                 then
                     PHP_START_SERVERS="${response}"
                     break
                 else
                     status "Input must be a number, please try again:"
                     read response
                 fi
             done
        fi

        if ( [ "${PHP_MODE}" = "dynamic" ] )
        then
            status "Please enter the value for the configuration value min_spare_servers"
            read response
            while ( [ 1 ] )
            do
                if ( [ "${response}" -eq "${response}" 2>/dev/null ] )
                then
                    PHP_MIN_SPARE_SERVERS="${response}"
                    break
                else
                    status "Input must be a number, please try again:"
                    read response
                fi
            done
        fi

        if ( [ "${PHP_MODE}" = "dynamic" ] )
        then
            status "Please enter the value for the configuration value max_spare_servers"
            read response
            while ( [ 1 ] )
            do
                if ( [ "${response}" -eq "${response}" 2>/dev/null ] )
                then
                    PHP_MAX_SPARE_SERVERS="${response}"
                    break
                else
                    status "Input must be a number, please try again:"
                    read response
                fi
            done
        fi

        if ( [ "${PHP_MODE}" = "ondemand" ] )
        then
            status "Please enter the value for the configuration value process_idle_timeout"
            read response
            while ( [ 1 ] )
            do
                if ( [ "${response}" -eq "${response}" 2>/dev/null ] )
                then
                    PHP_PROCESS_IDLE_TIMEOUT="${response}"
                    break
                else  
                    status "Input must be a number, please try again:"
                    read response
                fi
            done
	    fi
    fi
fi
