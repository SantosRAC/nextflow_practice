process downloadReadFTP {
    input:
        path json_file

    output:
        path '*.fastq.gz'

    """
    ${projectDir}/../bin/download_from_json.py --json ${json_file}
    """
}

