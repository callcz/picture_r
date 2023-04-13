#!/bin/bash
if [[ $1 == --help ]]
then
	echo "Usage : $0 [file]
Options:
	-w	New File width Pixels (default 32)
	-h	New File Hight Pixels (default 16)"
	exit
else
	./picture_r.sh $@ &
fi
puid=`ps -ef|grep picture_r.sh|grep bash|awk '{print $2}'`
esc=`echo -en "\033"`
my_exit_l(){
	kill -9 $puid
	echo -en "\E[0m""\e[48;1f""\033[?25h"
	exit
}
trap 'my_exit_l' 2
	while :
	do
		puid=`ps -ef|grep picture_r.sh|grep bash|awk '{print $2}'`
		if [[ ! $puid ]]
		then
			my_exit_l
		fi
		read -s -n1 akey
#		echo akey=$akey
		case $akey in
		$empty)
			key=space
			;;
		q)
			my_exit_l
			;;
		r)
			key=r
			;;
		s)
			key=s
			;;
		m)
			key=m
			;;
		p)
			key=p
			;;
		*)
			key3=$key2
			key2=$key1
			key1=$akey
#			echo akey=$akey key3=$key3 key2=$key2 key1=$key1
			if [[ $key3 == $esc && $key2 == '[' ]]
			then
				case $key1 in
					A) key=up ;;
					B) key=down ;;
					C) key=right ;;
					D) key=left ;;
				esac
			fi
		;;
		esac
		case $key in
			r) kill -22 $puid ;;
			s) kill -21 $puid ;;
			m) kill -23 $puid ;;
			p) kill -24 $puid ;;
			up) kill -25 $puid ;;
			down) kill -26 $puid ;;
			left) kill -27 $puid ;;
			right) kill -28 $puid ;;
			space) kill -29 $puid ;;
		esac
		unset key
	done
