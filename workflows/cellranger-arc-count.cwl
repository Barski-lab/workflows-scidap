cwlVersion: v1.0
class: Workflow


requirements:
  - class: SubworkflowFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: MultipleInputFeatureRequirement


"sd:upstream":
  genome_indices:
  - "cellranger-mkref.cwl"


inputs:

  alias_:
    type: string
    label: "Analysis name"
    sd:preview:
      position: 1

  indices_folder:
    type: Directory
    label: "Cell Ranger Reference Sample"
    doc: |
      Any "Cell Ranger Reference Sample" that
      builds a reference genome package of a
      selected species for quantifying gene
      expression and chromatin accessibility.
      This sample can be obtained from "Cell
      Ranger Reference (RNA, ATAC, RNA+ATAC)"
      pipeline.
    "sd:upstreamSource": "genome_indices/arc_indices_folder"
    "sd:localLabel": true

  memory_limit:
    type: int?
    default: 20
    "sd:upstreamSource": "genome_indices/memory_limit"

  gex_fastq_file_r1:
    type:
    - File
    - type: array
      items: File
    label: "RNA FASTQ, Read 1"
    doc: |
      Optionally compressed FASTQ file
      with Read 1 (10x barcode and UMI)
      single-cell RNA sequencing data.
      If multiple files provided they
      will be merged.

  gex_fastq_file_r2:
    type:
    - File
    - type: array
      items: File
    label: "RNA FASTQ, Read 2"
    doc: |
      Optionally compressed FASTQ file
      with Read 2 (cDNA insert) single-cell
      RNA sequencing data. If multiple
      files provided they will be merged.

  atac_fastq_file_r1:
    type:
    - File
    - type: array
      items: File
    label: "ATAC FASTQ, Read 1"
    doc: |
      Optionally compressed FASTQ file
      with Read 1 (transposed DNA)
      single-cell ATAC sequencing data.
      If multiple files provided they
      will be merged.

  atac_fastq_file_r2:
    type:
    - File
    - type: array
      items: File
    label: "ATAC FASTQ, Read 2"
    doc: |
      Optionally compressed FASTQ file
      with Read 2 (10x barcode)
      single-cell ATAC sequencing data.
      If multiple files provided they
      will be merged.

  atac_fastq_file_r3:
    type:
    - File
    - type: array
      items: File
    label: "ATAC FASTQ, Read 3"
    doc: |
      Optionally compressed FASTQ file
      with Read 3 (transposed DNA)
      single-cell ATAC sequencing data.
      If multiple files provided they
      will be merged.

  exclude_introns:
    type: boolean?
    default: false
    label: "Do not count intronic reads"
    doc: |
      Exclude intronic reads when counting
      gene expression. In this mode, only
      reads that are exonic and compatible
      with annotated splice junctions in
      the reference are counted. Using this
      mode will reduce the UMI counts and
      decrease sensitivity.
    "sd:layout":
      advanced: true

  threads:
    type:
    - "null"
    - type: enum
      symbols:
      - "1"
      - "2"
      - "3"
      - "4"
      - "5"
      - "6"
    default: "6"
    label: "Cores/CPUs"
    doc: |
      Parallelization parameter to define the
      number of cores/CPUs that can be utilized
      simultaneously.
      Default: 4
    "sd:layout":
      advanced: true


