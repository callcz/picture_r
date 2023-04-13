#!/bin/bash
#▀
#▄
#█
################################
	if [[ -z `ps -ef|grep picture.sh|grep bash|awk '{print $2}'` ]]
	then
		echo Plase run \"./picture.sh\" .
		exit
	fi
################################
my_exit_l() {
	echo -en "\E[0m""\e[48;1f""\033[?25h"
	exit
}
echo -e "\033c""\e[?25l"
trap 'my_exit_l' 2
trap 'key=up' 25
trap 'key=down' 26
trap 'key=left' 27
trap 'key=right' 28
trap 'key=space' 29
trap 'key=r' 22
trap 'key=s' 21
trap 'key=m' 23
trap 'key=p' 24

#参数
while [[ -n $@ ]]
do
	case $1 in
		'--help')
			echo head -n2 $$
			my_exit_l
			;;
		-w)
			shift
			if [[ -n "`echo $1|sed 's/[0-9]//g'`" ]]
			then
				echo unknow option \'$1\'
			else
				width=$1
				shift
			fi
			;;
		-h)
			shift
			if [[ -n "`echo $1|sed 's/[0-9]//g'`" ]]
			then
				echo unknow option \'$1\'
			else
				hight=$1
				shift
			fi
			;;
		*)
			if [[ -a $1 ]]
			then
				paper=`cat $1`
				paper_size=($(awk -F▄ '{print $(NF-1)}' $1|sed -e 's/\\e\[//g' -e 's/f.*$//' -e 's/;/ /'))
				width=${paper_size[1]}
				hight=$((${paper_size[0]}*2))
				echo -en $paper"\e[0m"
				break
			else
				echo "$1 File does not exist !"
				my_exit_l
			fi
			;;
	esac
done
if [[ ! $width ]]
then
	width=32
fi
if [[ ! $hight ]]
then
	hight=16
fi
hight_real=$((hight/2))
total=$((width*hight_real))

#功能键提示
fun_tips_l(){
	local begin=$((hight_real+1))
	printf "\e[$begin;1H""\e[0m""P=PALETTE SPACE=SELECT/DRAW S=SAVE M=FOCUS R=REFRESH MOVE=ARROW_KEYS color=$focus_color_code Q=EXIT"
}

#保存
save_l(){
	unset name
	unset num
	name=${0%.*}.save
#	echo name=$name and $0
	while [[ -a $name ]]
	do
		num=$((${num:=0}+1))
		name=${0%.*}_$num'.save'
	done
	echo $paper > $name
	echo -en "\e[0m""\e[$((hight_real));1fPicture saved！name=$name"
	sleep 2
	echo -en $paper"\e[0m"
}

#画纸
paper_l(){
	for i in `seq 1 $total`
	do
		echo -n "\e[${y:=1};${x:=1}f""\e[48;5;15;38;5;15m▄"
		if [[ $x -lt $width ]]
		then
			((x++))
		else
			x=1
			((y++))
		fi
	done
}
if [[ ! $paper ]]
then
	paper=`paper_l`
	echo -en $paper"\e[0m"

fi
fun_tips_l

