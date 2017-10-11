#!/bin/bash

DATE=2017-06-30
invoice_number=1000

echo invoice_number,invoice_date,account_id,salesperson_id

(( i = 0 ))
while (( i < 80 ))
do
    (( i = i + 1 ))
    DATE=`./nextdate $DATE`

    x=$(( RANDOM % 750 ))
    n=`echo $x | awk '{ print $1^(1/4) - 1.0 }' | cut -d. -f1`

    # echo $i $DATE $n

    while (( n > 0 ))
    do
        (( n = n - 1 ))
        (( invoice_number = invoice_number + 1 ))
        generate-one-invoice.sh $invoice_number $DATE
    done

done