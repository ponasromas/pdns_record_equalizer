#!/bin/bash
#
# Put script into master server. It requires root login to SQL DB on all servers.

# vars
master='ns1'
slave='ns2'
local_db='pdns'
remote_db='pdns'
vip_domain='domain.tld' # domain used for NS. This domain will be ignored in comparison!

# local DB domains
names_on_local=$(mysql -N --database="${local_db}" --execute="SELECT name FROM domains WHERE name != '${vip_domain}';")

# remote DB domains
names_on_remote=$(ssh -A root@${slave} "mysql -N -D '${remote_db}' -se 'SELECT name FROM domains WHERE name != \"${vip_domain}\";'")

# compare function
compare () {

local a=("$1")
local b=("$2")

declare -a arr

for x in ${a[@]}
do
	if [[ ! ${b[@]} =~ ${x} ]]
	then
		arr+=("${x}")
	fi
done

echo ${arr[@]}

}

delete_zone () {

local zone="$1"
local server="$2"

if [[ ${server} =~ 'ns1' ]]
then
	for zone in ${zone[@]}
	do
		pdnsutil delete-zone ${zone}
		echo "Removed zone: ${zone} from ${server}"
	done
else
	for zone in ${zone[@]}
	do
		ssh -A root@${server} << EOF
		pdnsutil delete-zone ${zone}
EOF
		echo "Removed zone: ${zone} from ${server}"
	done
fi

}

remote_dormant_zones=$(compare "${names_on_remote[@]}" "${names_on_local[@]}")
local_dormant_zones=$(compare "${names_on_local[@]}" "${names_on_remote[@]}")

[ -z "${remote_dormant_zones}" ] || echo -e "Dormant zones in SLAVE server:\n ${remote_dormant_zones[@]}"
[ -z "${local_dormant_zones}" ]  || echo -e "Dormant zones in MASTER server:\n ${local_dormant_zones[@]}"

# remove zones
[ -z "${remote_dormant_zones}" ] && echo "Nothing to delete!" || delete_zone "${remote_dormant_zones}" "${slave}"

exit 0





