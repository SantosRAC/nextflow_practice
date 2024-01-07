#!/usr/bin/env nextflow

params.reads = "SRR1156953"

process getReadFTP {
    input:
    val sra_accession

    output:
    path "${sra_accession}.json"

    """
    ffq -o "${sra_accession}.json" $sra_accession
    """
}

process downloadReadFTP {
    input:
    path json_file

    output:
    path '*.fastq.gz'
    
    """
    ${baseDir}/../scripts/download_from_json.py --json $json_file
    """
}

process runTrimmomatic {
    input:
    path fastq_read_list
    
    script:
    if(fastq_read_list.size() == 2)
        """
        echo Running Trimmomatic PE mode
        \${CONDA_PREFIX}/bin/trimmomatic PE \
        -trimlog trimmomatic.log $fastq_read_list -baseout output \
        MINLEN:15
        """
    else if(fastq_read_list.size() == 1)
        """
        echo Running Trimmomatic SE mode
        \${CONDA_PREFIX}/bin/trimmomatic SE \
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
