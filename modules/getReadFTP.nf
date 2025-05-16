process getReadFTP {
    maxForks 1  // limit parallel downloads: https://github.com/nextflow-io/nextflow/discussions/3415
    
    input:
        val(run)

    output:
        tuple val(run), path("${run}.json")

    script:
        """
        ffq -o ${run}.json ${run}
        """
}