outputs:

  web_summary_report:
    type: File
    outputSource: generate_counts_matrix/web_summary_report
    label: "Cell Ranger Summary"
    doc: |
      Report generated by Cell Ranger
    "sd:visualPlugins":
    - linkList:
        tab: "Overview"
        target: "_blank"

  cellbrowser_report:
    type: File
    outputSource: cellbrowser_build/index_html_file
    label: "UCSC Cell Browser"
    doc: |
      UCSC Cell Browser HTML index file
    "sd:visualPlugins":
    - linkList:
        tab: "Overview"
        target: "_blank"

  fastqc_report_gex_fastq_r1:
    type: File
    outputSource: run_fastqc_for_gex_fastq_r1/html_file
    label: "QC report (RNA FASTQ, Read 1)"
    doc: |
      FastqQC report generated for
      RNA FASTQ file, Read 1
    "sd:visualPlugins":
    - linkList:
        tab: "Overview"
        target: "_blank"

  fastqc_report_gex_fastq_r2:
    type: File
    outputSource: run_fastqc_for_gex_fastq_r2/html_file
    label: "QC report (RNA FASTQ, Read 2)"
    doc: |
      FastqQC report generated for
      RNA FASTQ file, Read 2
    "sd:visualPlugins":
    - linkList:
        tab: "Overview"
        target: "_blank"

  fastqc_report_atac_fastq_r1:
    type: File
    outputSource: run_fastqc_for_atac_fastq_r1/html_file
    label: "QC report (ATAC FASTQ, Read 1)"
    doc: |
      FastqQC report generated for
      ATAC FASTQ file, Read 1
    "sd:visualPlugins":
    - linkList:
        tab: "Overview"
        target: "_blank"

  fastqc_report_atac_fastq_r2:
    type: File
    outputSource: run_fastqc_for_atac_fastq_r2/html_file
    label: "QC report (ATAC FASTQ, Read 2)"
    doc: |
      FastqQC report generated for
      ATAC FASTQ file, Read 2
    "sd:visualPlugins":
    - linkList:
        tab: "Overview"
        target: "_blank"

  fastqc_report_atac_fastq_r3:
    type: File
    outputSource: run_fastqc_for_atac_fastq_r3/html_file
    label: "QC report (ATAC FASTQ, Read 3)"
    doc: |
      FastqQC report generated for
      ATAC FASTQ file, Read 3
    "sd:visualPlugins":
    - linkList:
        tab: "Overview"
        target: "_blank"

  metrics_summary_report:
    type: File
    outputSource: generate_counts_matrix/metrics_summary_report
    label: "Run summary metrics"
    doc: |
      Cell Ranger generated run summary
      metrics in CSV format

  barcode_metrics_report:
    type: File
    outputSource: generate_counts_matrix/barcode_metrics_report
    label: "ATAC and RNA barcode metrics"
    doc: |
      ATAC and RNA read count summaries
      generated for every barcode observed
      in the experiment. The columns contain
      the paired ATAC and Gene Expression
      barcode sequences, ATAC and Gene
      Expression QC metrics for that barcode,
      as well as whether this barcode was
      identified as a cell-associated
      partition by the pipeline.

  gex_possorted_genome_bam_bai:
    type: File
    outputSource: generate_counts_matrix/gex_possorted_genome_bam_bai
    label: "RNA reads"
    doc: |
      Genome track of RNA reads aligned to
      the reference genome. Each read has
      a 10x Chromium cellular (associated
      with a 10x Genomics gel bead) barcode
      and molecular barcode information
      attached.
    "sd:visualPlugins":
    - igvbrowser:
        tab: "IGV Genome Browser"
        id: "igvbrowser"
        type: "alignment"
        format: "bam"
        name: "RNA reads"
        displayMode: "SQUISHED"

  atac_possorted_genome_bam_bai:
    type: File
    outputSource: generate_counts_matrix/atac_possorted_genome_bam_bai
    label: "ATAC reads"
    doc: |
      Genome track of ATAC reads aligned to
      the reference genome. Each read has
      a 10x Chromium cellular (associated
      with a 10x Genomics gel bead) barcode
      and mapping information stored in TAG
      fields.
    "sd:visualPlugins":
    - igvbrowser:
        tab: "IGV Genome Browser"
        id: "igvbrowser"
        type: "alignment"
        format: "bam"
        name: "ATAC reads"
        displayMode: "SQUISHED"

  filtered_feature_bc_matrix_folder:
    type: File
    outputSource: compress_filtered_feature_bc_matrix_folder/compressed_folder
    label: "Filtered feature barcode matrix, MEX"
    doc: |
      Filtered feature barcode matrix stored
      as a CSC sparse matrix in MEX format.
      The rows consist of all the gene and
      peak features concatenated together
      (identical to raw feature barcode
      matrix) and the columns are restricted
      to those barcodes that are identified
      as cells.

  filtered_feature_bc_matrix_h5:
    type: File
    outputSource: generate_counts_matrix/filtered_feature_bc_matrix_h5
    label: "Filtered feature barcode matrix, HDF5"
    doc: |
      Filtered feature barcode matrix stored
      as a CSC sparse matrix in hdf5 format.
      The rows consist of all the gene and
      peak features concatenated together
      (identical to raw feature barcode
      matrix) and the columns are restricted
      to those barcodes that are identified
      as cells.

  raw_feature_bc_matrices_folder:
    type: File
    outputSource: compress_raw_feature_bc_matrices_folder/compressed_folder
    label: "Raw feature barcode matrix, MEX"
    doc: |
      Raw feature barcode matrix stored as
      a CSC sparse matrix in MEX format.
      The rows consist of all the gene and
      peak features concatenated together
      and the columns consist of all observed
      barcodes with non-zero signal for
      either ATAC or gene expression.

  raw_feature_bc_matrices_h5:
    type: File
    outputSource: generate_counts_matrix/raw_feature_bc_matrices_h5
    label: "Raw feature barcode matrix, HDF5"
    doc: |
      Raw feature barcode matrix stored as
      a CSC sparse matrix in hdf5 format.
      The rows consist of all the gene and
      peak features concatenated together
      and the columns consist of all observed
      barcodes with non-zero signal for
      either ATAC or gene expression.

  secondary_analysis_report_folder:
    type: File
    outputSource: compress_secondary_analysis_report_folder/compressed_folder
    label: "Secondary analysis"
    doc: |
      Various secondary analyses that
      utilize the ATAC, RNA data, and
      their linkage: dimensionality
      reduction and clustering results
      for the ATAC and RNA data,
      differential expression, and
      differential accessibility for all
      clustering results above and linkage
      between ATAC and RNA data.

  gex_molecule_info_h5:
    type: File
    outputSource: generate_counts_matrix/gex_molecule_info_h5
    label: "RNA molecule-level data"
    doc: |
      Count and barcode information for
      every RNA molecule observed in the
      experiment in hdf5 format

  loupe_browser_track:
    type: File
    outputSource: generate_counts_matrix/loupe_browser_track
    label: "Loupe Browser visualization"
    doc: |
      Loupe Browser visualization file
      with all the analysis outputs

  atac_fragments_file:
    type: File
    outputSource: generate_counts_matrix/atac_fragments_file
    label: "ATAC fragments"
    doc: |
      Count and barcode information for
      every ATAC fragment observed in
      the experiment in TSV format.
  
  atac_peaks_bed_file:
    type: File
    outputSource: generate_counts_matrix/atac_peaks_bed_file
    label: "ATAC peaks"
    doc: |
      Genome track of open-chromatin
      regions identified as peaks.
    "sd:visualPlugins":
    - igvbrowser:
        tab: "IGV Genome Browser"
        id: "igvbrowser"
        type: "annotation"
        name: "ATAC peaks"
        displayMode: "COLLAPSE"
        height: 40

  atac_cut_sites_bigwig_file:
    type: File
    outputSource: generate_counts_matrix/atac_cut_sites_bigwig_file
    label: "ATAC transposition counts"
    doc: |
      Genome track of observed transposition
      sites in the experiment smoothed at a
      resolution of 400 bases.
    "sd:visualPlugins":
    - igvbrowser:
        tab: "IGV Genome Browser"
        id: "igvbrowser"
        type: "wig"
        name: "ATAC transposition counts"
        height: 120

  atac_peak_annotation_file:
    type: File
    outputSource: generate_counts_matrix/atac_peak_annotation_file
    label: "ATAC peaks annotations"
    doc: |
      Annotations of peaks based on
      genomic proximity alone. Note,
      that these are not functional
      annotations and they do not make
      use of linkage with RNA data.

  generate_counts_matrix_stdout_log:
    type: File
    outputSource: generate_counts_matrix/stdout_log
    label: "Output log, cellranger-arc count step"
    doc: |
      stdout log generated by cellranger-arc count

  generate_counts_matrix_stderr_log:
    type: File
    outputSource: generate_counts_matrix/stderr_log
    label: "Error log, cellranger-arc count step"
    doc: |
      stderr log generated by cellranger-arc count

  collected_statistics_yaml:
    type: File
    outputSource: collect_statistics/collected_statistics_yaml
    label: "Collected statistics, YAML"
    doc: |
      Collected statistics in YAML format

  collected_statistics_md:
    type: File
    outputSource: collect_statistics/collected_statistics_md
    label: "Collected statistics"
    doc: |
      Collected statistics in Markdown format
    "sd:visualPlugins":
    - markdownView:
        tab: "Overview"

  collected_statistics_tsv:
    type: File
    outputSource: collect_statistics/collected_statistics_tsv
    label: "Collected statistics"
    doc: |
      Collected statistics in TSV format
    "sd:visualPlugins":
    - tableView:
        vertical: true
        tab: "Overview"

  html_data_folder:
    type: Directory
    outputSource: cellbrowser_build/html_data
    label: "UCSC Cell Browser data"
    doc: |
      Directory with UCSC Cell Browser
      data


