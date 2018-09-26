#!/bin/bash

echo -e "\n GOOD \n" > testGood.txt

for (( i=1; i<=23; i++))
	do
		echo -e "\n TEST"$i >> testGood.txt
		./tiger ../tests/good/test$i.tig >> testGood.txt
	done

echo -e "\n TYPE \n" > testType.txt

for (( i=1; i<=34; i++))
	do
		echo -e "\n TEST"$i >> testType.txt
		./tiger ../tests/type/test$i.tig >> testType.txt
	done

