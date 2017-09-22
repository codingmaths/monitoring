#!/bin/bash

ICINGA_HOSTNAME="ICINGAWEB2_HOSTNAME"
SLACK_WEBHOOK_URL="<SLACK_WEBHOOK_URL>"
SLACK_CHANNEL="#icinga-monitor"
SLACK_WEBHOOK_PROD="<Prod Webhook URL"
SLACK_CHANNEL_PROD="#prod-channel"
SLACK_BOTNAME="icinga2"

#Set the message icon based on ICINGA service state
if [ "$SERVICESTATE" = "CRITICAL" ]
then
    ICON=":bomb:"
elif [ "$SERVICESTATE" = "WARNING" ]
then
    ICON=":warning:"
elif [ "$SERVICESTATE" = "OK" ]
then
    ICON=":beer:"
elif [ "$SERVICESTATE" = "UNKNOWN" ]
then
    ICON=":question:"
else
    ICON=":white_medium_square:"
fi

# Hack to avoid NTP Service Alterts
if [ "$SERVICEDISPLAYNAME" = "ntp" ]; then
    echo "NTP Service"
    
elif [[ " ${GROUPNAME[@]} " =~ "production" ]]; then
  
    #Send message to Slack
    PAYLOAD="payload={\"channel\": \"${SLACK_CHANNEL_PROD}\", \"username\": \"${SLACK_BOTNAME}\", \"text\": \"${ICON} HOST: <https://${ICINGA_HOSTNAME}/ic
ingaweb2/monitoring/host/services?host=${HOSTNAME}|${HOSTDISPLAYNAME}>   SERVICE: <https://${ICINGA_HOSTNAME}/icingaweb2/monitoring/service/show?host=${HOSTNAME}&service=${SERVICEDESC}|${SERVICEDISPLAYNAME}>  STATE: ${SERVICESTATE}  Additional Info:: ${SERVICEOUTPUT} \"}"

    curl --connect-timeout 30 --max-time 60 -s -S -X POST --data-urlencode "${PAYLOAD}" "${SLACK_WEBHOOK_PROD}"

else

    PAYLOAD="payload={\"channel\": \"${SLACK_CHANNEL}\", \"username\": \"${SLACK_BOTNAME}\", \"text\": \"${ICON} HOST: <https://${ICINGA_HOSTNAME}/icingaw
eb2/monitoring/host/services?host=${HOSTNAME}|${HOSTDISPLAYNAME}>   SERVICE: <https://${ICINGA_HOSTNAME}/icingaweb2/monitoring/service/show?host=${HOSTNAME}&service=${SERVICEDESC}|${SERVICEDISPLAYNAME}>  STATE: ${SERVICESTATE}  Additional Info:: ${SERVICEOUTPUT} \"}"

    curl --connect-timeout 30 --max-time 60 -s -S -X POST --data-urlencode "${PAYLOAD}" "${SLACK_WEBHOOK_URL}"
fi
