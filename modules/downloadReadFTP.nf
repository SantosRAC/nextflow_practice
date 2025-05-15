process downloadReadFTP {
    input:
        tuple val(run), path(json_file)

    output:
        tuple val(run), path("*.fastq.gz")

    """
    ${projectDir}/../bin/download_from_json.py --json ${json_file}
    """
}

