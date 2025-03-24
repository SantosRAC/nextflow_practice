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

workflow {
    // read csv with samples (run = SRA Accession)
    samples_ch = Channel.fromPath("samples/samples.csv")
                        .splitCsv(header: true)

    // map run and sample_name (from samples.csv)
    sample_info = samples_ch.map { row -> tuple(row.run, row.sample_name) }

    // get SRA Accession and set accession channel
    sample_info.map { run, sample_name -> run } set { accession_ch }

    // runnin the workflow (channel chaining)
    // run process getReadFTP
    json_ch = accession_ch | getReadFTP

    // download fastq files from getReadFTP 
    fastq_ch = json_ch | downloadReadFTP

    // run fastqc on raw data
    raw_fastqc_ch = fastq_ch | raw_fastqc

    // group fastqc files (raw) and run multiqc 
    raw_multiqc_ch = raw_fastqc_ch.collect() | raw_multiqc

    // run bbduk 
    trimmed_fastq_ch = fastq_ch | bbduk

    // run fastqc on trimmed data 
    trimmed_fastqc_ch = trimmed_fastq_ch | trimmed_fastqc

    // group fastqc files (trimmed) and run multiqc 
    trimmed_multiqc_ch = trimmed_fastqc_ch.collect() | trimmed_multiqc

    // here im just including the sampleInfo process, but idk exactly what is the expected output 
    json_ch | sampleInfo
}
