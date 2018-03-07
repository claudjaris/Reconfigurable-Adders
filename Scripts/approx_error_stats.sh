#!/bin/bash
#echo "This script will calculate the error parameters of an approximate adder compared to accurate adder."

#the script expects a file named tb_output.csv (change in line 25,40,41, 150) in following format:
#a, b, a_binary, b_binary, acc_result, app_result, acc_result_binary, app_result_binary
#for improved readability of .csv you can add the columns , error, rel_error (1st line will be copied and content calculated by the script)
#the script will generate a folder (if not existent yet) and fill it with a new calculated $file.csv, $file.txt containing the metrics
#as well as 7 diagrams

#modifications of word length may have to be done partially by hand


file='ApproxResult_'$1

echo $file

width=$2

echo $width

range=2**$width
NED_range=$(( ($range-1)*($range-1) ))
sort_range=$(( $range*$range*2 ))
distr_range=$(( $range/8 ))

file_err=$file'_err'
file_rel=$file'_rel'
file_abs=$file'_abs'
file_bit=$file'_bit'
file_err_old=$file'_err_old'
file_rel_old=$file'_rel_old'

file_sort_res=$file'_sort_res'
file_acc=$file'_acc'
file_app=$file'_app'
file_acc_err=$file'_acc_err'

if [ ! -d "$file" ]; then
  mkdir $file
fi
cp tb_output.csv $file
cd $file

touch $file.txt
> $file.txt

#due to a possible change of columns that has to be used they are defined as variables
acc=5
app=6
acc_bin=7
app_bin=8
error=9
rel_error=10

#copy the very first line before proceeding with calculation
awk 'BEGIN {FS=", ";} {if(NR==1){print $0}}' tb_output.csv > $file.csv

awk 'BEGIN {FS=", "} function abs(x) {return (x<0) ? x*-1 : x} NR>1 {if($"'"$acc"'"!=0) {print $0, abs($"'"$acc"'"-$"'"$app"'") ", " abs(($"'"$acc"'"-$"'"$app"'")/$"'"$acc"'")} else {print $0, abs($"'"$acc"'"-$"'"$app"'") ", " abs($"'"$acc"'"-$"'"$app"'")}}' tb_output.csv >> $file.csv

echo "20%"

#sort for output to plot result difference
(tail -n $sort_range $file.csv | sort -k$acc -n -t, ) > $file_sort_res.csv

#max
pmax=$(awk -v max=0 'BEGIN {FS=", ";} NR>1 {if($"'"$error"'">max){max=$"'"$error"'"}}END{print max}' $file.csv)
#min
pmin=$(awk -v min=0 'BEGIN {FS=", ";} NR>1 {if($"'"$error"'"<min){min=$"'"$error"'"}}END{print min}' $file.csv)

error_range=$pmax/4

echo "Min Error = $pmin" >> $file.txt
echo "Max Error = $pmax" >> $file.txt

#min error count
awk -v min_cnt=0 'BEGIN {FS=", ";} NR>1 {if($"'"$error"'"=="'"$pmin"'"){min_cnt+=1}}END{print "Min count = " min_cnt " (" min_cnt/(NR-1)*100 "%)"}' $file.csv >> $file.txt
#max error count
awk -v max_cnt=0 'BEGIN {FS=", ";} NR>1 {if($"'"$error"'"=="'"$pmax"'"){max_cnt+=1}}END{print "Max count = " max_cnt " (" max_cnt/(NR-1)*100 "%)"}' $file.csv >> $file.txt

echo "40%"

#max correct result
awk -v cmax=0 'BEGIN {FS=", ";} NR>1 {if($"'"$acc"'">cmax){cmax=$"'"$acc"'"}}END{print "Max accurate result = " cmax}' $file.csv >> $file.txt
#min correct result
awk -v cmin=0 'BEGIN {FS=", ";} NR>1 {if($"'"$acc"'"<cmin){cmin=$"'"$acc"'"}}END{print "Min accurate result = " cmin}' $file.csv >> $file.txt

