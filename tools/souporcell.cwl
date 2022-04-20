cwlVersion: v1.0
class: CommandLineTool


requirements:
- class: InlineJavascriptRequirement


hints:
- class: DockerRequirement
  dockerPull: cumulusprod/souporcell:2021.03


inputs:
  
  possorted_genome_bam_bai:
    type: File
    secondaryFiles:
    - .bai
    inputBinding:
      position: 5
      prefix: "--bam"
    doc: |
      Position-sorted indexed aligned to the reference genome and transcriptome gene
      expression reads file annotated with barcode information in BAM+BAI format.

  barcodes_tsv_file:
    type: File
    inputBinding:
      position: 6
      prefix: "--barcodes"
    doc: |
      Cellular barcodes TSV file from the filtered feature-barcode matrices folder
      generated by Cell Ranger Count (if run ARC then use only GEX matrices)

  genome_fasta_file:
    type: File
    secondaryFiles:
    - .fai
    inputBinding:
      position: 7
      prefix: "--fasta"
    doc: |
      Reference genome FASTA file + fai index file

  clusters_count:
    type: int
    inputBinding:
      position: 8
      prefix: "--clusters"
    doc: |
      Number of clusters to detect (number of donors merged into one single-cell experiment)

  ploidy_count:
    type: int?
    inputBinding:
      position: 9
      prefix: "--ploidy"
    doc: |
      Ploidy, must be 1 or 2
      Default: 2

  min_alt:
    type: int?
    inputBinding:
      position: 10
      prefix: "--min_alt"
    doc: |
      Min alt to use locus
      Default: 10

  min_ref:
    type: int?
    inputBinding:
      position: 11
      prefix: "--min_ref"
    doc: |
      Min ref to use locus
      Default: 10

  max_loci:
    type: int?
    inputBinding:
      position: 12
      prefix: "--max_loci"
    doc: |
      Max loci per cell, affects speed
      Default: 2048

  restarts_count:
    type: int?
    inputBinding:
      position: 13
      prefix: "--restarts"
    doc: |
      Number of restarts in clustering, when there are > 12
      clusters we recommend increasing this to avoid local
      minima
      Default: 100

  common_variants_vcf_file:
    type: File?
    inputBinding:
      position: 14
      prefix: "--common_variants"
    doc: |
      Common variant loci or known variant loci vcf file,
      must be made vs the same reference fasta

  known_genotypes_vcf_file:
    type: File?
    inputBinding:
      position: 15
      prefix: "--known_genotypes"
    doc: |
      Known variants per clone in population vcf mode, must be .vcf

  known_genotypes_sample_names:
    type:
    - "null"
    - string
    - type: array
      items: string
    inputBinding:
      position: 16
      prefix: "--known_genotypes_sample_names"
    doc: |
      Which samples in population vcf from known genotypes
      option represent the donors in your sample

  skip_remap:
    type: boolean?
    inputBinding:
      position: 17
      prefix: "--skip_remap"
    doc: |
      Don't remap with minimap2 (not recommended unless in
      conjunction with --common_variants)

  no_umi:
    type: boolean?
    default: false
    inputBinding:
      position: 18
      prefix: "--no_umi"
      valueFrom: $(self?"True":"False")                 # Souporcell expects word, not just boolean flag
    doc: |
      Set to True if your bam has no UMI tag, will
      ignore/override --umi_tag

  umi_tag:
    type: string?
    inputBinding:
      position: 19
      prefix: "--umi_tag"
    doc: |
      Set if your umi tag is not UB

  cell_tag:
    type: string?
    inputBinding:
      position: 20
      prefix: "--cell_tag"
    doc: |
      Set if your cell barcode tag is not CB

  ignore_data_errors:
    type: boolean?
    inputBinding:
      position: 21
      prefix: "--ignore"
    doc: |
      Set to True to ignore data error assertions

  threads:
    type: int?
    default: 1
    inputBinding:
      position: 22
      prefix: "--threads"
    doc: |
      Max threads to use
      Forced default: 1


outputs:

  genotype_cluster_tsv_file:
    type: File
    outputBinding:
      glob: "./souporcell/clusters.tsv"
    doc: "Cellurar barcodes file clustered by genotype"

  genotype_cluster_vcf_file:
    type: File
    outputBinding:
      glob: "./souporcell/cluster_genotypes.vcf"
    doc: |
      VCF file with genotypes for each cluster for each variant call.
      Refer to http://software.broadinstitute.org/software/igv/viewing_vcf_files
      for track description when displaying in IGV.

  ambient_rna_file:
    type: File
    outputBinding:
      glob: "./souporcell/ambient_rna.txt"
    doc: "Ambient RNA evaluation text file"

  stdout_log:
    type: stdout

  stderr_log:
    type: stderr


baseCommand: ["souporcell_pipeline.py", "--out_dir", "./souporcell"]


stdout: souporcell_stdout.log
stderr: souporcell_stderr.log


$namespaces:
  s: http://schema.org/

