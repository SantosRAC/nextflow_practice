process salmonQuant {
    input:
        path trimmed_reads

    output:
        path "${trimmed_reads.baseName}_${params.indexName}"

    script:
        def indexPath = "$projectDir/6b_References/${params.indexName}_index"

        """
        if [[ -f ${trimmed_reads} ]]; then
            echo "Running Salmon in Single-End mode"
            salmon quant -i ${indexPath} -l A \
            -r ${trimmed_reads} \
            --validateMappings -o ${trimmed_reads.baseName}_${params.indexName} \
            --threads 2 --seqBias --gcBias \
            --reduceGCMemory
        elif [[ \$(ls -1 ${trimmed_reads} | wc -l) -eq 2 ]]; then
            echo "Running Salmon in Paired-End mode"
            salmon quant -i ${indexPath} -l A \
            -1 \$(echo ${trimmed_reads} | cut -d ' ' -f1) -2 \$(echo ${trimmed_reads} | cut -d ' ' -f2) \
            --validateMappings -o ${trimmed_reads.baseName}_${params.indexName} \
            --threads 2 --seqBias --gcBias \
            --reduceGCMemory
        else
            echo "Error: Unexpected number of FASTQ files" >&2
            exit 1
        fi
        """
}
