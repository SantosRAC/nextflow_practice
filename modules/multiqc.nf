process multiqc {
    input:
        path(fastqc_dirs)

    output:
        path("multiqc_report.html")

    script:
        """
        multiqc ${fastqc_dirs.join(' ')}
        """
}