#调色板
palette_l(){
	echo -en "\e[0m"
	local focus_row=$((((focus_y+1))/2))
	for i in `seq 0 255`
	do
		if [[ $i -eq 16 || $i -eq 232 ]]
		then
			unset x
			unset y
		fi
		if [[ $i -le 15 ]]
		then
			echo -n "\e[${y:=$((focus_row+1))};${x:=$((focus_x+1))}f""\e[48;5;${i};38;5;0m "
		elif [[ $i -ge 232 ]]
		then
			echo -n "\e[${y:=$((focus_row+8))};${x:=$((focus_x+1))}f""\e[48;5;${i};38;5;0m "
		else
			echo -n "\e[${y:=$((focus_row+2))};${x:=$((focus_x+1))}f""\e[48;5;${i};38;5;0m "
		fi
		if [[ $x -lt $((focus_x+36)) ]]
		then
			((x++))
		else
			x=$((focus_x+1))
			((y++))
		fi
	done
}
palette_off_l(){
	echo -en "\e[0m"
	local focus_row=$((((focus_y+1))/2))
	for i in `seq 0 255`
	do
		if [[ $i -eq 16 || $i -eq 232 ]]
		then
			unset x
			unset y
		fi
		if [[ $i -le 15 ]]
		then
			echo -n "\e[${y:=$((focus_row+1))};${x:=$((focus_x+1))}f""\e[0m "
		elif [[ $i -ge 232 ]]
		then
			echo -n "\e[${y:=$((focus_row+8))};${x:=$((focus_x+1))}f""\e[0m "
		else
			echo -n "\e[${y:=$((focus_row+2))};${x:=$((focus_x+1))}f""\e[0m "
		fi
		if [[ $x -lt $((focus_x+36)) ]]
		then
			((x++))
		else
			x=$((focus_x+1))
			((y++))
		fi
		echo -en "\e[$((focus_row+9));$((focus_x+1))f""\e[0m " "\e[$((focus_row+9));$((focus_x+2))f""\e[0m " "\e[$((focus_row+9));$((focus_x+3))f""\e[0m "
	done
	fun_tips_l
}
palette_ref_l(){
	echo -en $palette"\e[0m"
	echo -en $(echo $focus_color|awk -F';' -v _focus=$((${palette_focus:=1}-1)) -v OFS=';' '{gsub(/^[0-9]*/,_focus,$7);print}')
	echo -en "\e[$((((((focus_y+1))/2))+9));$((focus_x+1))f""\e[0m ""\e[$((((((focus_y+1))/2))+9));$((focus_x+2))f""\e[0m ""\e[$((((((focus_y+1))/2))+9));$((focus_x+3))f""\e[0m "
}

#填色
space_l(){
#	echo space_color=$space_color
	space_color_transf=$(echo $space_color|sed 's/\\/\\\\/g')
	paper=`echo $paper|awk -F'm▄' -v OFS=m▄ -v space_color_transf=$space_color_transf -v focus_seq=$focus_seq '{gsub(/[^\s]*/,space_color_transf,$focus_seq);print}'`
	echo -en $paper"\e[0m"
}

#伪光标
focus_x=1
focus_y=1
focus_color_code=0
focus_x_max=$width
focus_y_max=$hight
open_palette=close
while :
do
	fun_tips_l
	unset key
	focus_seq=$((((((((((focus_y+1))/2))-1))*$width))+focus_x))
	focus_paper_bg_color_code=`echo $paper|awk -F'm▄' -v focus_seq=$focus_seq '{print $focus_seq}'|awk -F';' '{print $4}'`
	focus_paper_fo_color_code=`echo $paper|awk -F'm▄' -v focus_seq=$focus_seq '{print $focus_seq}'|awk -F';' '{print $7}'`
	if [[ $((focus_y%2)) -eq 0 ]]
	then
		focus_color="\e[$((focus_y/2));${focus_x}f\e[48;5;${focus_paper_bg_color_code};38;5;${focus_color_code}m▄"
		focus_color_ss="\e[$((focus_y/2));${focus_x}f\e[48;5;${focus_paper_bg_color_code};38;5;${focus_paper_fo_color_code}m▄"
		space_color="\e[$((focus_y/2));${focus_x}f\e[48;5;${focus_paper_bg_color_code};38;5;${focus_color_code}"
		palette_focus=$((focus_color_code+1))
	else
		focus_color="\e[$((((focus_y+1))/2));${focus_x}f\e[48;5;${focus_paper_fo_color_code};38;5;${focus_color_code}m▀"
		focus_color_ss="\e[$((((focus_y+1))/2));${focus_x}f\e[48;5;${focus_paper_fo_color_code};38;5;${focus_paper_bg_color_code}m▀"
		space_color="\e[$((((focus_y+1))/2));${focus_x}f\e[48;5;${focus_color_code};38;5;${focus_paper_fo_color_code}"
		palette_focus=$((focus_color_code+1))
	fi
	while [[ ! $key ]]
	do
		parity=`date +%s`
		if [[ $((${parity:-0}%2)) == 0 || $delay_ss -gt 0 ]]
		then
			echo -en $focus_color
			if [[ $delay_ss -gt 0 ]]
			then
				((delay_ss--))
			fi
		else
			echo -en $focus_color_ss
		fi
	done
	echo -en $paper"\e[0m"