#error count
awk -v err_nr=0 'BEGIN {FS=", ";} NR>1 {if($"'"$error"'"!=0){err_nr+=1}}END{print "Error Occurences = " err_nr}' $file.csv >> $file.txt
#error probability
awk -v err_cnt=0 'BEGIN {FS=", ";} NR>1 {if($"'"$error"'"!=0){err_cnt+=1}}END{print "Error probability = " (err_cnt/(NR-1))*100 "%"}' $file.csv >> $file.txt
#average error
awk -v err_sum=0 'BEGIN {FS=", ";} NR>1 {err_sum=err_sum+$"'"$error"'"}END{print "Average error = " err_sum/(NR-1)}' $file.csv >> $file.txt
#average relative error
awk -v avg_err=0 'BEGIN {FS=", ";} function abs(x) {return (x<0) ? x*-1 : x} NR>1 {if($"'"$acc"'"!=0){avg_err+=$"'"$error"'"/abs($"'"$acc"'")}}END{print "Average relative error = " avg_err/(NR-1)}' $file.csv >> $file.txt

echo "60%"

#mean error
awk -v mean=0 'BEGIN {FS=", ";} function abs(x) {return (x<0) ? x*-1 : x} NR>1 {if($"'"$acc"'"!=0){mean+=($"'"$error"'"/$"'"$acc"'")}}END{print "Mean error = " (mean*100)/(NR-1)}' $file.csv >> $file.txt
#mse
awk -v mse=0 'BEGIN {FS=", ";} NR>1 {mse=mse+($"'"$error"'"*$"'"$error"'")}END{print "Mean squared error = " (mse/(NR-1))}' $file.csv >> $file.txt
#normalized error distance BE AWARE for signed max number = 2^(n-1) while for unsigned it is (2^n)-1
awk -v med=0 'BEGIN {FS=", ";} function abs(x) {return (x<0) ? x*-1 : x} NR>1 {med+=abs($"'"$app"'"-$"'"$acc"'")}END{print "Normalized Mean Error Distance = " ((med/(NR-1))/$NED_range)}' $file.csv >> $file.txt
#error occurences per error in percent
awk 'BEGIN {FS=", "} NR>1 {x[$"'"$error"'"]["count"]++;}END{for(y in x){print y ", " ((x[y]["count"])/(NR-1))*100}}' $file.csv > $file_err.csv

echo "80%"

if [ $width = 4 ]; then
  bit0=$(awk -v b0=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 21, 1)!=substr($"'"$app_bin"'", 21, 1)){b0+=1}}END{print (b0/(NR-1))*100}' $file.csv)
  bit1=$(awk -v b1=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 20, 1)!=substr($"'"$app_bin"'", 20, 1)){b1+=1}}END{print (b1/(NR-1))*100}' $file.csv)
  bit2=$(awk -v b2=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 19, 1)!=substr($"'"$app_bin"'", 19, 1)){b2+=1}}END{print (b2/(NR-1))*100}' $file.csv)
  bit3=$(awk -v b3=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 18, 1)!=substr($"'"$app_bin"'", 18, 1)){b3+=1}}END{print (b3/(NR-1))*100}' $file.csv)
  bit4=$(awk -v b4=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 17, 1)!=substr($"'"$app_bin"'", 17, 1)){b4+=1}}END{print (b4/(NR-1))*100}' $file.csv)
  printf " $bit0 \n $bit1 \n $bit2 \n $bit3 \n $bit4" > $file_bit.csv
else
if [ $width = 6 ]; then
  bit0=$(awk -v b0=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 21, 1)!=substr($"'"$app_bin"'", 21, 1)){b0+=1}}END{print (b0/(NR-1))*100}' $file.csv)
  bit1=$(awk -v b1=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 20, 1)!=substr($"'"$app_bin"'", 20, 1)){b1+=1}}END{print (b1/(NR-1))*100}' $file.csv)
  bit2=$(awk -v b2=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 19, 1)!=substr($"'"$app_bin"'", 19, 1)){b2+=1}}END{print (b2/(NR-1))*100}' $file.csv)
  bit3=$(awk -v b3=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 18, 1)!=substr($"'"$app_bin"'", 18, 1)){b3+=1}}END{print (b3/(NR-1))*100}' $file.csv)
  bit4=$(awk -v b4=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 17, 1)!=substr($"'"$app_bin"'", 17, 1)){b4+=1}}END{print (b4/(NR-1))*100}' $file.csv)
  bit5=$(awk -v b5=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 16, 1)!=substr($"'"$app_bin"'", 16, 1)){b5+=1}}END{print (b5/(NR-1))*100}' $file.csv)
  bit6=$(awk -v b6=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 15, 1)!=substr($"'"$app_bin"'", 15, 1)){b6+=1}}END{print (b6/(NR-1))*100}' $file.csv)
  printf " $bit0 \n $bit1 \n $bit2 \n $bit3 \n $bit4 \n $bit5 \n $bit6" > $file_bit.csv
