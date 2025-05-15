process sampleInfo {
    input:
        tuple val(run), path(json_file)

    output:
        tuple val(run), file('*')

    """
    ${projectDir}/../bin/sampleinfo.sh ${json_file}
    """
}

