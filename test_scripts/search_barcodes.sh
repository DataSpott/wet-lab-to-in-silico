#!/bin/bash
filename=$1
while read -r line; do
echo $line
done < <(grep NB $filename| grep Barcodekit -v)

