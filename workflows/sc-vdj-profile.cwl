cwlVersion: v1.0
class: Workflow


requirements:
  - class: SubworkflowFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement


"sd:upstream":
  sc_tools_sample:
  - "sc-rna-reduce.cwl"
  - "sc-rna-cluster.cwl"
  - "sc-ctype-assign.cwl"
  sc_vdj_sample:
  - "cellranger-multi.cwl"
  - "cellranger-aggr.cwl"


inputs:

  alias_:
    type: string
    label: "Analysis name"
    sd:preview:
      position: 1

  query_data_rds:
    type: File
    label: "Single-cell Analysis with PCA Transformed RNA-Seq Datasets"
    doc: |
      Analysis that includes single-cell
      RNA-Seq datasets run through "Single-Cell
      RNA-Seq Dimensionality Reduction Analysis"
      at any of the processing stages.
    "sd:upstreamSource": "sc_tools_sample/seurat_data_rds"
    "sd:localLabel": true

  contigs_data:
    type: File
    label: "Cell Ranger RNA+VDJ Sample"
    doc: |
      Any "Cell Ranger RNA+VDJ Sample" to
      load high level annotations of each
      high-confidence contig from the
      cell-associated barcodes. This sample
      can be obtained from either "Cell
      Ranger Count (RNA+VDJ)" or "Cell Ranger
      Aggregate (RNA, RNA+VDJ)" pipeline.
    "sd:upstreamSource": "sc_vdj_sample/filtered_contig_annotations_csv"
    "sd:localLabel": true

  cloneby:
    type:
    - "null"
    - type: enum
      symbols:
      - "gene"
      - "nt"
      - "aa"
      - "strict"
    default: "gene"
    label: "Clonotype calling"
    doc: |
      Defines how to call the clonotype.
      gene: based on VDJC gene sequence.
      nt: based on the nucleotide sequence.
      aa: based on the amino acid sequence.
      strict: based on the combination of
      the nucleotide and gene sequences.
      Default: gene

  filterby:
    type:
    - "null"
    - type: enum
      symbols:
      - "cells"
      - "chains"
      - "none"
    default: "none"
    label: "Stringency filter"
    doc: |
      Applies stringency filters. 1) cells:
      removes cells with more than 2 chains.
      2) chains: removes chains exceeding 2
      (selects the most expressed ones).
      Default: none.

  remove_partial:
    type: boolean?
    default: false
    label: "Remove cells with only one chain detected"
    doc: |
      Remove cells with only one chain detected.
      Default: keep all cells if at least one
      chain detected

  minimum_frequency:
    type: int?
    default: 3
    label: "Minimum clonotype frequency"
    doc: |
      Minimum frequency (number of cells) per
      clonotype to be reported.
      Default: 3

  datasets_metadata:
    type: File?
    label: "Datasets metadata (optional)"
    doc: |
      If the selected single-cell analysis
      includes multiple aggregated datasets,
      each of them can be assigned to a
      separate group by one or multiple
      categories. This can be achieved by
      providing a TSV/CSV file with
      "library_id" as the first column and
      any number of additional columns with
      unique names, representing the desired
      grouping categories. To obtain a proper
      template of this file, download
      "datasets_metadata.tsv" output from the
      "Files" tab of the filtering step that
      was run before the selected "Single-cell
      Analysis with PCA Transformed RNA-Seq
      Datasets" (a.k.a "Single-cell Analysis
      with Filtered RNA-Seq Datasets") and add
      extra columns as needed.

  barcodes_data:
    type: File?
    label: "Selected cell barcodes (optional)"
    doc: |
      A TSV/CSV file to optionally prefilter
      the single cell data by including only
      the cells with the selected barcodes.
      The provided file should include at
      least one column named "barcode", with
      one cell barcode per line. All other
      columns, except for "barcode", will be
      added to the single cell metadata loaded
      from "Single-cell Analysis with Clustered
      RNA-Seq Datasets" and can be utilized in
      the current or future steps of analysis.

  export_loupe_data:
    type: boolean?
    default: false
    label: "Save raw counts to Loupe file by accepting the EULA available at https://10xgen.com/EULA"
    doc: |
      Save raw counts from the RNA assay to Loupe file. By
      enabling this feature you accept the End-User License
      Agreement available at https://10xgen.com/EULA.
      Default: false
    "sd:layout":
      advanced: true

  color_theme:
    type:
    - "null"
    - type: enum
      symbols:
      - "gray"
      - "bw"
      - "linedraw"
      - "light"
      - "dark"
      - "minimal"
      - "classic"
      - "void"
    default: "classic"
    label: "Plots color theme"
    doc: |
      Color theme for all plots saved
      as PNG files.
      Default: classic
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
      Default: 6
    "sd:layout":
      advanced: true


