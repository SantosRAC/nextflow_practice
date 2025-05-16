process buildNetwork {
    input:
        path(expression_matrix)

    output:
        path("network.tsv") 

    script:
        """
        echo "Generating network from expression matrix"
        ${projectDir}/../bin/generate_correlations_corals.py --expression_matrix $expression_matrix --output_network network.tsv
        """
}