$schemas:
- https://github.com/schemaorg/schemaorg/raw/main/data/releases/11.01/schemaorg-current-http.rdf

label: "Souporcell Cluster by Genotype"
s:name: "Souporcell Cluster by Genotype"
s:alternateName: "Souporcell: robust clustering of single-cell RNA-seq data by genotype without reference genotypes"

s:downloadUrl: https://raw.githubusercontent.com/Barski-lab/workflows/master/tools/souporcell.cwl
s:codeRepository: https://github.com/Barski-lab/workflows
s:license: http://www.apache.org/licenses/LICENSE-2.0

s:isPartOf:
  class: s:CreativeWork
  s:name: Common Workflow Language
  s:url: http://commonwl.org/

s:creator:
- class: s:Organization
  s:legalName: "Cincinnati Children's Hospital Medical Center"
  s:location:
  - class: s:PostalAddress
    s:addressCountry: "USA"
    s:addressLocality: "Cincinnati"
    s:addressRegion: "OH"
    s:postalCode: "45229"
    s:streetAddress: "3333 Burnet Ave"
    s:telephone: "+1(513)636-4200"
  s:logo: "https://www.cincinnatichildrens.org/-/media/cincinnati%20childrens/global%20shared/childrens-logo-new.png"
  s:department:
  - class: s:Organization
    s:legalName: "Allergy and Immunology"
    s:department:
    - class: s:Organization
      s:legalName: "Barski Research Lab"
      s:member:
      - class: s:Person
        s:name: Michael Kotliar
        s:email: mailto:misha.kotliar@gmail.com
        s:sameAs:
        - id: http://orcid.org/0000-0002-6486-3898


doc: |
  Souporcell Cluster by Genotype
  ==============================

  Souporcell: robust clustering of single-cell RNA-seq data by genotype without reference genotypes

  --out_dir - harcoded to ./souporcell
  --threads - forced to the default 1, because it's required parameter
  --aligner - not added to CWL inputs


s:about: |
  usage: souporcell_pipeline.py [-h] -i BAM -b BARCODES -f FASTA -t THREADS -o
                                OUT_DIR -k CLUSTERS [-p PLOIDY]
                                [--min_alt MIN_ALT] [--min_ref MIN_REF]
                                [--max_loci MAX_LOCI] [--restarts RESTARTS]
                                [--common_variants COMMON_VARIANTS]
                                [--known_genotypes KNOWN_GENOTYPES]
                                [--known_genotypes_sample_names KNOWN_GENOTYPES_SAMPLE_NAMES [KNOWN_GENOTYPES_SAMPLE_NAMES ...]]
                                [--skip_remap SKIP_REMAP] [--no_umi NO_UMI]
                                [--umi_tag UMI_TAG] [--cell_tag CELL_TAG]
                                [--ignore IGNORE] [--aligner ALIGNER]

  single cell RNAseq mixed genotype clustering using sparse mixture model
  clustering.

  optional arguments:
    -h, --help            show this help message and exit
    -i BAM, --bam BAM     cellranger bam
    -b BARCODES, --barcodes BARCODES
                          barcodes.tsv from cellranger
    -f FASTA, --fasta FASTA
                          reference fasta file
    -t THREADS, --threads THREADS
                          max threads to use
    -o OUT_DIR, --out_dir OUT_DIR
                          name of directory to place souporcell files
    -k CLUSTERS, --clusters CLUSTERS
                          number cluster, tbd add easy way to run on a range of
                          k
    -p PLOIDY, --ploidy PLOIDY
                          ploidy, must be 1 or 2, default = 2
    --min_alt MIN_ALT     min alt to use locus, default = 10.
    --min_ref MIN_REF     min ref to use locus, default = 10.
    --max_loci MAX_LOCI   max loci per cell, affects speed, default = 2048.
    --restarts RESTARTS   number of restarts in clustering, when there are > 12
                          clusters we recommend increasing this to avoid local
                          minima
    --common_variants COMMON_VARIANTS
                          common variant loci or known variant loci vcf, must be
                          vs same reference fasta
    --known_genotypes KNOWN_GENOTYPES
                          known variants per clone in population vcf mode, must
                          be .vcf right now we dont accept gzip or bcf sorry
    --known_genotypes_sample_names KNOWN_GENOTYPES_SAMPLE_NAMES [KNOWN_GENOTYPES_SAMPLE_NAMES ...]
                          which samples in population vcf from known genotypes
                          option represent the donors in your sample
    --skip_remap SKIP_REMAP
                          don't remap with minimap2 (not recommended unless in
                          conjunction with --common_variants
    --no_umi NO_UMI       set to True if your bam has no UMI tag, will
                          ignore/override --umi_tag
    --umi_tag UMI_TAG     set if your umi tag is not UB
    --cell_tag CELL_TAG   set if your cell barcode tag is not CB
    --ignore IGNORE       set to True to ignore data error assertions
    --aligner ALIGNER     optionally change to HISAT2 if you have it installed,
                          not included in singularity build