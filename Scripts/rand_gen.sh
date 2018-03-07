#!/bin/bash
# create random ordered input data of bit width n

n=$1
nn=$((2**$n))
nnn=$(($nn-1))

> tb_inputA1.txt
nr=($(seq 0 $nnn | shuf -n $nn))
#echo "${nr[@]}"
for (( i=0; i<=$nn; i++ ))
do
  echo "${nr[$i]}" >> tb_inputA1.txt
done

> tb_inputA2.txt
nr=($(seq 0 $nnn | shuf -n $nn))
#echo "${nr[@]}"
for (( i=0; i<=$nn; i++ ))
do
  echo "${nr[$i]}" >> tb_inputA2.txt
done

> tb_inputA3.txt
nr=($(seq 0 $nnn | shuf -n $nn))
#echo "${nr[@]}"
for (( i=0; i<=$nn; i++ ))
do
  echo "${nr[$i]}" >> tb_inputA3.txt
done

> tb_inputB1.txt
nr=($(seq 0 $nnn | shuf -n $nn))
#echo "${nr[@]}"
for (( i=0; i<=$nn; i++ ))
do
  echo "${nr[$i]}" >> tb_inputB1.txt
done

> tb_inputB2.txt
nr=($(seq 0 $nnn | shuf -n $nn))
#echo "${nr[@]}"
for (( i=0; i<=$nn; i++ ))
do
  echo "${nr[$i]}" >> tb_inputB2.txt
done

> tb_inputB3.txt
nr=($(seq 0 $nnn | shuf -n $nn))
#echo "${nr[@]}"
for (( i=0; i<=$nn; i++ ))
do
  echo "${nr[$i]}" >> tb_inputB3.txt
done
