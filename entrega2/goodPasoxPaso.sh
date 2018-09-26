#!/bin/bash

echo -e "\n GOOD PASOXPASO \n" > testGoodPasoxPaso.txt

for (( i=1; i<=3; i++))
	do
			echo "**********************************************";
			echo " TEST "$i;
			./tiger ../tests/good/test$i.tig -inter;
			echo "**************** TEST $i *********************";
			echo -e "\n TEST "$i >> testGoodPasoxPaso.txt;
			./tiger ../tests/good/test$i.tig -inter >> testGoodPasoxPaso.txt;
			read -p "Pulse para continuar....";			
	done

for (( i=4; i<=5; i++))
	do
			echo "**********************************************";
			echo " TEST "$i;
			echo "ESTE TEST NO TERMINA!"
			echo "**************** TEST $i *********************";
			echo -e "\n TEST "$i >> testGoodPasoxPaso.txt;
			echo -e "\n ESTE TEST NO TERMINA!" >> testGoodPasoxPaso.txt;
			read -p "Pulse para continuar....";
	done
for (( i=6; i<=23; i++))
	do
			echo "**********************************************";
			echo " TEST "$i;
			./tiger ../tests/good/test$i.tig -inter;
			echo "**************** TEST $i *********************";
			echo -e "\n TEST "$i >> testGoodPasoxPaso.txt;
			./tiger ../tests/good/test$i.tig -inter >> testGoodPasoxPaso.txt;
			read -p "Pulse para continuar....";			
	done


