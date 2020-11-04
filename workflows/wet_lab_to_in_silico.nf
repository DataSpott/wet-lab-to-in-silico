#!/usr/bin/env nextflow
nextflow.preview.dsl=2

println "\u001B[32mProfile: $workflow.profile\033[0m"
println "\033[2mCurrent User: $workflow.userName"
println "Workdir location:"
println "  $workflow.workDir\u001B[0m"
println "CPUs to use: $params.cores"
println "Output dir: $params.output"

//display a help-msgs
if (params.help) { exit 0, helpMSG() }

// help
def helpMSG() {
    log.info """
    Usage:
    nextflow run wet_lab_to_in_silico.nf --dir /fast5 -profile local,docker
    --dir         directory where the sequencing-run is located
    
    Options:
    --cores       max cores [default: $params.cores]
    --memory      max memory [default: $params.memory]
    --output      directory where results are stored [default: $params.output]
    """.stripIndent()
}


//xxxxxxxxxxxxxx//
//***Inputs***//
//xxxxxxxxxxxxxx//

if (params.dir) { dir_input_ch = Channel
        .fromPath( params.dir, checkIfExists: true, type: 'dir')
        .map { file -> tuple(file.name, file) }
        .view()
    }

// outputDirectory
//if (params.output) { output_ch = Channel}


//xxxxxxxxxxxxxx//
//***Modules***//
//xxxxxxxxxxxxxx//

include { guppy_gpu } from './subworkflows/guppy/guppy'
include { combiner } from './subworkflows/combiner/combiner'

//xxxxxxxxxxxxxx//
//***process runInfo***//
//xxxxxxxxxxxxxx//

directory = new File(params.dir)
directory.eachFileRecurse { it.getClass()}
directory.eachFileRecurse {
    if (it.toString().contains('run_info.txt')) {
        runInfo_location = it.toString()
    } 
}
//I assume there is only one "run_info.txt"-file. Otherwise we have a problem...

def runInfoList = new File(runInfo_location).text.readLines()
runInfoList = runInfoList.findAll { it.contains('#') }
runInfoListSize = runInfoList.size()

runInfo_ch = Channel.fromList(runInfoList)//.view()

if (runInfoListSize > 2) {
    params.single = false
}
else {
    params.single = true
}


//xxxxxxxxxxxxxx//
//***Basecalling***//
//xxxxxxxxxxxxxx//

workflow basecalling_wf {
    take:
        dir_input
    
    main:

        guppy_gpu(dir_input)

        if (params.single == true) { fastq_channel = guppy_gpu.out }

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
    combiner(runInfo_ch, basecalling_wf(dir_input_ch))
    //basecalling_wf.out.fastq_channel.view()
}

//basecalling_wf.out.fastq_channel.view()

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