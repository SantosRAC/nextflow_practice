process salmonQuantMerge {
    input:
        path(quant_files)
    
    output:
        path("expression_matrix.tsv")

    script:
        def quant_paths = quant_files.join(' ')
        """
        salmon quantmerge \
            --quants ${quant_paths} \
            --output expression_matrix.tsv \
            --column TPM
        """
}

