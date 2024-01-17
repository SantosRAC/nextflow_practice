# Nextflow Practice

## Practical activity

 * January 15, 2024 (Monday)
 * 4pm - 6pm BRT
 * Online: [Google Meet](https://meet.google.com/jsa-uuwf-gbz)

PS: if you want to join the meeting, please send an email to [@SantosRAC](mailto:renatoacsantos@gmail.com) by January 14, 2024 (Sunday).

Contact information:
 * Renato Augusto Corrêa dos Santos [@SantosRAC](mailto:renatoacsantos@gmail.com)

### Requirements

 * Nextflow version 23.10.0 build 5889
 * ffq v0.3
 * Trimmomatic v0.39
 * jq v1.7.1
 * [edirect](https://www.ncbi.nlm.nih.gov/books/NBK25501/)


### Pipeline execution

```bash
cd nextflow
nextflow run nextflow_pratice.nf -c ../nextflow.config
# if docker requires sudo
sudo /path/to/nextflow nextflow_pratice.nf -c ../nextflow.config
```

[@jomare1188](https://github.com/jomare1188) suggested to add the following parameters to the command line: `-with-report -with-dag`. They provide a report and a DAG graph, respectively.

```bash
sudo /path/to/nextflow nextflow_pratice.nf -c ../nextflow.config -with-report -with-dag --reads "SRR6665476"
```

`--reads "SRR6665476"` changes the value of `params.reads` variable in the nextflow.nf file.

After the activity, we added a report and a DAG graph to the `/results` folder, providing examples of workflows that failed and succeeded.

## Organizers

 * Renato Augusto Corrêa dos Santos [@SantosRAC](https://github.com/SantosRAC)
 * Pedro Cristovão Carvalho [@capuccino26](https://github.com/capuccino26)
 * Jorge Mario Muñoz Pérez [@jomare1188](https://github.com/jomare1188)
 * Kelly Hidalgo Martinez [@khidalgo85](https://github.com/khidalgo85)
 * Beatriz Rodrigues Estevam [@Beatriz-Estevam](https://github.com/Beatriz-Estevam)
 * Felipe Vaz Peres [@felipevzps](https://github.com/felipevzps)


## References

 * [Nextflow & nf-core Treinamento Comunitário Online - Sessão 1 (Portuguese)](https://www.youtube.com/watch?v=751E-yOH7H8) (shared by [@khidalgo85](https://github.com/khidalgo85))
 * [Nextflow Official Documentation](https://www.nextflow.io/docs/latest/)
 * [RNA sequencing analysis pipeline](https://nf-co.re/rnaseq/3.13.2) (shared by [@capuccino26](https://github.com/capuccino26))


