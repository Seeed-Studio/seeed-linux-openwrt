#!/bin/bash 
# 1,file name
# 2,Use a special string to find the corresponding line
# 3,new line 
insert_line () {
	#echo $1
	#echo $2
	#echo $3
	d_line=$(grep -n  "$2"  $1 |  awk -F  ":" '{print $1}')
	if [ ! "${d_line}" ] ; then
		echo "cannt fine the special string"
	else
		sed -i "${d_line}i$3" $1
	fi
}

# 1,file name
# 2,Use a special string to find the corresponding line
delete_line () {
	d_line=$(grep -n  "$2"  $1 |  awk -F  ":" '{print $1}')
	if [ ! "${d_line}" ] ; then
		echo "cannt fine the special string"
	else
		sed -i "${d_line}d" $1
	fi
}

