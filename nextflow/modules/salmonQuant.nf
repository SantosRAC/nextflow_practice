process salmonQuant {
    input:
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
}
