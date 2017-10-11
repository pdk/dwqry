#!/bin/bash

invoice_number=$1
invoice_date=$2

account_line=$(( ( RANDOM % 99 )  + 2 ))
salesperson_line=$(( ( RANDOM % 99 )  + 2 ))

account_id=`head -$account_line accounts.csv | tail -1 | cut -d, -f1`
salesperson_id=`head -$salesperson_line salespeople.csv | tail -1 | cut -d, -f1`

echo $invoice_number,$invoice_date,$account_id,$salesperson_id
