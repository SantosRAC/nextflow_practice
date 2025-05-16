process sampleInfo {
    input:
        tuple val(run), path(json_file)

    output:
        tuple val(run), file('*')
    
    script:
        """
        ${projectDir}/../bin/sampleinfo.sh ${json_file}
        """
}
