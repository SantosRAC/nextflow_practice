process buildNetwork {
    input:
        path expression_matrix

    output:
        path network_file

    script:
        
        """
        echo "Generating network from expression matrix"
        generate_correlations_corals.py --expression_matrix ${expression_matrix} --output_network ${network_file}
        """
}