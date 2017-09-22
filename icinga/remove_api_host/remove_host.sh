#!/bin/bash
export mysqluser=icinga
export mysqlpassword=icinga
export mysqldatabase=icinga

cat remove_host.sh.config | while read line

do

	org=`echo $line| cut -d ":" -f1`
	environment=` echo $line| cut -d ":" -f2`

	mysqlhost=$(mysql --user="$mysqluser" --password="$mysqlpassword" --database="$mysqldatabase" --execute="select address from icinga_hosts where display_name='"${org}-${environment}-server"'")

	instanceIPs=$(aws ec2 describe-instances --filters "Name=tag:Name,Values='"bijou-${org}-${environment}-auto-scaling-group"'" --query 'Reservations[].Instances[].PublicIpAddress' --output text)
	#instanceIPs=`aws ec2 describe-instances --filters "Name=tag:Name,Values=bijou-{{ org }}-{{ environment }}-auto-scaling-group" --query 'Reservations[].Instances[].PublicIpAddress' --output text`

	value=`echo ${mysqlhost[@]} ${instanceIPs[@]} | tr ' ' '\n' | sort | uniq -u`

	for ip in  $value
		do

			curl -k -s -u root:6021bf293cda45fa -H 'Accept: application/json' -X DELETE "https://52.19.194.134:5665/v1/objects/hosts/${ip}?cascade=1" | python -m json.tool

		done

done
curl -k -s -u root:6021bf293cda45fa -H 'Accept: application/json' -X POST 'https://52.19.194.134:5665/v1/actions/restart-process' | python -m json.tool
