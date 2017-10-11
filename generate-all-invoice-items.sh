#!/bin/bash

echo invoice_number,product_id,item_count,retail_price

tail +2 invoices.csv | cut -d, -f1 | while read invoice_number
do
    generate-invoice-items.sh $invoice_number
done
