process combiner {
    publishDir "${params.output}/", mode: 'copy'

    input:
        val(sampleNumber) //eventuell hier "each" verwenden statt "val" oder "tuple"
        val(kitInfo)
        tuple val(name), path(dir)

    output:
        tuple val("${name}"), path("*")//path("/\$sample_number/*.gz"), path("/\$sample_number/*.txt") 

    script:
    """
    sample_barcode=\$(echo "${sampleNumber}" | cut -f1 -d"#" |grep -o -E '[0-9]+')
    sample_number=\$(echo "${sampleNumber}" |  cut -f2 -d"#")
    fastq_barcode=\$(echo ${name} | grep -o -E '[0-9]+')
    
    if [[ "\$sample_barcode" == "\$fastq_barcode" ]]
    then
        mkdir ./"\$sample_number"
        for elements in ${kitInfo}; do
            echo "\$elements" | tr -d "[]"  >> "\$sample_number"/runInfo.txt
        done
        cp -r ${dir} "\$sample_number"/
    fi
    """
}