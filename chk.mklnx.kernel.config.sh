#!/bin/sh

CHK_CONFIG=$1

if [ -z "$CHK_CONFIG" ]; then
	echo "Please supply the path to a kernel configuration file"
	exit 1
fi

cat ${CHK_CONFIG} | grep "CONFIG_DEBUG_KERNEL" >/dev/null
if [ $? -ne 0 ]; then
	echo "Does not appear to be a kernel configuration file: $CHK_CONFIG"
	exit 1
fi

#CHK_CONFIG=/boot/config-6.1.0-20-amd64
while read line
do
	echo $line | grep -P '^(?=[\s]*+[^#])[^#]*'>/dev/null
	if [ $? -eq 0 ]; then 
		#echo "Got       $line"
		TOKEN_KEY=$(echo $line | awk -F '=' '{print $1}')
		TOKEN_VAL=$(echo $line | awk -F '=' '{print $2}')
		TOKEN="$(printf '%40s' ${TOKEN_KEY}=${TOKEN_VAL})"
		SRCH_TOKEN="${TOKEN_KEY}="
		#echo "SRCH_TOKEN=$SRCH_TOKEN"
		MATCH="$(cat ${CHK_CONFIG} | grep ${SRCH_TOKEN})"
		NOT_FOUND=$?
		MATCH_STR=""
		MARKER=" _ "
		if [ $NOT_FOUND -eq 0 ]; then
			MATCH_VAL="$(echo $MATCH | awk -F '=' '{print $2}')"
			MATCH_KEY="$(echo $MATCH | awk -F '=' '{print $1}')"
			MATCH_STR="${MATCH_VAL}=${MATCH_KEY}"
			if [ "${MATCH_VAL}"=="${TOKEN_VAL}" ]; then
				MARKER=" = "
			else
				MARKER=" X "

			fi
		else
			MARKER=" ? "
		fi
		echo "${TOKEN}${MARKER}${MATCH_STR}"
		#line="$(printf '%40s' $line)"
		#echo "$line   $MATCH"
	else
		echo "Rejected: $line"
	fi
done << EOF
CONFIG_LOCALVERSION="-mlnx"
CONFIG_DEFAULT_HOSTNAME="mlnx"
CONFIG_NET_IPIP=m
CONFIG_NET_IPGRE_DEMUX=m
CONFIG_NET_IPGRE=m
CONFIG_IPV6_GRE=m
CONFIG_IP_MROUTE_MULTIPLE_TABLES=y
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IPV6_MULTIPLE_TABLES=y
CONFIG_BRIDGE=m
CONFIG_VLAN_8021Q=m
CONFIG_BRIDGE_VLAN_FILTERING=y
CONFIG_BRIDGE_IGMP_SNOOPING=y
CONFIG_NET_SWITCHDEV=y
CONFIG_NET_DEVLINK=y
CONFIG_MLXFW=m
CONFIG_MLXSW_CORE=m
CONFIG_MLXSW_CORE_HWMON=y
CONFIG_MLXSW_CORE_THERMAL=y
CONFIG_MLXSW_PCI=m
CONFIG_MLXSW_I2C=m
CONFIG_MLXSW_MINIMAL=y
CONFIG_MLXSW_SWITCHX2=m
CONFIG_MLXSW_SPECTRUM=m
CONFIG_MLXSW_SPECTRUM_DCB=y
CONFIG_LEDS_MLXCPLD=m
CONFIG_NET_SCH_PRIO=m
CONFIG_NET_SCH_RED=m
CONFIG_NET_SCH_INGRESS=m
CONFIG_NET_CLS=y
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_MIRRED=m
CONFIG_NET_CLS_MATCHALL=m
CONFIG_NET_CLS_FLOWER=m
CONFIG_NET_ACT_GACT=m
CONFIG_NET_ACT_MIRRED=m
CONFIG_NET_ACT_SAMPLE=m
CONFIG_NET_ACT_VLAN=m
CONFIG_NET_L3_MASTER_DEV=y
CONFIG_NET_VRF=m
EOF

