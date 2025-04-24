process sampleInfo {
    input:
        path json_file

    output:
        file '*'

    """
    ${projectDir}/../bin/sampleinfo.sh ${json_file}
    """
}

