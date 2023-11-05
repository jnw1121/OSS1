#!/bin/bash

echo "User Name: JeongJinWoo" 
echo "Student Number: 12223817" 

echo [ MENU ]
echo 1. Get the data of the movie identified by a specific ''\'movie id''\' from ''\'u.item''\'
echo 2. Get the data of action genre movies from ''\'u.item''\'
echo 3. Get the average ''\'rating''\' of the movie identified by specific 'movie id' from ''\'u.data''\'
echo 4. Delete the ''\'IMDb URL''\' from ''\'u.item''\'
echo 5. Get the data about users from ''\'u.user''\'
echo 6. Modify the format of ''\'release date''\' in ''\'u.item''\'
echo 7. Get the data of movies rated by a specific ''\'user id''\' from ''\'u.data''\'
echo 8. Get the average ''\'rating''\' of movies rated by users with 'age' between 20 and 29 and ''\'occupation''\' as ''\'programmer''\'
echo 9. Exit

while true
do

read -p "Enter your choice [ 1~9 ] : " choice

if [ $choice == 1 ]
then
	read -p "Please enter 'movie id'(1~1682): " id
	cat $1 | awk -v idtemp="$id" -F\| '$1==idtemp {print $0}'

elif [ $choice == 2 ]
then
	read -p "Do you want to get the data of 'action' genre movies from 'u.item'? (y/n): " ans
	if [ $ans == "y" ]
	then
		cat $1 | awk -F\| '$7==1{print $1,$2; count++} count >= 10 {exit}'
	fi


elif [ $choice == 3 ]
then
	read -p "Please enter the 'movie id' (1~1682): " id
	cat $2 | awk -v idtemp=$id '$2==idtemp { sum += $3; cnt++ } END { average =  sum / cnt; printf "%.5f\n", average }'
elif [ $choice == 4 ]
then
	read -p "Do you want to delete the 'IMDB URL' from 'u.item'? (y/n): " ans
	if [ $ans == "y" ]
	then
		cat $1 | sed 's/http:\/\/us.imdb.com\/[^|]*//g' | head -n 10
	fi
elif [ $choice == 5 ]
then
	read -p "Do you want to get the data about users from 'u.user'? (y/n): " ans
	if [ $ans == "y" ]
	then
		cat $3 | sed -E 's/^([0-9]+)\|([0-9]+)\|([MF])\|([^|]+)\|.*/user \1 is \2 years old \3 \4/' | sed -E 's/M/male/;s/F/female/' | head -n 10	
	fi
elif [ $choice == 6 ]
then 
	read -p "Do you want to Modify the format of 'release data' in 'u.item'? (y/n): " ans
	if [ $ans == "y" ]
	then
  		cat $1 | sed 's/\([0-9]\{2\}\)-\([a-zA-Z]\{3\}\)-\([0-9]\{4\}\)/\3\2\1/g' | sed -E 's/Jan/01/g;s/Feb/02/g;s/Mar/03/g;s/Apr/04/g;s/May/05/g;s/Jun/06/g;s/Jul/07/g;s/Aug/08/g;s/Sep/09/g;s/Oct/10/g;s/Nov/11/g;s/Dec/12/g;' | tail -n 10
       	fi

elif [ $choice == 7 ]
then
	read -p "Please enter the 'user id' (1~943): " id
	cat $2 | awk -v idtemp=$id '$1==idtemp {movie[i++]=$2;} END {n = asort(movie); for (i=1; i<=n; i++) print movie[i]} ' > usermovie.txt
	movie_id=($(<"usermovie.txt"))
	arrsize="${#movie_id[@]}"
	cnt=1
	for mv in "${movie_id[@]}"
	do
		if [ $cnt == $arrsize ]
		then
			printf "%s\n\n" $mv
		else
			printf "%s|" $mv
		fi
		cnt=$(( cnt+1 ))
	done

	n=0
	while (( $n < 10 ))
	do
		cat $1 | awk -v mvid="${movie_id[$n]}" -F\| '$1==mvid{print $1 "|" $2}'
		n=$(( n+1 ))
	done

	rm usermovie.txt

elif [ $choice == 8 ]
then
	read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'? (y/n): " ans
	if [ $ans == "y" ]
	then
		cat $3 | awk -F \| '$2>=20&&$2<=29&&$4=="programmer"{print $1}' > programmerUser.txt
		programmerId=($(<"programmerUser.txt"))
		programmersize="${#programmerId[@]}"
		n=0
		while (( $n < $programmersize ))
		do
			cat $2 | awk -v pgid="${programmerId[$n]}" '$1==pgid{print $2 "\t" $3}' >> m.rate
			n=$(( n+1 ))
		done

		cnt=1
		while (( $cnt != 1683 ))
		do
			cat m.rate | awk -v mvid=$cnt  '$1==mvid{sum += $2; count++ } END {if(sum != 0) print mvid,sum/count }'  
			cnt=$(( cnt+1 ))
		done
		
		rm m.rate
		rm programmerUser.txt
		
	fi 

elif [ $choice == 9 ]
then
	echo Bye!
	break

fi
done