outputs:

  umap_cl_freq_spl_ch_plot_png:
    type: File?
    outputSource: vdj_profile/umap_cl_freq_spl_ch_plot_png
    label: "UMAP colored by clonotype frequency (split by chain, filtered by minimum frequency)"
    doc: |
      UMAP colored by clonotype frequency.
      Split by chain; filtered by minimum clonotype
      frequency per donor.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "UMAP"
        Caption: "UMAP colored by clonotype frequency (split by chain, filtered by minimum frequency)"

  hmst_gr_idnt_spl_ch_plot_png:
    type: File?
    outputSource: vdj_profile/hmst_gr_idnt_spl_ch_plot_png
    label: "Proportion of clonotype frequencies per dataset (split by chain, not filtered by minimum frequency)"
    doc: |
      Proportion of clonotype frequencies per dataset.
      Split by chain; not filtered by clonotype frequency.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Grouped by dataset"
        Caption: "Proportion of clonotype frequencies per dataset (split by chain, not filtered by minimum frequency)"

  dvrs_gr_idnt_spl_ch_plot_png:
    type: File?
    outputSource: vdj_profile/dvrs_gr_idnt_spl_ch_plot_png
    label: "Diversity of clonotypes per dataset (split by chain, not filtered by minimum frequency)"
    doc: |
      Diversity of clonotypes per dataset.
      Split by chain; not filtered by clonotype frequency.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Grouped by dataset"
        Caption: "Diversity of clonotypes per dataset (split by chain, not filtered by minimum frequency)"

  vrlp_gr_idnt_spl_ch_plot_png:
    type: File?
    outputSource: vdj_profile/vrlp_gr_idnt_spl_ch_plot_png
    label: "Overlap of clonotypes between datasets (split by chain, filtered by minimum frequency)"
    doc: |
      Overlap of clonotypes between datasets.
      Split by chain; filtered by minimum clonotype
      frequency per donor.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Grouped by dataset"
        Caption: "Overlap of clonotypes between datasets (split by chain, filtered by minimum frequency)"

  allu_gr_idnt_spl_ch_plot_png:
    type: File?
    outputSource: vdj_profile/allu_gr_idnt_spl_ch_plot_png
    label: "Proportion of top shared clonotypes between datasets (split by chain, filtered by minimum frequency)"
    doc: |
      Proportion of top shared clonotypes between datasets.
      Split by chain; filtered by minimum clonotype
      frequency per donor; top clonotypes selected from
      each dataset.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Grouped by dataset"
        Caption: "Proportion of top shared clonotypes between datasets (split by chain, filtered by minimum frequency)"

  cl_qnt_gr_idnt_spl_ch_plot_png:
    type: File?
    outputSource: vdj_profile/cl_qnt_gr_idnt_spl_ch_plot_png
    label: "Percentage of unique clonotypes per dataset (split by chain, filtered by minimum frequency)"
    doc: |
      Percentage of unique clonotypes per dataset.
      Split by chain; filtered by minimum clonotype
      frequency per donor.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Grouped by dataset"
        Caption: "Percentage of unique clonotypes per dataset (split by chain, filtered by minimum frequency)"

  gene_gr_idnt_spl_ch_plot_png:
    type: File?
    outputSource: vdj_profile/gene_gr_idnt_spl_ch_plot_png
    label: "Distribution of gene usage per dataset (split by chain, filtered by minimum frequency)"
    doc: |
      Distribution of gene usage per dataset.
      Split by chain; filtered by minimum clonotype
      frequency per donor.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Grouped by dataset"
        Caption: "Distribution of gene usage per dataset (split by chain, filtered by minimum frequency)"

  cl_dnst_gr_idnt_spl_ch_plot_png:
    type: File?
    outputSource: vdj_profile/cl_dnst_gr_idnt_spl_ch_plot_png
    label: "Distribution of clonotype frequencies per dataset (split by chain, filtered by minimum frequency)"
    doc: |
      Distribution of clonotype frequencies per dataset.
      Split by chain; filtered by minimum clonotype
      frequency per donor.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Grouped by dataset"
        Caption: "Distribution of clonotype frequencies per dataset (split by chain, filtered by minimum frequency)"

  hmst_gr_dnr_spl_ch_plot_png:
    type: File?
    outputSource: vdj_profile/hmst_gr_dnr_spl_ch_plot_png
    label: "Proportion of clonotype frequencies per donor (split by chain, not filtered by minimum frequency)"
    doc: |
      Proportion of clonotype frequencies per donor.
      Split by chain; not filtered by clonotype frequency.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Grouped by donor"
        Caption: "Proportion of clonotype frequencies per donor (split by chain, not filtered by minimum frequency)"

  dvrs_gr_dnr_spl_ch_plot_png:
    type: File?
    outputSource: vdj_profile/dvrs_gr_dnr_spl_ch_plot_png
    label: "Diversity of clonotypes per donor (split by chain, not filtered by minimum frequency)"
    doc: |
      Diversity of clonotypes per donor.
      Split by chain; not filtered by clonotype frequency.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Grouped by donor"
        Caption: "Diversity of clonotypes per donor (split by chain, not filtered by minimum frequency)"

  vrlp_gr_dnr_spl_ch_plot_png:
    type: File?
    outputSource: vdj_profile/vrlp_gr_dnr_spl_ch_plot_png
    label: "Overlap of clonotypes between donors (split by chain, filtered by minimum frequency)"
    doc: |
      Overlap of clonotypes between donors.
      Split by chain; filtered by minimum clonotype
      frequency per donor.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Grouped by donor"
        Caption: "Overlap of clonotypes between donors (split by chain, filtered by minimum frequency)"

  allu_gr_dnr_spl_ch_plot_png:
    type: File?
    outputSource: vdj_profile/allu_gr_dnr_spl_ch_plot_png
    label: "Proportion of top shared clonotypes between donors (split by chain, filtered by minimum frequency)"
    doc: |
      Proportion of top shared clonotypes between donors.
      Split by chain; filtered by minimum clonotype
      frequency per donor; top clonotypes selected from
      each donor.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Grouped by donor"
        Caption: "Proportion of top shared clonotypes between donors (split by chain, filtered by minimum frequency)"

  cl_qnt_gr_dnr_spl_ch_plot_png:
    type: File?
    outputSource: vdj_profile/cl_qnt_gr_dnr_spl_ch_plot_png
    label: "Percentage of unique clonotypes per donor (split by chain, filtered by minimum frequency)"
    doc: |
      Percentage of unique clonotypes per donor.
      Split by chain; filtered by minimum clonotype
      frequency per donor.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Grouped by donor"
        Caption: "Percentage of unique clonotypes per donor (split by chain, filtered by minimum frequency)"

  gene_gr_dnr_spl_ch_plot_png:
    type: File?
    outputSource: vdj_profile/gene_gr_dnr_spl_ch_plot_png
    label: "Distribution of gene usage per donor (split by chain, filtered by minimum frequency)"
    doc: |
      Distribution of gene usage per donor.
      Split by chain; filtered by minimum clonotype
      frequency per donor.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Grouped by donor"
        Caption: "Distribution of gene usage per donor (split by chain, filtered by minimum frequency)"

  cl_dnst_gr_dnr_spl_ch_plot_png:
    type: File?
    outputSource: vdj_profile/cl_dnst_gr_dnr_spl_ch_plot_png
    label: "Distribution of clonotype frequencies per donor (split by chain, filtered by minimum frequency)"
    doc: |
      Distribution of clonotype frequencies per donor.
      Split by chain; filtered by minimum clonotype
      frequency per donor.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Grouped by donor"
        Caption: "Distribution of clonotype frequencies per donor (split by chain, filtered by minimum frequency)"

  hmst_gr_cnd_spl_ch_plot_png:
    type: File?
    outputSource: vdj_profile/hmst_gr_cnd_spl_ch_plot_png
    label: "Proportion of clonotype frequencies per grouping condition (split by chain, not filtered by minimum frequency)"
    doc: |
      Proportion of clonotype frequencies per
      grouping condition.
      Split by chain; not filtered by clonotype frequency.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Grouped by condition"
        Caption: "Proportion of clonotype frequencies per grouping condition (split by chain, not filtered by minimum frequency)"

  dvrs_gr_cnd_spl_ch_plot_png:
    type: File?
    outputSource: vdj_profile/dvrs_gr_cnd_spl_ch_plot_png
    label: "Diversity of clonotypes per grouping condition (split by chain, not filtered by minimum frequency)"
    doc: |
      Diversity of clonotypes per grouping condition.
      Split by chain; not filtered by clonotype frequency.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Grouped by condition"
        Caption: "Diversity of clonotypes per grouping condition (split by chain, not filtered by minimum frequency)"

  vrlp_gr_cnd_spl_ch_plot_png:
    type: File?
    outputSource: vdj_profile/vrlp_gr_cnd_spl_ch_plot_png
    label: "Overlap of clonotypes between grouping conditions (split by chain, filtered by minimum frequency)"
    doc: |
      Overlap of clonotypes between grouping conditions.
      Split by chain; filtered by minimum clonotype
      frequency per donor.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Grouped by condition"
        Caption: "Overlap of clonotypes between grouping conditions (split by chain, filtered by minimum frequency)"

  allu_gr_cnd_spl_ch_plot_png:
    type: File?
    outputSource: vdj_profile/allu_gr_cnd_spl_ch_plot_png
    label: "Proportion of top shared clonotypes between grouping conditions (split by chain, filtered by minimum frequency)"
    doc: |
      Proportion of top shared clonotypes between
      grouping conditions.
      Split by chain; filtered by minimum clonotype
      frequency per donor; top clonotypes selected from
      each grouping condition.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Grouped by condition"
        Caption: "Proportion of top shared clonotypes between grouping conditions (split by chain, filtered by minimum frequency)"

  cl_qnt_gr_cnd_spl_ch_plot_png:
    type: File?
    outputSource: vdj_profile/cl_qnt_gr_cnd_spl_ch_plot_png
    label: "Percentage of unique clonotypes per grouping condition (split by chain, filtered by minimum frequency)"
    doc: |
      Percentage of unique clonotypes per
      grouping condition.
      Split by chain; filtered by minimum clonotype
      frequency per donor.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Grouped by condition"
        Caption: "Percentage of unique clonotypes per grouping condition (split by chain, filtered by minimum frequency)"

  gene_gr_cnd_spl_ch_plot_png:
    type: File?
    outputSource: vdj_profile/gene_gr_cnd_spl_ch_plot_png
    label: "Distribution of gene usage per grouping condition (split by chain, filtered by minimum frequency)"
    doc: |
      Distribution of gene usage per grouping condition.
      Split by chain; filtered by minimum clonotype
      frequency per donor.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Grouped by condition"
        Caption: "Distribution of gene usage per grouping condition (split by chain, filtered by minimum frequency)"

  cl_dnst_gr_cnd_spl_ch_plot_png:
    type: File?
    outputSource: vdj_profile/cl_dnst_gr_cnd_spl_ch_plot_png
    label: "Distribution of clonotype frequencies per grouping condition (split by chain, filtered by minimum frequency)"
    doc: |
      Distribution of clonotype frequencies
      per grouping condition.
      Split by chain; filtered by minimum clonotype
      frequency per donor.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Grouped by condition"
        Caption: "Distribution of clonotype frequencies per grouping condition (split by chain, filtered by minimum frequency)"

  clonotypes_data_tsv:
    type: File?
    outputSource: vdj_profile/clonotypes_data_tsv
    label: "Clonotypes (filtered by minimum frequency)"
    doc: |
      Clonotypes data.
      Filtered by minimum clonotype
      frequency per donor.
      TSV format.
    "sd:visualPlugins":
    - syncfusiongrid:
        tab: "Clonotypes table"
        Title: "Clonotypes (filtered by minimum frequency)"

  ucsc_cb_html_data:
    type: Directory?
    outputSource: vdj_profile/ucsc_cb_html_data
    label: "UCSC Cell Browser (data)"
    doc: |
      UCSC Cell Browser html data.

  ucsc_cb_html_file:
    type: File?
    outputSource: vdj_profile/ucsc_cb_html_file
    label: "UCSC Cell Browser"
    doc: |
      UCSC Cell Browser html index.
    "sd:visualPlugins":
    - linkList:
        tab: "Overview"
        target: "_blank"

  seurat_data_rds:
    type: File
    outputSource: vdj_profile/seurat_data_rds
    label: "Seurat object in RDS format"
    doc: |
      Seurat object.
      RDS format.

  seurat_data_scope:
    type: File?
    outputSource: vdj_profile/seurat_data_scope
    label: "Seurat object in SCope compatible loom format"
    doc: |
      Seurat object.
      SCope compatible.
      Loom format.

  seurat_data_cloupe:
    type: File?
    outputSource: vdj_profile/seurat_data_cloupe
    label: "Seurat object in Loupe format"
    doc: |
      Seurat object.
      Loupe format.

  pdf_plots:
    type: File
    outputSource: compress_pdf_plots/compressed_folder
    label: "Compressed folder with all PDF plots"
    doc: |
      Compressed folder with all PDF plots.

  vdj_profile_stdout_log:
    type: File
    outputSource: vdj_profile/stdout_log
    label: "Output log"
    doc: |
      Stdout log from the vdj_profile step.

  vdj_profile_stderr_log:
    type: File
    outputSource: vdj_profile/stderr_log
    label: "Error log"
    doc: |
      Stderr log from the vdj_profile step.


