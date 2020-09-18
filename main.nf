#!/usr/bin/env nextflow

//display a help-msgs
if (params.help) { exit 0, helpMSG() }

//xxxxxxxxxxxxxx//
//***Inputs***//
//xxxxxxxxxxxxxx//

// eventually define the paths directly, because we want to execute it in the
// same directory all the time

// fast5 input
if (params.fast5) { fast5_input_ch = Channel
    fromPath( params.fast5, checkIfExists: true)
    .map{ file -> tuple(file.simpleName, file)}
}

// runInfo input
if (params.runInfo) { runInfo_ch = Channel
    fromPath( params.runInfo, checkIfExists: true)
}

// outputDirectory
if (params.output) { output_ch = Channel
    
}

//xxxxxxxxxxxxxx//
//***Modules***//
//xxxxxxxxxxxxxx//

include { guppy_gpu } from './modules/guppy'


//xxxxxxxxxxxxxx//
//***CheckBarcodes***//
//xxxxxxxxxxxxxx//

// check if barcodes are given in runInfo & create a file if yes
process barcode_check {

    input:
        file runInfo from runInfo_ch
    
    output:
        file barcode_test into barcode_check_ch

    """
    if grep -q Barcodekit $runInfo; then echo "found" > barcode_test.txt; fi 
    """
}

// check for existence of the file created above and setup params.single if false
if (checkIfExists(./barcode_test.txt) == false) {
    params.single}
// would the command in this way be possible? Or would it otherwise be possible to
// compare the output from 'print barcode_test.txt' to a string like 'found' (in 
// this case writing 'not found' in the file otherwise)?

//xxxxxxxxxxxxxx//
//***Basecalling***//
//xxxxxxxxxxxxxx//

workflow basecalling_wf {
    take:
        dir_input
    main:

        guppy_gpu(dir_input)

        if (params.single) { fastq_channel = guppy_gpu.out }

        else { fastq_channel = guppy_gpu.out
                            .map { it -> it[1] }
                            .flatten()
                            .map { it -> [ it.simpleName, it ] }

    emit:
        fastq_channel
}


//xxxxxxxxxxxxxx//
//***getBarcodes***//
//xxxxxxxxxxxxxx//

if (!params.single) {
    process searchBarcodes {
        
        input:
            file runInfo_file from runInfo_ch
        
        output:
            barcode_file into barcode_ch
        
        """
        grep NB $runInfo_file | grep -v Barcodekit > barcode_file
        """
    }
}


//xxxxxxxxxxxxxx//
//***createSampleDirs***//
//xxxxxxxxxxxxxx//

process sample_dir_creation {

    input:
        file barcode_file from barcode_ch
        path output from output_ch
    
    // shell-command to read the barcode-file and make directories for all samples
    // in the corresponding subdirectories (& deleting the barcode)
    """
    while read line; do mkdir -p $output/fast5/$(echo "$line" | cut -c5-); done < $barcode_file
    while read line; do mkdir -p $output/fastq/$(echo "$line" | cut -c5-); done < $barcode_file
    """
}

// how does the program know from which channel the results come 
// (that are the result of the whole program)?