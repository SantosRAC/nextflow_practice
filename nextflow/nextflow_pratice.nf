#!/usr/bin/env nextflow

params.reads = "SRR1156953"

process getReadFTP {
    publishDir "$projectDir", mode: 'copy'
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

process sampleInfo {
        publishDir "$projectDir/SAMPLEINFO", mode: 'copy'

	input:
	path json_file

        output:
        file '*'

        script:
        """
        /media/bkoffee/HDD1/NEXTFLOW/sampleinfo.sh "$json_file"
        """
}

workflow {
    run_accesion = params.reads
    genjson = channel.of(run_accesion) | getReadFTP
    genjson | downloadReadFTP | runTrimmomatic
    genjson | sampleinfo
}