else
if [ $width = 8 ]; then
  bit0=$(awk -v b0=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 21, 1)!=substr($"'"$app_bin"'", 21, 1)){b0+=1}}END{print (b0/(NR-1))*100}' $file.csv)
  bit1=$(awk -v b1=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 20, 1)!=substr($"'"$app_bin"'", 20, 1)){b1+=1}}END{print (b1/(NR-1))*100}' $file.csv)
  bit2=$(awk -v b2=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 19, 1)!=substr($"'"$app_bin"'", 19, 1)){b2+=1}}END{print (b2/(NR-1))*100}' $file.csv)
  bit3=$(awk -v b3=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 18, 1)!=substr($"'"$app_bin"'", 18, 1)){b3+=1}}END{print (b3/(NR-1))*100}' $file.csv)
  bit4=$(awk -v b4=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 17, 1)!=substr($"'"$app_bin"'", 17, 1)){b4+=1}}END{print (b4/(NR-1))*100}' $file.csv)
  bit5=$(awk -v b5=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 16, 1)!=substr($"'"$app_bin"'", 16, 1)){b5+=1}}END{print (b5/(NR-1))*100}' $file.csv)
  bit6=$(awk -v b6=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 15, 1)!=substr($"'"$app_bin"'", 15, 1)){b6+=1}}END{print (b6/(NR-1))*100}' $file.csv)
  bit7=$(awk -v b7=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 14, 1)!=substr($"'"$app_bin"'", 14, 1)){b7+=1}}END{print (b7/(NR-1))*100}' $file.csv)
  bit8=$(awk -v b8=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 13, 1)!=substr($"'"$app_bin"'", 13, 1)){b8+=1}}END{print (b8/(NR-1))*100}' $file.csv)
  printf " $bit0 \n $bit1 \n $bit2 \n $bit3 \n $bit4 \n $bit5 \n $bit6 \n $bit7 \n $bit8" > $file_bit.csv
else
if [ $width = 10 ]; then
  bit0=$(awk -v b0=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 21, 1)!=substr($"'"$app_bin"'", 21, 1)){b0+=1}}END{print (b0/(NR-1))*100}' $file.csv)
  bit1=$(awk -v b1=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 20, 1)!=substr($"'"$app_bin"'", 20, 1)){b1+=1}}END{print (b1/(NR-1))*100}' $file.csv)
  bit2=$(awk -v b2=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 19, 1)!=substr($"'"$app_bin"'", 19, 1)){b2+=1}}END{print (b2/(NR-1))*100}' $file.csv)
  bit3=$(awk -v b3=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 18, 1)!=substr($"'"$app_bin"'", 18, 1)){b3+=1}}END{print (b3/(NR-1))*100}' $file.csv)
  bit4=$(awk -v b4=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 17, 1)!=substr($"'"$app_bin"'", 17, 1)){b4+=1}}END{print (b4/(NR-1))*100}' $file.csv)
  bit5=$(awk -v b5=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 16, 1)!=substr($"'"$app_bin"'", 16, 1)){b5+=1}}END{print (b5/(NR-1))*100}' $file.csv)
  bit6=$(awk -v b6=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 15, 1)!=substr($"'"$app_bin"'", 15, 1)){b6+=1}}END{print (b6/(NR-1))*100}' $file.csv)
  bit7=$(awk -v b7=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 14, 1)!=substr($"'"$app_bin"'", 14, 1)){b7+=1}}END{print (b7/(NR-1))*100}' $file.csv)
  bit8=$(awk -v b8=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 13, 1)!=substr($"'"$app_bin"'", 13, 1)){b8+=1}}END{print (b8/(NR-1))*100}' $file.csv)
  bit9=$(awk -v b9=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 12, 1)!=substr($"'"$app_bin"'", 12, 1)){b9+=1}}END{print (b9/(NR-1))*100}' $file.csv)
  bit10=$(awk -v b10=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 11, 1)!=substr($"'"$app_bin"'", 11, 1)){b10+=1}}END{print (b10/(NR-1))*100}' $file.csv)
  printf " $bit0 \n $bit1 \n $bit2 \n $bit3 \n $bit4 \n $bit5 \n $bit6 \n $bit7 \n $bit8 \n $bit9 \n $bit10" > $file_bit.csv
