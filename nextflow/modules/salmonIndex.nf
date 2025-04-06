process salmonIndex {
    input:
        path reference_genome

    output:
        path "salmon_index", emit: index_dir

    script:
        if (!file(reference_genome).exists()) {
            error "ERRO: Genoma de referência não encontrado em: ${reference_genome}"
        }
        """
        salmon index -t $reference_genome -i salmon_index
        """
}
