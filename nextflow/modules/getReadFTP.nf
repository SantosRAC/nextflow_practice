process getReadFTP {
    input:
        val sra_accession

    output:
        path "${sra_accession}.json"

    """
    ffq -o ${sra_accession}.json ${sra_accession}
    """
}

