#set -x 

machinetypes="`cs listServiceOfferings | jq '.serviceoffering[] | .displaytext + " : " +  .id' | sed 's/\"//g' | /bin/sed 's/ //g'`"

chosen_name="Micro 512mb 1cpu"

chosen_name="`/bin/echo ${chosen_name} | /bin/sed 's/ //g'`"

#IFS=":"

for machinetype in ${machinetypes}
do
    name="`/bin/echo ${machinetype} | /usr/bin/awk -F':' '{print $1}' | /bin/sed 's/ //g'`" 
    if ( [ "${name}" = "${chosen_name}" ] )
    then
        serviceoffering="`/bin/echo ${machinetype} | /usr/bin/awk -F':' '{print $2}'`" 
    fi
done

/bin/echo ${serviceoffering}
