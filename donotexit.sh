export PS1='> '

while true
do
	rand=$(( ( RANDOM % 30 )  + 1 ))
	if (( rand % 30 == 0 )); then
		echo -e "\e[1;31m YOU CANNOT EXIT \e[0m"
		echo -e "\e[1;31m YOU CANNOT EXIT \e[0m"
		echo -e "\e[1;31m YOU CANNOT EXIT \e[0m"
	else
    	echo -e "\e[1;31m Do not exit \e[0m"
    fi
done
