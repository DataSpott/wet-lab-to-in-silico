# maybe a cae for -gz makes sense

for x in barcode06/*.fastq ; do sed -n '1~4p' $x | cut -f1 -d" " | tr -d "@" >> barcode06_ids.txt ; done

# nanozoo/ont-fast5-api:3.1.5--c9dbec6

fast5_subset --input fast5/ --filename_base barcode06 --save_path fast5_demultipled \
    --read_id_list barcode06_ids.txt --recursive --batch_size 100000  --threads 20

```
