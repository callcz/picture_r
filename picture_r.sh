#!/bin/bash
#▀
#▄
#█
################################
	if [[ -z `ps -ef|grep picture.sh|grep bash|awk '{print $2}'` ]]
	then
		echo Plase run \"./picture.sh\" .
		my_exit_l
	fi
################################
echo -e "\033c""\e[?25l"

my_exit_l() {
	echo -en "\E[0m""\e[48;1f""\033[?25h"
	exit
}
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

width=64
hight=64
hight_real=$((hight/2))
total=$((width*hight_real))

#功能键提示
fun_tips_l(){
	local begin=$((hight_real+1))
	printf "\e[$begin;1H""\e[0m"'P=PALETTE SPACE=SELECT/DRAW S=SAVE M=FOCUS R=REFRESH'
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
if [[ ! $1 ]]
then
	paper=`paper_l`
	echo -en $paper"\e[0m"
elif [[ $1 == '--help' || $1 == '-h' ]]
then
	echo head -n2 $$
elif [[ ! -a $1 ]]
then
	echo "$1 File does not exist !"
	my_exit_l
else
	paper=`cat $1`
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
			echo -n "\e[${y:=$((focus_row+8))};${x:=$((focus_x+1))}f""\e[48;5;${i};38;5;0m "
		elif [[ $i -ge 232 ]]
		then
			echo -n "\e[${y:=$((focus_row+7))};${x:=$((focus_x+1))}f""\e[48;5;${i};38;5;0m "
		else
			echo -n "\e[${y:=$((focus_row+1))};${x:=$((focus_x+1))}f""\e[48;5;${i};38;5;0m "
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
			echo -n "\e[${y:=$((focus_row+8))};${x:=$((focus_x+1))}f""\e[0m "
		elif [[ $i -ge 232 ]]
		then
			echo -n "\e[${y:=$((focus_row+7))};${x:=$((focus_x+1))}f""\e[0m "
		else
			echo -n "\e[${y:=$((focus_row+1))};${x:=$((focus_x+1))}f""\e[0m "
		fi
		if [[ $x -lt $((focus_x+36)) ]]
		then
			((x++))
		else
			x=$((focus_x+1))
			((y++))
		fi
	done
	fun_tips_l
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
focus_color_code=36
focus_x_max=$width
focus_y_max=$hight
open_palette=close
while :
do
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
		if [[ $((${parity:-0}%2)) == 0 ]]
		then
			echo -en $focus_color
		else
			echo -en $focus_color_ss
		fi
	done
	echo -en $paper"\e[0m"
	#按键处理
	case $key in
		up)
			((focus_y--))
			if [[ $focus_y -lt 1 ]]
			then
				focus_y=$focus_y_max
			fi
			;;
		down)
			((focus_y++))
			if [[ $focus_y -gt $focus_y_max ]]
			then
				focus_y=1
			fi
			;;
		left)
			((focus_x--))
			if [[ $focus_x -lt 1 ]]
			then
				focus_x=$focus_x_max
			fi
			;;
		right)
			((focus_x++))
			if [[ $focus_x -gt $focus_x_max ]]
			then
				focus_x=1
			fi
			;;
		r)
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
				while :
				do
					if [[ $key == p || $key == ecs ]]
					then
						echo -en `palette_off_l`
						echo -en $paper"\e[0m"
						open_palette='close'
						break
					elif [[ $key == space ]]
					then
						focus_color_code=$((palette_focus-1))
						echo -en `palette_off_l`
						echo -en $paper"\e[0m"
						open_palette='close'
						break
					elif [[ $key == up ]]
					then
						if [[ $((palette_focus-36)) -gt 0 ]]
						then
							palette_focus=$((palette_focus-36))
							echo -en $palette"\e[0m"
						else
							palette_focus=$((palette_focus+220))
							echo -en $palette"\e[0m"
						fi
					elif [[ $key == down ]]
					then
						if [[ $((palette_focus+36)) -le 256 ]]
						then
							palette_focus=$((palette_focus+36))
							echo -en $palette"\e[0m"
						else
							palette_focus=$((palette_focus-220))
							echo -en $palette"\e[0m"
						fi
					elif [[ $key == left ]]
					then
						if [[ $((palette_focus-1)) -gt 0 ]]
						then
							palette_focus=$((palette_focus-1))
							echo -en $palette"\e[0m"
						else
							palette_focus=256
							echo -en $palette"\e[0m"
						fi
					elif [[ $key == right ]]
					then
						if [[ $((palette_focus+1)) -le 256 ]]
						then
							palette_focus=$((palette_focus+1))
							echo -en $palette"\e[0m"
						else
							palette_focus=1
							echo -en $palette"\e[0m"
						fi
					fi
#					echo -en "\e[40;1f""\e[0m"palette_focus=$palette_focus
					unset key
					parity=`date +%s`
					if [[ $((${parity:-0}%2)) == 0 ]]
					then
						echo -en $(echo $palette|awk -v palette_focus=${palette_focus:=1} '{print $palette_focus}')▒
						echo -en $(echo $focus_color|awk -F';' -v _focus=$((${palette_focus:=1}-1)) -v OFS=';' '{gsub(/^[0-9]*/,_focus,$7);print}')
					else
						echo -en $(echo $palette|awk -v palette_focus=${palette_focus:=1} '{gsub(0m,15m,$palette_focus);print $palette_focus}')▒
						echo -en $focus_color
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
