process salmonQuant {
    input:
<<<<<<< HEAD
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
=======
        path trimmed_reads 
        path salmon_index

    output:
        path "quant/quant.sf"  //TODO: I think this can cause a problem if we have more than one accession file... It needs to be tested.

    script:
        if (trimmed_reads.size() == 2) {
            """
            salmon quant -i $salmon_index -l A \
                -1 ${trimmed_reads[0]} \
                -2 ${trimmed_reads[1]} \
                -o quant \
                --validateMappings
            """
        } else if (trimmed_reads.size() == 1) {
            """
            salmon quant -i $salmon_index -l A \
                -r ${trimmed_reads[0]} \
                -o quant \
                --validateMappings
            """
        }
        // TODO: remove the condition below after debuggin the pipeline
        else {
            """
            echo: "reads[0]: ${trimmed_reads[0]}, reads[1]: ${trimmed_reads[1]}, salmon_index: $salmon_index"
            """
        }
>>>>>>> 3201447f347db6be6a9ef9ba9785435b225fafa8
}
