#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// include modules
<<<<<<< HEAD
include { salmonQuant                   } from "../modules/salmonQuant.nf"

workflow {
    // Criando um canal com os arquivos de trimmed reads
    trimmed_reads_ch = Channel.fromPath("5_trimmedReads/*.fastq")
=======
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
include { buildNetwork                  } from "../modules/buildNetwork.nf"

workflow {
    // read csv with samples (run = SRA Accession)
    samples_ch = Channel.fromPath("samples/samples.csv")
                        .splitCsv(header: true)
>>>>>>> 3201447f347db6be6a9ef9ba9785435b225fafa8

    // map run and sample_name (from samples.csv)
    sample_info = samples_ch.map { row -> tuple(row.run, row.sample_name) }

    // get SRA Accession and set accession channel
    sample_info.map { run, sample_name -> run } set { accession_ch }

<<<<<<< HEAD
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
=======
    // runnin the workflow (channel chaining)
    // run process getReadFTP
    json_ch = accession_ch | getReadFTP
    getReadFTP.out.view{ "getReadFTP: $it" }

    // download fastq files from getReadFTP 
    fastq_ch = json_ch | downloadReadFTP
    downloadReadFTP.out.view{ "downloadReadFTP: $it" }

    // run fastqc on raw data
    raw_fastqc_ch = fastq_ch | raw_fastqc
    raw_fastqc.out.view{ "raw_fastqc: $it" }

    // group fastqc files (raw) and run multiqc 
    raw_multiqc_ch = raw_fastqc_ch.collect() | raw_multiqc
    raw_multiqc.out.view{ "raw_multiqc: $it" }

    // run bbduk 
    trimmed_fastq_ch = fastq_ch | bbduk
    bbduk.out.view{ "bbduk: $it" }

    // run fastqc on trimmed data 
    trimmed_fastqc_ch = trimmed_fastq_ch | trimmed_fastqc
    trimmed_fastqc.out.view{ "trimmed_fastqc: $it" }

    // group fastqc files (trimmed) and run multiqc 
    trimmed_multiqc_ch = trimmed_fastqc_ch.collect() | trimmed_multiqc
    trimmed_multiqc.out.view{ "trimmed_multiqc: $it" }

    // Executar salmonIndex
    ref_genome = file("references/MetaBAT2_bins.99_sub.fa") //TODO: include the reference file only in the configuration. Also, currently it isnt calling the file from nextflow/references/, it is calling from nextflow/MetaBAT2_bins... Needs to be fixed 

    salmon_index_ch = salmonIndex(ref_genome)
    salmonIndex.out.view { "salmonIndex: $it" }

    // Combinar reads trimados (como lista) com o índice
    //salmon_quant_ch = trimmed_fastq_ch.combine(salmon_index_ch) | salmonQuant // TODO: im having trouble to make it work... But the line below works properly. I thought that it would have the same function, but this line isnt finding the salmon_index_ch. I guess we should talk about it...
    salmonQuant(trimmed_fastq_ch, salmon_index_ch)
    salmonQuant.out.view{ "salmonQuant: $it" } 
    
    //TODO: create a process to combine all the quantification files
    //salmonQuantMerge

    buildNetwork_ch = salmonQuant.out | buildNetwork 

    // here im just including the sampleInfo process, but idk exactly what is the expected output 
    json_ch | sampleInfo
>>>>>>> 3201447f347db6be6a9ef9ba9785435b225fafa8
}