steps:

  extract_gex_fastq_r1:
    run: ../tools/extract-fastq.cwl
    in:
      compressed_file: gex_fastq_file_r1
      output_prefix:
        default: "rna_read_1"
    out:
    - fastq_file

  extract_gex_fastq_r2:
    run: ../tools/extract-fastq.cwl
    in:
      compressed_file: gex_fastq_file_r2
      output_prefix:
        default: "rna_read_2"
    out:
    - fastq_file

  extract_atac_fastq_r1:
    run: ../tools/extract-fastq.cwl
    in:
      compressed_file: atac_fastq_file_r1
      output_prefix:
        default: "atac_read_1"
    out:
    - fastq_file

  extract_atac_fastq_r2:
    run: ../tools/extract-fastq.cwl
    in:
      compressed_file: atac_fastq_file_r2
      output_prefix:
        default: "atac_read_2"
    out:
    - fastq_file

  extract_atac_fastq_r3:
    run: ../tools/extract-fastq.cwl
    in:
      compressed_file: atac_fastq_file_r3
      output_prefix:
        default: "atac_read_3"
    out:
    - fastq_file

  run_fastqc_for_gex_fastq_r1:
    run: ../tools/fastqc.cwl
    in:
      reads_file: extract_gex_fastq_r1/fastq_file
      threads:
        source: threads
        valueFrom: $(parseInt(self))
    out:
    - html_file

  run_fastqc_for_gex_fastq_r2:
    run: ../tools/fastqc.cwl
    in:
      reads_file: extract_gex_fastq_r2/fastq_file
      threads:
        source: threads
        valueFrom: $(parseInt(self))
    out:
    - html_file

  run_fastqc_for_atac_fastq_r1:
    run: ../tools/fastqc.cwl
    in:
      reads_file: extract_atac_fastq_r1/fastq_file
      threads:
        source: threads
        valueFrom: $(parseInt(self))
    out:
    - html_file

  run_fastqc_for_atac_fastq_r2:
    run: ../tools/fastqc.cwl
    in:
      reads_file: extract_atac_fastq_r2/fastq_file
      threads:
        source: threads
        valueFrom: $(parseInt(self))
    out:
    - html_file

  run_fastqc_for_atac_fastq_r3:
    run: ../tools/fastqc.cwl
    in:
      reads_file: extract_atac_fastq_r3/fastq_file
      threads:
        source: threads
        valueFrom: $(parseInt(self))
    out:
    - html_file

  generate_counts_matrix:
    run: ../tools/cellranger-arc-count.cwl
    in:
      gex_fastq_file_r1: extract_gex_fastq_r1/fastq_file
      gex_fastq_file_r2: extract_gex_fastq_r2/fastq_file
      atac_fastq_file_r1: extract_atac_fastq_r1/fastq_file
      atac_fastq_file_r2: extract_atac_fastq_r2/fastq_file
      atac_fastq_file_r3: extract_atac_fastq_r3/fastq_file
      indices_folder: indices_folder
      exclude_introns: exclude_introns
      threads:
        source: threads
        valueFrom: $(parseInt(self))
      memory_limit: memory_limit
      virt_memory_limit: memory_limit
    out:
    - web_summary_report
    - metrics_summary_report
    - barcode_metrics_report
    - gex_possorted_genome_bam_bai
    - atac_possorted_genome_bam_bai
    - filtered_feature_bc_matrix_folder
    - filtered_feature_bc_matrix_h5
    - raw_feature_bc_matrices_folder
    - raw_feature_bc_matrices_h5
    - secondary_analysis_report_folder
    - gex_molecule_info_h5
    - loupe_browser_track
    - atac_fragments_file
    - atac_peaks_bed_file
    - atac_cut_sites_bigwig_file
    - atac_peak_annotation_file
    - stdout_log
    - stderr_log

  compress_filtered_feature_bc_matrix_folder:
    run: ../tools/tar-compress.cwl
    in:
      folder_to_compress: generate_counts_matrix/filtered_feature_bc_matrix_folder
    out:
    - compressed_folder

  compress_raw_feature_bc_matrices_folder:
    run: ../tools/tar-compress.cwl
    in:
      folder_to_compress: generate_counts_matrix/raw_feature_bc_matrices_folder
    out:
    - compressed_folder

  compress_secondary_analysis_report_folder:
    run: ../tools/tar-compress.cwl
    in:
      folder_to_compress: generate_counts_matrix/secondary_analysis_report_folder
    out:
    - compressed_folder

  collect_statistics:
    run: ../tools/collect-stats-sc-arc-count.cwl
    in:
      metrics_summary_report: generate_counts_matrix/metrics_summary_report
    out:
    - collected_statistics_yaml
    - collected_statistics_tsv
    - collected_statistics_md

  cellbrowser_build:
    run: ../tools/cellbrowser-build-cellranger-arc.cwl
    in:
      secondary_analysis_report_folder: generate_counts_matrix/secondary_analysis_report_folder
      filtered_feature_bc_matrix_folder: generate_counts_matrix/filtered_feature_bc_matrix_folder
    out:
    - html_data
    - index_html_file


$namespaces:
  s: http://schema.org/

$schemas:
- https://github.com/schemaorg/schemaorg/raw/main/data/releases/11.01/schemaorg-current-http.rdf

s:name: "Cell Ranger Count (RNA+ATAC)"
label: "Cell Ranger Count (RNA+ATAC)"
s:alternateName: "Quantifies single-cell gene expression and chromatin accessibility of the sequencing data from a single 10x Genomics library in a combined manner"

s:downloadUrl: https://raw.githubusercontent.com/datirium/workflows/master/workflows/cellranger-arc-count.cwl
s:codeRepository: https://github.com/datirium/workflows
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
  Cell Ranger Count (RNA+ATAC)

  Quantifies single-cell gene expression and chromatin accessibility
  of the sequencing data from a single 10x Genomics library in a
  combined manner. The results of this workflow are primarily used in
  either “Single-Cell Multiome ATAC and RNA-Seq Filtering Analysis”
  or “Cell Ranger Aggregate (RNA+ATAC)” pipelines.