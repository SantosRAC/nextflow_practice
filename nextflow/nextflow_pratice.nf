#!/usr/bin/env nextflow

params.reads = "SRR1156953"
params.getReadFT="/Storage/data1/jorge.munoz/nextflow_practice/getReadFTP"
params.download="/Storage/data1/jorge.munoz/nextflow_practice/download"
params.trimmomatic="/Storage/data1/jorge.munoz/nextflow_practice/trimmomatic"

process getReadFTP {
    publishDir("$params.getReadFT", mode: "copy")
    conda 'conda_envs/ffq.yml'
    input:
    val sra_accession

    output:
    path "${sra_accession}.json"

    """
    ffq -o "${sra_accession}.json" $sra_accession
    """
}

process downloadReadFTP {
    publishDir("$params.download", mode: "copy")
    conda 'conda_envs/TRIMMOMATIC.yml'
    input:
    path json_file

    output:
    path '*.fastq.gz'

    """
    /Storage/data1/jorge.munoz/nextflow_practice/scripts/download_from_json.py --json $json_file
    """
}

process runTrimmomatic {
    publishDir("$params.trimmomatic", mode: "copy")
    conda 'conda_envs/TRIMMOMATIC.yml'
    input:
    path fastq_read_list

    script:
    if(fastq_read_list.size() == 2)
        """
        echo Running Trimmomatic PE mode
        trimmomatic PE \
        -trimlog trimmomatic.log $fastq_read_list -baseout output \
        MINLEN:15
        """
    else if(fastq_read_list.size() == 1)
        """
        echo Running Trimmomatic SE mode
        trimmomatic SE \
        -trimlog trimmomatic.log $fastq_read_list output.fastq.gz \
        MINLEN:15
        """
    else
        """
        echo "Error"
        echo "Not running Trimmomatic at all!!"
        """
}

workflow {
    run_accesion = params.reads
    channel.of(run_accesion) | getReadFTP | downloadReadFTP | runTrimmomatic

}
