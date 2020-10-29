#!/usr/bin/env nextflow
nextflow.preview.dsl=2

//display a help-msgs
//if (params.help) { exit 0, helpMSG() }

//xxxxxxxxxxxxxx//
//***Inputs***//
//xxxxxxxxxxxxxx//

// eventually define the paths directly, because we want to execute it in the
// same directory all the time

// fast5 input
//if (params.inDir) {
//    inDir_ch = Channel
//    .fromPath( params.inDir, checkIfExists: true)
//    .view()
//}

if (params.inDir) { inDir_ch = Channel
        .fromPath( params.inDir, checkIfExists: true, type: 'dir')
        .map { file -> tuple(file.name, file) }
        .view()
    }
// outputDirectory
//if (params.output) { output_ch = Channel}


//xxxxxxxxxxxxxx//
//***Modules***//
//xxxxxxxxxxxxxx//

include { guppy_gpu } from './subworkflows/guppy/guppy'


//xxxxxxxxxxxxxx//
//***process runInfo***//
//xxxxxxxxxxxxxx//

runInfo_location = [params.inDir, 'run_info.txt'].join()

def runInfoList = new File(runInfo_location).text.readLines()
runInfoList = runInfoList.findAll { it.contains('#') }
runInfoListSize = runInfoList.size()

runInfo_kits_ch = Channel.fromList(runInfoList).view()

if (runInfoListSize > 2) {
    params.single = false
}
else {
    params.single = true
}
println params.single


//xxxxxxxxxxxxxx//
//***Basecalling***//
//xxxxxxxxxxxxxx//

workflow basecalling_wf {
    take:
        dir_input
    
    main:

        guppy_gpu(dir_input)

        if (runInfoListSize > 2) { fastq_channel = guppy_gpu.out }

        else { fastq_channel = guppy_gpu.out
                            .map { it -> it[1] }
                            .flatten()
                            .map { it -> [ it.simpleName, it ] }
        }

    emit:
        fastq_channel
}


//xxxxxxxxxxxxxx//
//***main Workflow***//
//xxxxxxxxxxxxx//

workflow {
    basecalling_wf(inDir_ch)
}


//xxxxxxxxxxxxxx//
//***create sampleDirs***//
//xxxxxxxxxxxxxx//

//process sample_dir_creation {

 //   input:
 //       file barcode_file from barcode_ch
 //       path output from output_ch
    
    // shell-command to read the barcode-file and make directories for all samples
    // in the corresponding subdirectories (& deleting the barcode)
  //  """
  //  while read line; do mkdir -p $output/fast5/$(echo "$line" | cut -c5-); done < $barcode_file
  //  while read line; do mkdir -p $output/fastq/$(echo "$line" | cut -c5-); done < $barcode_file
  //  """
//}

// how does the program know from which channel the results come 
// (that are the result of the whole program)?