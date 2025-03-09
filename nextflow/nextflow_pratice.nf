#!/usr/bin/env nextflow

params.reads = "SRR8742861"
params.readsForSplit = 50000

process getReadFTP {
    publishDir "$projectDir/READS", mode: 'copy'
    input:
    val sra_accession

    output:
    path "${sra_accession}.json"
    """
    ffq -o "${sra_accession}.json" $sra_accession
    """
}

process downloadReadFTP {
    publishDir "$projectDir/FASTQ", mode: 'copy'
    input:
    path json_file

    output:
    path '*.fastq.gz'
    
    script:
    """
    python3 $projectDir/bin/download_from_json.py --json $json_file
    ls -l
    """
}

process runTrimmomatic {
    publishDir "$projectDir/TRIMMED_READS", mode: 'copy'
    container 'staphb/trimmomatic'

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

process sampleInfo {
    publishDir "$projectDir/SAMPLEINFO", mode: 'copy'
    input:
    path json_file

    output:
    file '*'

    script:
    """
    sampleinfo.sh "$json_file"
    """
}

process SalmonFull {
    publishDir "$projectDir/SALMON_RESULTS", mode: 'copy'

    input:
    path fastq_reads

    output:
    path "${fastq_reads.baseName}_RTX430"

    script:
    def line = fastq_reads.baseName
    def indexPath = "$projectDir/bin/RTX430_index"

    println "Listing files in FASTQ folder:"
    def listFiles = "ls -lh FASTQ/"
    listFiles.execute().text.split("\n").each { println it }

    def fastqFiles = file("FASTQ/*.fastq.gz").toList()

    println "Found files: ${fastqFiles}"

    if (fastqFiles.size() == 1) {
        // Single-end
        """
        salmon quant -i ${indexPath} -l A \
        -r ${fastqFiles[0]} \
        --validateMappings -o ${line}_RTX430 \
        --threads 2 --seqBias --gcBias \
        --reduceGCMemory
        """
    } else if (fastqFiles.size() == 2) {
        // Paired-end
        """
        salmon quant -i ${indexPath} -l A \
        -1 ${fastqFiles[0]} -2 ${fastqFiles[1]} \
        --validateMappings -o ${line}_RTX430 \
        --threads 2 --seqBias --gcBias \
        --reduceGCMemory
        """
    } else {
        error "Error: Expected 1 or 2 FASTQ files in the folder, found ${fastqFiles.size()}. Found files: ${fastqFiles}"
    }
}

workflow {
    run_accession = params.reads
    genjson = channel.of(run_accession) | getReadFTP
    fastq_files = genjson | downloadReadFTP
    fastq_files.println()
    fastq_files | SalmonFull
    genjson | sampleInfo
}
