process combiner {
    publishDir "${params.output}/", mode: 'copy'

    input:
        val(sample) //eventuell hier "each" verwenden statt "val" oder "tuple"
        tuple val(name), path(dir)

    output:
        tuple val(sample_number), path(dir_path)

    script:
    """
    echo ${sample}
    echo ${name}
    echo ${dir}
    sample_barcode=`echo ${sample} | cut -f1 -d"#" |grep -o -E '[0-9]+'`
    echo \$sample_barcode
    sample_number=`echo ${sample} |  cut -f2 -d"#"`
    echo \$sample_number
    fastq_barcode=`echo ${name} | grep -o -E '[0-9]+'`
    echo \$fastq_barcode

    if [\$sample_barcode = \$fastq_barcode]
    then
        echo \$sample_barcode
        mkdir \$sample_number
        cp -r ${dir} /\$sample_number
        dir_path="\$PWD/\$sampe_number"
    fi
    """
}