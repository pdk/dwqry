#!/bin/bash

invoice_number=$1

lines=$(( ( RANDOM % 14 )  + 1 ))

while (( lines > 0 ))
do
    (( lines = lines - 1 ))

    product_line=$(( ( RANDOM % 99 )  + 2 ))
    item_count=$(( ( RANDOM % 20 )  + 1 ))

    head -$product_line products.csv | tail -1 | csvfields | while read product_id retail_price
    do
        echo $invoice_number,$product_id,$item_count,$retail_price
    done
done
