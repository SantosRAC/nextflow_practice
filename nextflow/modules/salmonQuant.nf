process salmonQuant {
    input:
        tuple val(run), path(trimmed_reads), path(salmon_index)

    output:
        tuple val(run), path("${run}/quant.sf")

    script:
        if (trimmed_reads.size() == 2) {
            """
            salmon quant -i $salmon_index -l A \
                -1 ${trimmed_reads[0]} \
                -2 ${trimmed_reads[1]} \
                -o ${run} \
                --validateMappings
            """
        } else if (trimmed_reads.size() == 1) {
            """
            salmon quant -i $salmon_index -l A \
                -r ${trimmed_reads[0]} \
                -o ${run} \
                --validateMappings
            """
        }
        // TODO: remove the condition below after debuggin the pipeline
        else {
            """ 
            echo: run: ${run}, "reads[0]: ${trimmed_reads[0]}, reads[1]: ${trimmed_reads[1]}, salmon_index: $salmon_index"
            """
        }
}