#按键处理
	case $key in
		up)
			((focus_y--))
			delay_ss=100
			if [[ $focus_y -lt 1 ]]
			then
				focus_y=$focus_y_max
			fi
			;;
		down)
			((focus_y++))
			delay_ss=100
			if [[ $focus_y -gt $focus_y_max ]]
			then
				focus_y=1
			fi
			;;
		left)
			((focus_x--))
			delay_ss=100
			if [[ $focus_x -lt 1 ]]
			then
				focus_x=$focus_x_max
			fi
			;;
		right)
			((focus_x++))
			delay_ss=100
			if [[ $focus_x -gt $focus_x_max ]]
			then
				focus_x=1
			fi
			;;
		r)
			echo -e "\033c""\e[?25l"
			echo -en $paper"\e[0m"
			;;
		space)
			space_l
			;;
		s)
			save_l
			;;
		m)
			for i in `seq 0 255`
			do
			echo -en $focus_color|awk -F';' -v i=$i -v OFS=';' '{gsub(/^[0-9]*/,i,$7);print}'
			done
			;;
		p)
			if [[ $open_palette == 'close' || ! $open_palette ]]
			then
				palette=`palette_l`
				echo -en $palette"\e[0m"
				open_palette='open'
				unset key
				echo -en $(echo $focus_color|awk -F';' -v _focus=$((${palette_focus:=1}-1)) -v OFS=';' '{gsub(/^[0-9]*/,_focus,$7);print}')
				while :
				do
					case $key in
						p)
							echo -en `palette_off_l`
							echo -en $paper"\e[0m"
							open_palette='close'
							break
							;;
						space)
							focus_color_code=$((palette_focus-1))
							echo -en `palette_off_l`
							echo -en $paper"\e[0m"
							open_palette='close'
							break
							;;
						up)
							if [[ $palette_focus -le 16 ]]
							then
								palette_focus=$((palette_focus+232))
							elif [[ $palette_focus -ge 17 && $palette_focus -le 32 ]]
							then
								palette_focus=$((palette_focus-16))
							elif [[ $palette_focus -ge 33 && $palette_focus -le 40 ]]
							then
								palette_focus=$(($palette_focus+216))
							elif [[ $palette_focus -ge 41 && $palette_focus -le 52 ]]
							then
								palette_focus=$(($palette_focus+180))
							else
								palette_focus=$(($palette_focus-36))
							fi
							palette_ref_l
							;;
						down)
							if [[ $palette_focus -ge 233 && $palette_focus -le 248 ]]
							then
								palette_focus=$(($palette_focus-232))
							elif [[ $palette_focus -ge 1 && $palette_focus -le 16 ]]
							then
								palette_focus=$((palette_focus+16))
							elif [[ $palette_focus -ge 221 && $palette_focus -le 232 ]]
							then
								palette_focus=$((palette_focus-180))
							elif [[ $palette_focus -ge 249 && $palette_focus -le 256 ]]
							then
								palette_focus=$((palette_focus-216))
							else
								palette_focus=$(($palette_focus+36))
							fi
							palette_ref_l
							;;
						left)
							if [[ $palette_focus -eq 1 ]]
							then
								palette_focus=16
							elif [[ $palette_focus -eq 233 ]]
							then
								palette_focus=256
							elif [[ $((((palette_focus+19))%36)) -eq 0 ]]
							then
								palette_focus=$((palette_focus+35))
							else
								palette_focus=$((palette_focus-1))
							fi
							palette_ref_l
							;;
						right)
							if [[ $palette_focus -eq 16 ]]
							then
								palette_focus=1
							elif [[ $palette_focus -eq 256 ]]
							then
								palette_focus=233
							elif [[ $((((palette_focus-16))%36)) -eq 0 ]]
							then
								palette_focus=$((palette_focus-35))
							else
								palette_focus=$((palette_focus+1))
							fi
							palette_ref_l
							;;
					esac
					echo -en "\e[$((((((focus_y+1))/2))+9));$((focus_x+1))f""\e[48;5;0;38;5;15m$((palette_focus-1))"
					unset key
					parity=`date +%s`
					if [[ $((${parity:-0}%2)) == 0 ]]
					then
						echo -en $(echo $palette|awk -v palette_focus=${palette_focus:=1} '{print $palette_focus}')▒
					else
						echo -en $(echo $palette|awk -v palette_focus=${palette_focus:=1} '{gsub("0m","15m",$palette_focus);print $palette_focus}')▒
					fi
				done
			else
				echo -en $paper"\e[0m"
				open_palette='close'
			fi
			;;
	esac
done

#退出
my_exit_l