else
if [ $width = 12 ]; then
  bit0=$(awk -v b0=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 21, 1)!=substr($"'"$app_bin"'", 21, 1)){b0+=1}}END{print (b0/(NR-1))*100}' $file.csv)
  bit1=$(awk -v b1=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 20, 1)!=substr($"'"$app_bin"'", 20, 1)){b1+=1}}END{print (b1/(NR-1))*100}' $file.csv)
  bit2=$(awk -v b2=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 19, 1)!=substr($"'"$app_bin"'", 19, 1)){b2+=1}}END{print (b2/(NR-1))*100}' $file.csv)
  bit3=$(awk -v b3=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 18, 1)!=substr($"'"$app_bin"'", 18, 1)){b3+=1}}END{print (b3/(NR-1))*100}' $file.csv)
  bit4=$(awk -v b4=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 17, 1)!=substr($"'"$app_bin"'", 17, 1)){b4+=1}}END{print (b4/(NR-1))*100}' $file.csv)
  bit5=$(awk -v b5=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 16, 1)!=substr($"'"$app_bin"'", 16, 1)){b5+=1}}END{print (b5/(NR-1))*100}' $file.csv)
  bit6=$(awk -v b6=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 15, 1)!=substr($"'"$app_bin"'", 15, 1)){b6+=1}}END{print (b6/(NR-1))*100}' $file.csv)
  bit7=$(awk -v b7=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 14, 1)!=substr($"'"$app_bin"'", 14, 1)){b7+=1}}END{print (b7/(NR-1))*100}' $file.csv)
  bit8=$(awk -v b8=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 13, 1)!=substr($"'"$app_bin"'", 13, 1)){b8+=1}}END{print (b8/(NR-1))*100}' $file.csv)
  bit9=$(awk -v b9=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 12, 1)!=substr($"'"$app_bin"'", 12, 1)){b9+=1}}END{print (b9/(NR-1))*100}' $file.csv)
  bit10=$(awk -v b10=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 11, 1)!=substr($"'"$app_bin"'", 11, 1)){b10+=1}}END{print (b10/(NR-1))*100}' $file.csv)
  bit11=$(awk -v b11=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 10, 1)!=substr($"'"$app_bin"'", 10, 1)){b11+=1}}END{print (b11/(NR-1))*100}' $file.csv)
  bit12=$(awk -v b12=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 9, 1)!=substr($"'"$app_bin"'", 9, 1)){b12+=1}}END{print (b12/(NR-1))*100}' $file.csv)
  printf " $bit0 \n $bit1 \n $bit2 \n $bit3 \n $bit4 \n $bit5 \n $bit6 \n $bit7 \n $bit8 \n $bit9 \n $bit10 \n $bit11 \n $bit12" > $file_bit.csv
