process salmonQuant {
    input:
        path trimmed_reads from "$projectDir/${params.outdir}/5_trimmedReads/*"

    output:
        path "${trimmed_reads.baseName}_${params.indexName}"

    script:
        def indexPath = "$projectDir/bin/${params.indexName}_index"
        
        if (trimmed_reads.size() == 1) {
            // Single-end
            """
            echo "Running Salmon in Single-End mode"
            salmon quant -i ${indexPath} -l A \
            -r ${trimmed_reads[0]} \
            --validateMappings -o ${trimmed_reads.baseName}_${params.indexName} \
            --threads 2 --seqBias --gcBias \
            --reduceGCMemory
            """
        } 
        else if (trimmed_reads.size() == 2) {
            // Paired-end
            """
            echo "Running Salmon in Paired-End mode"
            salmon quant -i ${indexPath} -l A \
            -1 ${trimmed_reads[0]} -2 ${trimmed_reads[1]} \
            --validateMappings -o ${trimmed_reads.baseName}_${params.indexName} \
            --threads 2 --seqBias --gcBias \
            --reduceGCMemory
            """
        } 
        else {
            error "Error: Unexpected number of FASTQ files"
        }
}
