#!/usr/bin/env nextflow

params.reads = "SRR26130076"
params.readsForSplit = 50000

process getReadFTP {
    publishDir "$projectDir", mode: 'copy'
    container 'andreatelatin/getreads:2.0'
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
    download_from_json.py --json $json_file
    """
}

process runTrimmomatic {
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
    container 'combinelab/salmon:latest'
    publishDir "$projectDir/SALMON_RESULTS", mode: 'copy'

    input:
    path trimmed_reads

    output:
    path "${params.reads}_COMPGG"

    script:
    def line = params.reads
    def files = trimmed_reads.listFiles()

    if (files.size() == 2) {
        """
        salmon quant -i ../../SALMON/COMPGG_index -l A \
        -1 ${files[0]} -2 ${files[1]} \
        --validateMappings -o ${line}_COMPGG \
        --threads 10 --seqBias --gcBias
        """
    } else if (files.size() == 1) {
        """
        salmon quant -i ../../SALMON/COMPGG_index -l A \
        -r ${files[0]} \
        --validateMappings -o ${line}_COMPGG \
        --threads 10 --seqBias --gcBias
        """
    } else {
        error "Error: No valid trimmed reads found for Salmon: ${files.size()}"
    }
}

workflow {
    run_accession = params.reads
    genjson = channel.of(run_accession) | getReadFTP
    genjson | downloadReadFTP | runTrimmomatic | SalmonFull
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
