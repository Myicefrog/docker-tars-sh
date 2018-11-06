#!/bin/bash

if [ -d /root/init ];then

	for x in $(ls /root/init)
	do
		if [ -f /root/init/$x ];then
			chmod u+x /root/init/$x
			/bin/bash /root/init/$x
			rm -rf /root/init/$x
		fi
	done
fi


case ${1} in
	init)
		;;
	start)
		/usr/local/app/tars/tarsnode/util/start.sh
		echo "already install"
		tail -f /dev/null
		;;
	*)
		exec "$@"
		;;
esac

