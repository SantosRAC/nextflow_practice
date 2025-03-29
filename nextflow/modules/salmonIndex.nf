process salmonIndex {
    input:
        val indexName from params.indexName

    output:
        path "$projectDir/6b_References/${indexName}"

    script:
        def refDir = "$projectDir/6b_References"
        def referenceFasta = "$projectDir/GENOMES/RAW/*${indexName}*{.fa,.fasta,.fa.gz,.fasta.gz}"
        def indexPath = "$refDir/${indexName}_index"
        
        if (file(indexPath).exists()) {
            """
            echo "Reference already indexed"
            """
        } 
        else {
            if (file(referenceFasta).exists()) {
                """
                echo "Indexing reference genome..."
                salmon index -t ${referenceFasta} -i ${indexPath} --gencode
                """
            } 
            else {
                error "Fasta file for reference not found"
            }
        }
}
