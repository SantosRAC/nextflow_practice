process buildNetwork {
    input:
        path expression_matrix

    output:
        path "network" //TODO: set the output name in the config file

    script:
        
        """
        echo "Generating network from expression matrix"
        ${projectDir}/../bin/generate_correlations_corals.py --expression_matrix $expression_matrix --output_network network
        """
}
