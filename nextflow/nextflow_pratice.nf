#!/usr/bin/env nextflow

params.reads = "SRR8742861"
params.readsForSplit = 50000

process getReadFTP {
    publishDir "$projectDir/READS", mode: 'copy'
    container 'file:///Storage/data1/pedro.carvalho/NEXTFLOW/nextflow_practice/nextflow/getreads.sif'
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
    
    """
    download_from_json.py --json $json_file
    """
}

process runTrimmomatic {
    publishDir "$projectDir/TRIMMED_READS", mode: 'copy'
    container 'singularity://staphb/trimmomatic'
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
    container 'singularity://library://vi.ya/rnaseq-dbs/salmon-1.4.0:latest'
    publishDir "$projectDir/SALMON_RESULTS", mode: 'copy'

    input:
    path fastq_reads

    output:
    path "${params.reads}_RTX430"

    script:
    def line = params.reads
    def files = trimmed_reads.listFiles()

    if (files.size() == 2) {
        """
        salmon quant -i /bin/RTX430_index -l A \
        -1 ${files[0]} -2 ${files[1]} \
        --validateMappings -o ${line}_RTX430 \
        --threads 10 --seqBias --gcBias
        """
    } else if (files.size() == 1) {
        """
        salmon quant -i /bin/RTX430_index -l A \
        -r ${files[0]} \
        --validateMappings -o ${line}_RTX430 \
        --threads 10 --seqBias --gcBias
        """
    } else {
        error "Error: No valid trimmed reads found for Salmon: ${files.size()}"
    }
}

workflow {
    run_accession = params.reads
    genjson = channel.of(run_accession) | getReadFTP
    fastq_files = genjson | downloadReadFTP
    fastq_files | SalmonFull
    genjson | sampleInfo
}

workflow getReadfromSRA{
    main:
    // get fastq.gz files
    chn = Channel.fromSRA(params.reads)

    // format chn output to format accepted by splitFastq 
    chn2 = chn.map{
        if(it[1] instanceof String){
            // println('string')
            return [it]
        }
        else
        {
            // println('notrstring')
            it[1].collect{path -> [it[0], path]}
        }
    }
    .flatMap()
    .view()

    // workflow output
    emit:
    // splitting fastq file - edit 'by'
    chn2.splitFastq(by:50000, file: true).map {it[1]} 
}
// Alternative workflow 
// Using fromSRA splitFastq channels to get fastq splitted files

//workflow {
//    run_accesion = params.reads
//    runTrimmomatic(getReadfromSRA())
//}