else
if [ $width = 16 ]; then
  bit0=$(awk -v b0=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 21, 1)!=substr($"'"$app_bin"'", 21, 1)){b0+=1}}END{print (b0/(NR-1))*100}' $file.csv)
  bit1=$(awk -v b1=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 20, 1)!=substr($"'"$app_bin"'", 20, 1)){b1+=1}}END{print (b1/(NR-1))*100}' $file.csv)
  bit2=$(awk -v b2=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 19, 1)!=substr($"'"$app_bin"'", 19, 1)){b2+=1}}END{print (b2/(NR-1))*100}' $file.csv)
  bit3=$(awk -v b3=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 18, 1)!=substr($"'"$app_bin"'", 18, 1)){b3+=1}}END{print (b3/(NR-1))*100}' $file.csv)
  bit4=$(awk -v b4=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 17, 1)!=substr($"'"$app_bin"'", 17, 1)){b4+=1}}END{print (b4/(NR-1))*100}' $file.csv)
  bit5=$(awk -v b5=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 16, 1)!=substr($"'"$app_bin"'", 16, 1)){b5+=1}}END{print (b5/(NR-1))*100}' $file.csv)
  bit6=$(awk -v b6=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 15, 1)!=substr($"'"$app_bin"'", 15, 1)){b6+=1}}END{print (b6/(NR-1))*100}' $file.csv)
  bit7=$(awk -v b7=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 14, 1)!=substr($"'"$app_bin"'", 14, 1)){b7+=1}}END{print (b7/(NR-1))*100}' $file.csv)
  bit8=$(awk -v b8=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 13, 1)!=substr($"'"$app_bin"'", 13, 1)){b8+=1}}END{print (b8/(NR-1))*100}' $file.csv)
  bit9=$(awk -v b9=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 12, 1)!=substr($"'"$app_bin"'", 12, 1)){b9+=1}}END{print (b9/(NR-1))*100}' $file.csv)
  bit10=$(awk -v b10=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 11, 1)!=substr($"'"$app_bin"'", 11, 1)){b10+=1}}END{print (b10/(NR-1))*100}' $file.csv)
  bit11=$(awk -v b11=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 10, 1)!=substr($"'"$app_bin"'", 10, 1)){b11+=1}}END{print (b11/(NR-1))*100}' $file.csv)
  bit12=$(awk -v b12=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 9, 1)!=substr($"'"$app_bin"'",  9, 1)){b12+=1}}END{print (b12/(NR-1))*100}' $file.csv)
  bit13=$(awk -v b13=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 8, 1)!=substr($"'"$app_bin"'",  8, 1)){b13+=1}}END{print (b13/(NR-1))*100}' $file.csv)
  bit14=$(awk -v b14=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 7, 1)!=substr($"'"$app_bin"'",  7, 1)){b14+=1}}END{print (b14/(NR-1))*100}' $file.csv)
  bit15=$(awk -v b15=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 6, 1)!=substr($"'"$app_bin"'",  6, 1)){b15+=1}}END{print (b15/(NR-1))*100}' $file.csv)
  bit16=$(awk -v b16=0 'BEGIN {FS=", "} NR>1 {if (substr($"'"$acc_bin"'", 5, 1)!=substr($"'"$app_bin"'",  5, 1)){b16+=1}}END{print (b16/(NR-1))*100}' $file.csv)
  printf " $bit0 \n $bit1 \n $bit2 \n $bit3 \n $bit4 \n $bit5 \n $bit6 \n $bit7 \n $bit8 \n $bit9 \n $bit10 \n $bit11 \n $bit12 \n $bit13 \n $bit14 \n $bit15 \n $bit16" > $file_bit.csv
fi
fi
fi
fi
fi
fi

echo 'Start plotting...'

#gnuplot has to be used, necessary commands:
gnuplot -persist <<PLOT
#set ylabel "Error"
set datafile separator ","
set term postscript eps enhanced color font 'Helvetica,10'
set boxwidth 1 absolute

set title "Accurate Result"
set ylabel "Result Output"
set xlabel "Sample Number"
set output "$file_acc.eps"
plot '$file_sort_res.csv' using $acc with lines title "Accurate Result"

set title "Approximate VS Accurate Result"
set output "$file_app.eps"
plot '$file_sort_res.csv' using $app with lines lt rgb "blue" title "Approximate Result", '$file_sort_res.csv' using $acc with lines lt rgb "red" title "Accurate Result"

set title "Accurate Output And Error"
set output "$file_acc_err.eps"
plot '$file_sort_res.csv' using $acc with lines title "Accurate Result", '$file_sort_res.csv' using $error with lines title "Absolute Error"

set boxwidth 0.8 absolute
set style fill solid 1.0
set xtics 1

set title "Error Probability From LSB to MSB"
set xlabel "Bit position"
set ylabel "Percent"
set output "$file_bit.eps"
plot '$file_bit.csv' with boxes notitle

set xtics $error_range

set title "Error Distribution"
set xlabel "Absolute Error"
set ylabel "Percent"
set output "$file_err.eps"
plot "$file_err.csv" with boxes notitle

set key autotitle columnhead
unset key

set xrange [-1:$range]
set yrange [-1:$range]
set xtics $distr_range
set ytics $distr_range

set palette model RGB
set palette defined ( 0 "green", 1 "white", 2 "yellow", 3 "orange", 4 "red")

set output "$file_rel.eps"
set title "Relative Error Distribution"
set xlabel "Input Word A"
set ylabel "Input Word B"
set view map
set size ratio .9
set object 1 rect from graph 0, graph 0 to graph 1, graph 1 back
set object 1 rect fc rgb "white" fillstyle solid 1.0
splot "$file.csv" using 1:2:$rel_error with points pointtype 5 pointsize 51.2/$range palette linewidth 30

set output "$file_abs.eps"
set title "Absolute Error Distribution"
splot "$file.csv" using 1:2:$error with points pointtype 5 pointsize 51.2/$range palette linewidth 30

quit
PLOT

rm tb_output.csv

echo "100%"
