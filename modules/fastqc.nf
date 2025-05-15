process fastqc {
    input:
        tuple val(run), path(fastq_read_list)

    output:
        tuple val(run), path("*_fastqc")

    script:
        def read_fastqc_names = fastq_read_list.collect { it.toString().replace('.fastq.gz', '_fastqc') }
        if( fastq_read_list.size() == 2 ) {
            """
            echo "Running FastQC (PAIRED END MODE)"
            mkdir -p ${read_fastqc_names[0]} ${read_fastqc_names[1]}
            fastqc -o ${read_fastqc_names[0]} ${fastq_read_list[0]}
            fastqc -o ${read_fastqc_names[1]} ${fastq_read_list[1]}
            """
        }
        else if( fastq_read_list.size() == 1 ) {
            """
            echo "Running FastQC (SINGLE END MODE)"
            mkdir -p ${read_fastqc_names[0]}
            fastqc -o ${read_fastqc_names[0]} ${fastq_read_list[0]}
            """
        }
        else {
            """
            echo "Error: Unexpected number of fastq files"
            """
        }
}

