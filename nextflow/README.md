# co-expression network pipeline

This repository provides our code for the modular and reproducible **Nextflow pipeline** to build gene co-expression networks from raw RNA-Seq data.  
It automates the process from data download to quantification and network construction.

---

# requirements

Ensure the following tools are installed before running the pipeline:

- `Nextflow` (version **24.10.2**)
- `Conda`

>[!IMPORTANT]
>It is **strongly recommended** to use Conda for creating an isolated and reproducible environment.

---

# project structure

```
nextflow
├── bin/
│   ├── download_from_json.py
│   ├── generate_correlations_corals.py
│   └── sampleinfo.sh
├── config/
│   └── nextflow.config
├── environment.yml
├── modules/                  # DSL2 modules
├── workflows/                # main pipeline (main.nf)
├── report/                   # pipeline reports (HTML + DAG)
├── samples/                  # sample metadata (samples.csv)
```

---

# setup

1. **Clone this repository**:

```bash
# clone
git clone https://github.com/SantosRAC/R2C.git

# go to nextflow directory
cd R2C/nextflow
```

2. **Create and activate Conda environment**:

```bash
# creating conda environment
conda env create -n R2C -f environment.yml

# activating environment
conda activate R2C
```

---

# how to run

From the project root directory, execute:

```bash
# run the pipeline
nextflow run workflows/main.nf -c config/nextflow.config
```

**Flags**:
- `-c config/nextflow.config`: loads custom configuration

---

# example output summary

```
Nextflow 24.10.5 is available - Please consider updating your version to it

 N E X T F L O W   ~  version 24.10.2

Launching `workflows/main.nf` [pedantic_golick] DSL2 - revision: 6c586e9cf6

[07/b99ca6] getReadFTP (1)      | 1 of 1 ✔
[4a/8f1741] downloadReadFTP (1) | 1 of 1 ✔
[db/032232] raw_fastqc (1)      | 1 of 1 ✔
[2d/976f7a] raw_multiqc         | 1 of 1 ✔
[bb/799c89] bbduk (1)           | 1 of 1 ✔
[be/c486ce] trimmed_fastqc (1)  | 1 of 1 ✔
[3d/da08bf] trimmed_multiqc     | 1 of 1 ✔
[9b/e00da1] salmonIndex         | 1 of 1 ✔
[52/c5c25f] salmonQuant (1)     | 1 of 1 ✔
[c0/b0839a] buildNetwork (1)    | 1 of 1 ✔
[ea/443133] sampleInfo (1)      | 1 of 1 ✔

Completed at: 09-Apr-2025 22:04:13
Duration    : 13m 49s
CPU hours   : 0.3
Succeeded   : 11
```

---

# reproducibility & testing

* The pipeline was developed with Nextflow version **24.10.2**.
* To ensure reproducibility, all steps are tracked under the `work/` directory.
* Final reports are saved in `report/` and can be used for visualization.

---

# questions?

For suggestions, bug reports, or collaboration, feel free to open an [issue](https://github.com/SantosRAC/R2C/issues)
