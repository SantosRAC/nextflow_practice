#!/usr/bin/env nextflow

params.reads = "SRR1156953"
params.rawfiles = "$projectDir/*.json"

process getReadFTP {
    input:
    val sra_accession

    output:
    path "${sra_accession}.json"

    """
    /home/bkoffee/anaconda3/bin/ffq -o "${sra_accession}.json" $sra_accession
    """
}

process downloadReadFTP {
    input:
    path json_file

    output:
    path '*.fastq.gz'

    """
    /media/bkoffee/HDD1/NEXTFLOW/download_from_json.py --json $json_file
    """
}

process runTrimmomatic {
    input:
    path fastq_read_list

    script:
    if(fastq_read_list.size() == 2)
        """
        echo Running Trimmomatic PE mode
        java -jar /media/bkoffee/HDD1/NEXTFLOW/Trimmomatic-0.39/trimmomatic-0.39.jar PE \
        -trimlog trimmomatic.log $fastq_read_list -baseout output \
        MINLEN:15
        """
    else if(fastq_read_list.size() == 1)
        """
        echo Running Trimmomatic SE mode
        java -jar /media/bkoffee/HDD1/NEXTFLOW/Trimmomatic-0.39/trimmomatic-0.39.jar SE \
        -trimlog trimmomatic.log $fastq_read_list output.fastq.gz \
        MINLEN:15
        """
    else
        """
        echo "Error"
        echo "Not running Trimmomatic at all!!"
        """
}

process sampleinfo {
        publishDir "$projectDir/SAMPLEINFO", mode: 'copy'

        input:
        path filejs

        output:
        file '*'

        script:
        """
        echo File: $filejs
        /media/bkoffee/HDD1/NEXTFLOW/sampleinfo.sh "$filejs"
        """
}

workflow {
    run_accesion = params.reads
    channel.of(run_accesion) | getReadFTP | downloadReadFTP | runTrimmomatic
    Channel.fromPath(params.rawfiles) | sampleinfo
}
