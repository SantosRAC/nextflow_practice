process salmonIndex {
    input:
<<<<<<< HEAD
        val indexName

    output:
        path "6b_References/${indexName}_index"

    script:
        def refDir = "6b_References"
        def indexPath = "${refDir}/${indexName}_index"

        if (file(indexPath).exists()) {
            """
            echo "Reference index already exists at ${indexPath}"
            """
        } else {
            def fastaPattern = "${params.genomes_dir}/*${indexName}*.fa"
            
            def proc = ["bash", "-c", "ls ${fastaPattern}"].execute()
            proc.waitFor()
            
            if (proc.exitValue() == 0) {
                def fastaFile = proc.text.trim().split('\n')[0]
                """
                echo "Indexing reference genome using ${fastaFile}"
                mkdir -p ${refDir}
                salmon index -t "${fastaFile}" -i "${indexPath}" --gencode
                """
            } else {
                error "Fasta file for reference not found matching pattern: ${fastaPattern}\n" +
                      "Available files in ${params.genomes_dir}:\n" +
                      new File(params.genomes_dir).listFiles().collect{ it.getName() }.join('\n')
            }
        }
=======
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
>>>>>>> 3201447f347db6be6a9ef9ba9785435b225fafa8
}
