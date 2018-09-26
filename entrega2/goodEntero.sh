#!/bin/bash

echo -e "\n GOOD ENTERO \n" > testGood.txt

for (( i=1; i<=3; i++))
	do
			echo -e "\n **********************************************">> testGood.txt;
			echo -e "\n TEST "$i >> testGood.txt;
			./tiger ../tests/good/test$i.tig -inter >> testGood.txt;
	done

for (( i=4; i<=5; i++))
	do
			echo -e "\n **********************************************">> testGood.txt;
			echo -e "\n TEST "$i >> testGood.txt;
			echo -e "\n ESTE TEST NO TERMINA!" >> testGood.txt;
	done

for (( i=6; i<=23; i++))
	do
			echo -e "\n **********************************************">> testGood.txt;
			echo -e "\n TEST "$i >> testGood.txt;
			./tiger ../tests/good/test$i.tig -inter >> testGood.txt;
	done


