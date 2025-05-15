#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// include modules
include { getReadFTP                    } from "../modules/getReadFTP.nf"
include { sampleInfo                    } from "../modules/sampleInfo.nf"
include { downloadReadFTP               } from "../modules/downloadReadFTP.nf"
include { fastqc as raw_fastqc          } from "../modules/fastqc.nf"
include { multiqc as raw_multiqc        } from "../modules/multiqc.nf"
include { bbduk                         } from "../modules/bbduk.nf"
include { fastqc as trimmed_fastqc      } from "../modules/fastqc.nf"
include { multiqc as trimmed_multiqc    } from "../modules/multiqc.nf"
include { salmonIndex                   } from "../modules/salmonIndex.nf"
include { salmonQuant                   } from "../modules/salmonQuant.nf"
include { salmonQuantMerge              } from "../modules/salmonQuantMerge.nf"
include { buildNetwork                  } from "../modules/buildNetwork.nf"

workflow {
    // read csv with samples (run = SRA Accession)
    samples_ch = Channel.fromPath(params.samples_csv)
                        .splitCsv(header: true)

    // map run and sample_name (from samples.csv)
    sample_info = samples_ch.map{ row -> tuple(row.run, row.sample_name) }

    // get SRA Accession and set accession channel
    sample_info.map{ run, sample_name -> run } set { accession_ch }

    // ~~~~~~ WORKFLOW START ~~~~~~

    // run process getReadFTP
    json_ch = accession_ch | getReadFTP
    getReadFTP.out.view{ "getReadFTP: $it" }

    // download fastq files from getReadFTP 
    fastq_ch = json_ch | downloadReadFTP
    downloadReadFTP.out.view{ "downloadReadFTP: $it" }

    // run fastqc on raw data
    raw_fastqc_ch = fastq_ch | raw_fastqc
    raw_fastqc.out.view{ "raw_fastqc: $it" }

    // group only fastqc directories and run multiqc 
    raw_multiqc_ch = raw_fastqc_ch.map{ run, dir -> dir }.collect() | raw_multiqc
    raw_multiqc.out.view{ "raw_multiqc: $it" }

    // run bbduk 
    trimmed_fastq_ch = fastq_ch | bbduk
    bbduk.out.view{ "bbduk: $it" }

    // run fastqc on trimmed data 
    trimmed_fastqc_ch = trimmed_fastq_ch | trimmed_fastqc
    trimmed_fastqc.out.view{ "trimmed_fastqc: $it" }

    // group only fastqc directories and run multiqc 
    trimmed_multiqc_ch = trimmed_fastqc_ch.map{ run, dir -> dir }.collect() | trimmed_multiqc
    trimmed_multiqc.out.view{ "trimmed_multiqc: $it" }
    
    // run salmonIndex on reference genome 
    salmon_index_ch = salmonIndex(params.ref_genome)
    salmonIndex.out.view{ "salmonIndex: $it" }
    
    // run salmonQuant on reference genome 
    salmon_quant_ch = trimmed_fastq_ch.combine(salmon_index_ch) | salmonQuant
    salmonQuant.out.view{ "salmonQuant: $it" } 
    
    // combine all quantification files into a single expression matrix
    salmon_quantmerge_ch = salmon_quant_ch.map{ run, quant -> file(quant.getParent()) }.collect() | salmonQuantMerge
    salmonQuantMerge.out.view{ "salmonQuantMerge: $it" }

    // run corals to build a co-expression network 
    buildNetwork_ch = salmon_quantmerge_ch | buildNetwork 
    buildNetwork.out.view{ "buildNetwork: $it" }

    // here im just including the sampleInfo process, but idk exactly what is the expected output 
    json_ch | sampleInfo
}
