process getReadFTP {
    input:
        val(run)

    output:
        tuple val(run), path("${run}.json")

    maxForks 3  // limit parallel downloads: https://github.com/nextflow-io/nextflow/discussions/3415

    """
    ffq -o ${run}.json ${run}
    """
}

