#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// include modules
include { salmonQuant                   } from "../modules/salmonQuant.nf"

workflow {
    // Criando um canal com os arquivos de trimmed reads
    trimmed_reads_ch = Channel.fromPath("5_trimmedReads/*.fastq")

    // map run and sample_name (from samples.csv)
    sample_info = samples_ch.map { row -> tuple(row.run, row.sample_name) }

    // get SRA Accession and set accession channel
    sample_info.map { run, sample_name -> run } set { accession_ch }

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

    // run salmonIndex to check for reference or generate it
    salmon_index_ch = Channel.value(params.indexName)
    salmon_index_ch | salmonIndex

    // run salmonQuant after index is generated or already exists
    trimmed_reads_ch = Channel.fromPath("5_trimmedReads/*.fastq")
    salmon_quant_ch = trimmed_reads_ch | salmonQuant

    // aqui estou incluindo o processo sampleInfo, mas não sei exatamente qual é a saída esperada
    json_ch | sampleInfo

    // Passando esse canal para o processo salmonQuant
    trimmed_reads_ch | salmonQuant
}
