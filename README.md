# wet-lab-to-in-silico
Worklfow:  (Sequencing - file transfer - demultiplexing - clean storage) x automation
by ricc and mike



What to do:
* watch path nextflow method
* fast 5 input
* use guppy module basecaller from dockerpipelines. with write out for fast 5 demultiplexing
  * use trim barcode option flag
* input run info needed for fast5 demultiplexing
* fast 5 demultiplex to single samples
  * folder structure:
    * database
      * fast5
        * sample1
          * fast5 files
      * fastq
        * sample1
          * fastq files
* 2 cases with and w/o barcode
* input flag for username and ip for ssh and transfer
* transfer modul which transfers the data to the nanoserver (sync-away.sh)
* on WS1 mnt/nanoserver --> get small fast5 test data (should be multiplexed)
* rm work/*   ( refering to the tmp/ to remove used storage space used by nextflow in current working dir)
# Goals
* fastq and fast5 directory per sample
* sample should be demultiplexed
* name directory af ter sample ( barcode to samplename)
* guppy version in fastq folder (for nanopolish and medaka)
* flow cell number and  the used kit  in fast5 folder