steps:

  vdj_profile:
    run: ../tools/sc-vdj-profile.cwl
    in:
      query_data_rds: query_data_rds
      contigs_data: contigs_data
      datasets_metadata: datasets_metadata
      barcodes_data: barcodes_data
      cloneby: cloneby
      minimum_frequency: minimum_frequency
      filterby:
        source: filterby
        valueFrom: $(self=="none"?null:self)
      remove_partial: remove_partial
      color_theme: color_theme
      export_loupe_data: export_loupe_data
      export_pdf_plots:
        default: true
      verbose:
        default: true
      export_ucsc_cb:
        default: true
      export_scope_data:
        default: true
      parallel_memory_limit:
        default: 32
      vector_memory_limit:
        default: 96
      threads:
        source: threads
        valueFrom: $(parseInt(self))
    out:
    - cl_qnt_gr_idnt_spl_ch_plot_png
    - cl_dnst_gr_idnt_spl_ch_plot_png
    - allu_gr_idnt_spl_ch_plot_png
    - hmst_gr_idnt_spl_ch_plot_png
    - vrlp_gr_idnt_spl_ch_plot_png
    - dvrs_gr_idnt_spl_ch_plot_png
    - gene_gr_idnt_spl_ch_plot_png
    - umap_cl_freq_spl_ch_plot_png
    - cl_qnt_gr_dnr_spl_ch_plot_png
    - cl_dnst_gr_dnr_spl_ch_plot_png
    - allu_gr_dnr_spl_ch_plot_png
    - hmst_gr_dnr_spl_ch_plot_png
    - vrlp_gr_dnr_spl_ch_plot_png
    - dvrs_gr_dnr_spl_ch_plot_png
    - gene_gr_dnr_spl_ch_plot_png
    - cl_qnt_gr_cnd_spl_ch_plot_png
    - cl_dnst_gr_cnd_spl_ch_plot_png
    - allu_gr_cnd_spl_ch_plot_png
    - hmst_gr_cnd_spl_ch_plot_png
    - vrlp_gr_cnd_spl_ch_plot_png
    - dvrs_gr_cnd_spl_ch_plot_png
    - gene_gr_cnd_spl_ch_plot_png
    - all_plots_pdf
    - clonotypes_data_tsv
    - ucsc_cb_html_data
    - ucsc_cb_html_file
    - seurat_data_rds
    - seurat_data_cloupe
    - seurat_data_scope
    - stdout_log
    - stderr_log

  folder_pdf_plots:
    run: ../tools/files-to-folder.cwl
    in:
      input_files:
        source:
        - vdj_profile/all_plots_pdf
        valueFrom: $(self.flat().filter(n => n))
      folder_basename:
        default: "pdf_plots"
    out:
    - folder

  compress_pdf_plots:
    run: ../tools/tar-compress.cwl
    in:
      folder_to_compress: folder_pdf_plots/folder
    out:
    - compressed_folder


$namespaces:
  s: http://schema.org/

$schemas:
- https://github.com/schemaorg/schemaorg/raw/main/data/releases/11.01/schemaorg-current-http.rdf

label: "Single-Cell Immune Profiling Analysis"
s:name: "Single-Cell Immune Profiling Analysis"
s:alternateName: "Single-Cell Immune Profiling Analysis"

s:downloadUrl: https://raw.githubusercontent.com/Barski-lab/workflows-datirium/master/workflows/sc-vdj-profile.cwl
s:codeRepository: https://github.com/Barski-lab/workflows-datirium
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
  Single-Cell Immune Profiling Analysis

  Estimates clonotype diversity and dynamics from V(D)J
  sequencing data assembled into contigs.