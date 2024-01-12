#!/usr/bin/env nextflow

params.reads = "SRR1156953"
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
    ${baseDir}/../scripts/download_from_json.py --json $json_file
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
        ${baseDir}/../scripts/sampleinfo.sh "$json_file"
        """
}

workflow {
    run_accession = params.reads
    genjson = channel.of(run_accession) | getReadFTP
    genjson | downloadReadFTP | runTrimmomatic
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