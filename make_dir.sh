#!/bin/bash
filename=$1
while read -r line; do
mkdir -p $(echo "$line" | cut -c5-)
done < <(grep NB $filename| grep Barcodekit -v)
