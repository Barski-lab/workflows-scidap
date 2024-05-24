cwlVersion: v1.1
class: Workflow


requirements:
  - class: SubworkflowFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
    expressionLib:
    - var split_numbers = function(line) {
          let splitted_line = line?line.split(/[\s,]+/).map(parseFloat):null;
          return (splitted_line && !!splitted_line.length)?splitted_line:null;
      };


"sd:upstream":
  sc_sample:
  - "cellranger-atac-count.cwl"
  - "cellranger-atac-aggr.cwl"
  - "cellranger-arc-count.cwl"
  - "cellranger-arc-aggr.cwl"


inputs:

  alias_:
    type: string
    label: "Analysis name"
    sd:preview:
      position: 1

  filtered_feature_bc_matrix_folder:
    type: File
    label: "Cell Ranger ATAC or RNA+ATAC Sample"
    doc: |
      Any "Cell Ranger ATAC or RNA+ATAC
      Sample" that produces either only
      chromatin accessibility or both gene
      expression and chromatin accessibility
      data in a form of a single compressed
      feature-barcode matrix in a MEX
      format, ATAC fragments file in TSV
      format, and optional aggregation
      metadata file in TSV/CSV format.
      This sample can be obtained from
      "Cell Ranger Count (ATAC)",
      "Cell Ranger Count (RNA+ATAC)",
      "Cell Ranger Aggregate (ATAC)", or
      "Cell Ranger Aggregate (RNA+ATAC)"
      pipelines. If present, gene expression
      data will be discarded.
    "sd:upstreamSource": "sc_sample/filtered_feature_bc_matrix_folder"
    "sd:localLabel": true

  atac_fragments_file:
    type: File
    secondaryFiles:
    - .tbi
    "sd:upstreamSource": "sc_sample/atac_fragments_file"

  aggregation_metadata:
    type: File?
    "sd:upstreamSource": "sc_sample/aggregation_metadata"

  annotation_gtf_file:
    type: File
    "sd:upstreamSource": "sc_sample/genome_indices/genome_indices/annotation_gtf"

  chrom_length_file:
    type: File
    "sd:upstreamSource": "sc_sample/genome_indices/chrom_length_file"

  blacklist_regions_file:
    type:
    - "null"
    - type: enum
      symbols:
      - "hg19"
      - "hg38"
      - "mm10"
    "sd:upstreamSource": "sc_sample/genome_indices/genome_indices/genome"

  grouping_data:
    type: File?
    label: "Datasets grouping (optional)"
    doc: |
      If the selected "Cell Ranger ATAC or
      RNA+ATAC Sample" includes multiple
      aggregated datasets, each dataset can
      be assigned to a separate group by
      providing a TSV/CSV file with "library_id"
      and "condition" columns. Obtain this file
      from the "aggregation_metadata.csv"
      output generated by "Cell Ranger ATAC or
      RNA+ATAC Sample" and accessible on the
      "Files" tab. Remove all columns except
      the "library_id". Add the group names
      for each dataset in a separate column
      named "condition".

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
      from "Cell Ranger ATAC or RNA+ATAC Sample"
      and can be utilized in the current or
      future steps of analysis.

  call_by:
    type: string?
    default: ""
    label: "Cells grouping for MACS2 peak calling"
    doc: |
      Single cell metadata column to be used
      for cells grouping before using MACS2
      to replace 10x peaks with the new ones.
      To group cells by dataset, use "dataset".
      Custom groups can be defined based on
      any single cell metadata added through
      the "Selected cell barcodes (optional)"
      input. Default: use the original peaks
      generated by Cell Ranger ATAC or
      RNA+ATAC Sample.
    "sd:layout":
      advanced: true

  minimum_qvalue:
    type: float?
    default: 0.05
    label: "Minimum MACS2 FDR"
    doc: |
      Minimum FDR (q-value) cutoff for MACS2 peak
      detection. Ignored if "Cells grouping for
      MACS2 peak calling" input is not provided.
      Default: 0.05
    "sd:layout":
      advanced: true

  remove_doublets:
    type: boolean?
    default: false
    label: "Remove doublets"
    doc: |
      Quality control filtering parameter
      to remove cells identified as doublets.
      Default: do not remove
    "sd:layout":
      advanced: true

  minimum_fragments:
    type: string?
    default: "1000"
    label: "Minimum number of ATAC fragments in peaks per cell"
    doc: |
      Quality control filtering threshold
      to exclude from the analysis all
      cells with the number of ATAC fragments
      in peaks smaller than the provided
      value. If the selected "Cell Ranger
      ATAC or RNA+ATAC Sample" includes multiple
      aggregated datasets, each of them can
      be filtered independently by providing
      comma or space-separated list of filtering
      thresholds. The order and number of
      the specified values need to match
      with the datasets order from the
      "aggregation_metadata.csv" output
      generated by "Cell Ranger ATAC or
      RNA+ATAC Sample" and accessible on
      the "Files" tab. Any 0 will be replaced
      with the auto-estimated threshold
      (median - 2.5 * MAD) calculated per dataset.
      Default: 1000
    "sd:layout":
      advanced: true

  minimum_tss_enrich:
    type: string?
    default: "2"
    label: "Minimum TSS enrichment score per cell"
    doc: |
      Quality control filtering threshold
      to exclude from the analysis all
      cells with the TSS enrichment score
      smaller than the provided value.
      This QC metrics is calculated based
      on the ratio of ATAC fragments
      centered at the genes TSS to ATAC
      fragments in the TSS-flanking regions.
      If the selected "Cell Ranger ATAC or
      RNA+ATAC Sample" includes multiple
      aggregated datasets, each of them can
      be filtered independently by providing
      comma or space-separated list of
      filtering thresholds. The order and
      number of the specified values need
      to match with the datasets order from
      the "aggregation_metadata.csv" output
      generated by "Cell Ranger ATAC or
      RNA+ATAC Sample" and accessible on
      the "Files" tab.
      Default: 2
    "sd:layout":
      advanced: true

  minimum_frip:
    type: float?
    default: 0.15
    label: "Minimum FRiP per cell"
    doc: |
      Quality control filtering threshold
      to exclude from the analysis all
      cells with the FRiP (Fraction of
      Reads in Peaks) smaller than the
      provided value.
      Default: 0.15
    "sd:layout":
      advanced: true

  maximum_nucl_signal:
    type: string?
    default: "4"
    label: "Maximum nucleosome signal per cell"
    doc: |
      Quality control filtering threshold
      to exclude from the analysis all
      cells with the nucleosome signal
      higher than the provided value.
      Nucleosome signal is a measurement
      of nucleosome occupancy. It quantifies
      the approximate ratio of mononucleosomal
      to nucleosome-free ATAC fragments.
      If the selected "Cell Ranger ATAC or
      RNA+ATAC Sample" includes multiple
      aggregated datasets, each of them can
      be filtered independently by providing
      comma or space-separated list of
      filtering thresholds. The order and
      number of the specified values need
      to match with the datasets order from
      the "aggregation_metadata.csv" output
      generated by "Cell Ranger ATAC or
      RNA+ATAC Sample" and accessible on
      the "Files" tab.
      Default: 4
    "sd:layout":
      advanced: true

  maximum_blacklist_fraction:
    type: string?
    default: "0.05"
    label: "Maximum blacklist fraction per cell"
    doc: |
      Quality control filtering threshold
      to exclude from the analysis all
      cells with the fraction of ATAC
      fragments in genomic blacklist regions
      bigger than the provided value.
      If the selected "Cell Ranger ATAC or
      RNA+ATAC Sample" includes multiple
      aggregated datasets, each of them can
      be filtered independently by providing
      comma or space-separated list of
      filtering thresholds. The order and
      number of the specified values need
      to match with the datasets order from
      the "aggregation_metadata.csv" output
      generated by "Cell Ranger ATAC or
      RNA+ATAC Sample" and accessible on
      the "Files" tab.
      Default: 0.05
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

  raw_1_2_qc_mtrcs_pca_plot_png:
    type: File?
    outputSource: sc_atac_filter/raw_1_2_qc_mtrcs_pca_plot_png
    label: "QC metrics PCA (unfiltered, PC1/PC2)"
    doc: |
      QC metrics PCA.
      Unfiltered; PC1/PC2.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Unfiltered"
        Caption: "QC metrics PCA (unfiltered, PC1/PC2)"

  raw_2_3_qc_mtrcs_pca_plot_png:
    type: File?
    outputSource: sc_atac_filter/raw_2_3_qc_mtrcs_pca_plot_png
    label: "QC metrics PCA (unfiltered, PC2/PC3)"
    doc: |
      QC metrics PCA.
      Unfiltered; PC2/PC3.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Unfiltered"
        Caption: "QC metrics PCA (unfiltered, PC2/PC3)"

  raw_cell_cnts_plot_png:
    type: File?
    outputSource: sc_atac_filter/raw_cell_cnts_plot_png
    label: "Number of cells per dataset (unfiltered)"
    doc: |
      Number of cells per dataset.
      Unfiltered.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Unfiltered"
        Caption: "Number of cells per dataset (unfiltered)"

  raw_frgm_dnst_plot_png:
    type: File?
    outputSource: sc_atac_filter/raw_frgm_dnst_plot_png
    label: "Distribution of ATAC fragments in peaks per cell (unfiltered)"
    doc: |
      Distribution of ATAC fragments in peaks
      per cell.
      Unfiltered.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Unfiltered"
        Caption: "Distribution of ATAC fragments in peaks per cell (unfiltered)"

  raw_peak_dnst_plot_png:
    type: File?
    outputSource: sc_atac_filter/raw_peak_dnst_plot_png
    label: "Distribution of peaks per cell (unfiltered)"
    doc: |
      Distribution of peaks per cell.
      Unfiltered.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Unfiltered"
        Caption: "Distribution of peaks per cell (unfiltered)"

  raw_blck_dnst_plot_png:
    type: File?
    outputSource: sc_atac_filter/raw_blck_dnst_plot_png
    label: "Distribution of ATAC fragments within genomic blacklist regions per cell (unfiltered)"
    doc: |
      Distribution of ATAC fragments within
      genomic blacklist regions per cell.
      Unfiltered.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Unfiltered"
        Caption: "Distribution of ATAC fragments within genomic blacklist regions per cell (unfiltered)"

  raw_tss_frgm_plot_png:
    type: File?
    outputSource: sc_atac_filter/raw_tss_frgm_plot_png
    label: "TSS enrichment score vs ATAC fragments in peaks per cell (unfiltered)"
    doc: |
      TSS enrichment score vs ATAC
      fragments in peaks per cell.
      Unfiltered.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Unfiltered"
        Caption: "TSS enrichment score vs ATAC fragments in peaks per cell (unfiltered)"

  raw_qc_mtrcs_dnst_plot_png:
    type: File?
    outputSource: sc_atac_filter/raw_qc_mtrcs_dnst_plot_png
    label: "Distribution of QC metrics per cell (unfiltered)"
    doc: |
      Distribution of QC metrics per cell.
      Unfiltered.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Unfiltered"
        Caption: "Distribution of QC metrics per cell (unfiltered)"

  raw_atacdbl_plot_png:
    type: File?
    outputSource: sc_atac_filter/raw_atacdbl_plot_png
    label: "Percentage of ATAC doublets (unfiltered)"
    doc: |
      Percentage of ATAC doublets.
      Unfiltered.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Unfiltered"
        Caption: "Percentage of ATAC doublets (unfiltered)"

  raw_tss_nrch_plot_png:
    type: File?
    outputSource: sc_atac_filter/raw_tss_nrch_plot_png
    label: "Signal enrichment around TSS (unfiltered, split by the minimum TSS enrichment score threshold)"
    doc: |
      Signal enrichment around TSS.
      Unfiltered; split by the minimum
      TSS enrichment score threshold.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Unfiltered"
        Caption: "Signal enrichment around TSS (unfiltered, split by the minimum TSS enrichment score threshold)"

  raw_frgm_hist_png:
    type: File?
    outputSource: sc_atac_filter/raw_frgm_hist_png
    label: "Histogram of ATAC fragment length (unfiltered, split by the maximum nucleosome signal threshold)"
    doc: |
      Histogram of ATAC fragment length.
      Unfiltered; split by the maximum
      nucleosome signal threshold.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Unfiltered"
        Caption: "Histogram of ATAC fragment length (unfiltered, split by the maximum nucleosome signal threshold)"

  raw_frgm_dnst_spl_cnd_plot_png:
    type: File?
    outputSource: sc_atac_filter/raw_frgm_dnst_spl_cnd_plot_png
    label: "Distribution of ATAC fragments in peaks per cell (unfiltered, split by grouping condition)"
    doc: |
      Distribution of ATAC fragments in peaks
      per cell.
      Unfiltered; split by grouping condition.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Unfiltered, split by group"
        Caption: "Distribution of ATAC fragments in peaks per cell (unfiltered, split by grouping condition)"

  raw_peak_dnst_spl_cnd_plot_png:
    type: File?
    outputSource: sc_atac_filter/raw_peak_dnst_spl_cnd_plot_png
    label: "Distribution of peaks per cell (unfiltered, split by grouping condition)"
    doc: |
      Distribution of peaks per cell.
      Unfiltered; split by grouping condition.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Unfiltered, split by group"
        Caption: "Distribution of peaks per cell (unfiltered, split by grouping condition)"

  raw_blck_dnst_spl_cnd_plot_png:
    type: File?
    outputSource: sc_atac_filter/raw_blck_dnst_spl_cnd_plot_png
    label: "Distribution of ATAC fragments within genomic blacklist regions per cell (unfiltered, split by grouping condition)"
    doc: |
      Distribution of ATAC fragments within
      genomic blacklist regions per cell.
      Unfiltered; split by grouping condition.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Unfiltered, split by group"
        Caption: "Distribution of ATAC fragments within genomic blacklist regions per cell (unfiltered, split by grouping condition)"

  fltr_1_2_qc_mtrcs_pca_plot_png:
    type: File?
    outputSource: sc_atac_filter/fltr_1_2_qc_mtrcs_pca_plot_png
    label: "QC metrics PCA (filtered, PC1/PC2)"
    doc: |
      QC metrics PCA.
      Filtered; PC1/PC2.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Filtered"
        Caption: "QC metrics PCA (filtered, PC1/PC2)"

  fltr_2_3_qc_mtrcs_pca_plot_png:
    type: File?
    outputSource: sc_atac_filter/fltr_2_3_qc_mtrcs_pca_plot_png
    label: "QC metrics PCA (filtered, PC2/PC3)"
    doc: |
      QC metrics PCA.
      Filtered; PC2/PC3.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Filtered"
        Caption: "QC metrics PCA (filtered, PC2/PC3)"

  fltr_cell_cnts_plot_png:
    type: File?
    outputSource: sc_atac_filter/fltr_cell_cnts_plot_png
    label: "Number of cells per dataset (filtered)"
    doc: |
      Number of cells per dataset.
      Filtered.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Filtered"
        Caption: "Number of cells per dataset (filtered)"

  fltr_frgm_dnst_plot_png:
    type: File?
    outputSource: sc_atac_filter/fltr_frgm_dnst_plot_png
    label: "Distribution of ATAC fragments in peaks per cell (filtered)"
    doc: |
      Distribution of ATAC fragments in peaks
      per cell.
      Filtered.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Filtered"
        Caption: "Distribution of ATAC fragments in peaks per cell (filtered)"

  fltr_peak_dnst_plot_png:
    type: File?
    outputSource: sc_atac_filter/fltr_peak_dnst_plot_png
    label: "Distribution of peaks per cell (filtered)"
    doc: |
      Distribution of peaks per cell.
      Filtered.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Filtered"
        Caption: "Distribution of peaks per cell (filtered)"

  fltr_blck_dnst_plot_png:
    type: File?
    outputSource: sc_atac_filter/fltr_blck_dnst_plot_png
    label: "Distribution of ATAC fragments within genomic blacklist regions per cell (filtered)"
    doc: |
      Distribution of ATAC fragments within
      genomic blacklist regions per cell.
      Filtered.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Filtered"
        Caption: "Distribution of ATAC fragments within genomic blacklist regions per cell (filtered)"

  fltr_tss_frgm_plot_png:
    type: File?
    outputSource: sc_atac_filter/fltr_tss_frgm_plot_png
    label: "TSS enrichment score vs ATAC fragments in peaks per cell (filtered)"
    doc: |
      TSS enrichment score vs ATAC
      fragments in peaks per cell.
      Filtered.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Filtered"
        Caption: "TSS enrichment score vs ATAC fragments in peaks per cell (filtered)"

  fltr_qc_mtrcs_dnst_plot_png:
    type: File?
    outputSource: sc_atac_filter/fltr_qc_mtrcs_dnst_plot_png
    label: "Distribution of QC metrics per cell (filtered)"
    doc: |
      Distribution of QC metrics per cell.
      Filtered.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Filtered"
        Caption: "Distribution of QC metrics per cell (filtered)"

  fltr_atacdbl_plot_png:
    type: File?
    outputSource: sc_atac_filter/fltr_atacdbl_plot_png
    label: "Percentage of ATAC doublets (filtered)"
    doc: |
      Percentage of ATAC doublets.
      Filtered.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Filtered"
        Caption: "Percentage of ATAC doublets (filtered)"

  fltr_tss_nrch_plot_png:
    type: File?
    outputSource: sc_atac_filter/fltr_tss_nrch_plot_png
    label: "Signal enrichment around TSS (filtered, split by the minimum TSS enrichment score threshold)"
    doc: |
      Signal enrichment around TSS.
      Filtered; split by the minimum
      TSS enrichment score threshold.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Filtered"
        Caption: "Signal enrichment around TSS (filtered, split by the minimum TSS enrichment score threshold)"

  fltr_frgm_hist_png:
    type: File?
    outputSource: sc_atac_filter/fltr_frgm_hist_png
    label: "Histogram of ATAC fragment length (filtered, split by the maximum nucleosome signal threshold)"
    doc: |
      Histogram of ATAC fragment length.
      Filtered; split by the maximum
      nucleosome signal threshold.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Filtered"
        Caption: "Histogram of ATAC fragment length (filtered, split by the maximum nucleosome signal threshold)"

  fltr_frgm_dnst_spl_cnd_plot_png:
    type: File?
    outputSource: sc_atac_filter/fltr_frgm_dnst_spl_cnd_plot_png
    label: "Distribution of ATAC fragments in peaks per cell (filtered, split by grouping condition)"
    doc: |
      Distribution of ATAC fragments in peaks
      per cell.
      Filtered; split by grouping condition.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Filtered, split by group"
        Caption: "Distribution of ATAC fragments in peaks per cell (filtered, split by grouping condition)"

  fltr_peak_dnst_spl_cnd_plot_png:
    type: File?
    outputSource: sc_atac_filter/fltr_peak_dnst_spl_cnd_plot_png
    label: "Distribution of peaks per cell (filtered, split by grouping condition)"
    doc: |
      Distribution of peaks per cell.
      Filtered; split by grouping condition.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Filtered, split by group"
        Caption: "Distribution of peaks per cell (filtered, split by grouping condition)"

  fltr_blck_dnst_spl_cnd_plot_png:
    type: File?
    outputSource: sc_atac_filter/fltr_blck_dnst_spl_cnd_plot_png
    label: "Distribution of ATAC fragments within genomic blacklist regions per cell (filtered, split by grouping condition)"
    doc: |
      Distribution of ATAC fragments within
      genomic blacklist regions per cell.
      Filtered; split by grouping condition.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Filtered, split by group"
        Caption: "Distribution of ATAC fragments within genomic blacklist regions per cell (filtered, split by grouping condition)"

  ucsc_cb_html_data:
    type: Directory
    outputSource: sc_atac_filter/ucsc_cb_html_data
    label: "UCSC Cell Browser (data)"
    doc: |
      UCSC Cell Browser html data.

  ucsc_cb_html_file:
    type: File
    outputSource: sc_atac_filter/ucsc_cb_html_file
    label: "UCSC Cell Browser"
    doc: |
      UCSC Cell Browser html index.
    "sd:visualPlugins":
    - linkList:
        tab: "Overview"
        target: "_blank"

  seurat_data_rds:
    type: File
    outputSource: sc_atac_filter/seurat_data_rds
    label: "Seurat object in RDS format"
    doc: |
      Seurat object.
      RDS format.

  datasets_metadata:
    type: File
    outputSource: sc_atac_filter/datasets_metadata
    label: "Example of datasets metadata"
    doc: |
      Example of datasets metadata file
      in TSV format

  pdf_plots:
    type: File
    outputSource: compress_pdf_plots/compressed_folder
    label: "Compressed folder with all PDF plots"
    doc: |
      Compressed folder with all PDF plots.

  sc_atac_filter_stdout_log:
    type: File
    outputSource: sc_atac_filter/stdout_log
    label: "Output log"
    doc: |
      Stdout log from the sc_atac_filter step.

  sc_atac_filter_stderr_log:
    type: File
    outputSource: sc_atac_filter/stderr_log
    label: "Error log"
    doc: |
      Stderr log from the sc_atac_filter step.


steps:

  uncompress_feature_bc_matrices:
    run: ../tools/tar-extract.cwl
    in:
      file_to_extract: filtered_feature_bc_matrix_folder
    out:
    - extracted_folder

  sc_atac_filter:
    run: ../tools/sc-atac-filter.cwl
    in:
      feature_bc_matrices_folder: uncompress_feature_bc_matrices/extracted_folder
      aggregation_metadata: aggregation_metadata
      atac_fragments_file: atac_fragments_file
      annotation_gtf_file: annotation_gtf_file
      chrom_length_file: chrom_length_file
      grouping_data: grouping_data
      blacklist_regions_file: blacklist_regions_file
      barcodes_data: barcodes_data
      call_by:
        source: call_by
        valueFrom: |
          ${
            if (self == "dataset") {
              return "new.ident";
            } else if (self == "") {
              return null;
            } else {
              return self;
            }
          }
      minimum_qvalue: minimum_qvalue
      atac_minimum_cells:
        default: 1                          # will remove peaks that are not present in any of the cells
      minimum_fragments:
        source: minimum_fragments
        valueFrom: $(split_numbers(self))
      maximum_nucl_signal:
        source: maximum_nucl_signal
        valueFrom: $(split_numbers(self))
      minimum_tss_enrich:
        source: minimum_tss_enrich
        valueFrom: $(split_numbers(self))
      minimum_frip: minimum_frip
      maximum_blacklist_fraction:
        source: maximum_blacklist_fraction
        valueFrom: $(split_numbers(self))
      remove_doublets: remove_doublets
      verbose:
        default: true
      export_ucsc_cb:
        default: true
      export_pdf_plots:
        default: true
      color_theme: color_theme
      parallel_memory_limit:
        default: 32
      vector_memory_limit:
        default: 96
      threads:
        source: threads
        valueFrom: $(parseInt(self))
    out:
    - raw_1_2_qc_mtrcs_pca_plot_png
    - raw_2_3_qc_mtrcs_pca_plot_png
    - raw_cell_cnts_plot_png
    - raw_frgm_dnst_plot_png
    - raw_peak_dnst_plot_png
    - raw_blck_dnst_plot_png
    - raw_tss_frgm_plot_png
    - raw_qc_mtrcs_dnst_plot_png
    - raw_atacdbl_plot_png
    - raw_tss_nrch_plot_png
    - raw_frgm_hist_png
    - raw_frgm_dnst_spl_cnd_plot_png
    - raw_peak_dnst_spl_cnd_plot_png
    - raw_blck_dnst_spl_cnd_plot_png
    - fltr_1_2_qc_mtrcs_pca_plot_png
    - fltr_2_3_qc_mtrcs_pca_plot_png
    - fltr_cell_cnts_plot_png
    - fltr_frgm_dnst_plot_png
    - fltr_peak_dnst_plot_png
    - fltr_blck_dnst_plot_png
    - fltr_atacdbl_plot_png
    - fltr_tss_frgm_plot_png
    - fltr_qc_mtrcs_dnst_plot_png
    - fltr_tss_nrch_plot_png
    - fltr_frgm_hist_png
    - fltr_frgm_dnst_spl_cnd_plot_png
    - fltr_peak_dnst_spl_cnd_plot_png
    - fltr_blck_dnst_spl_cnd_plot_png
    - all_plots_pdf
    - ucsc_cb_html_data
    - ucsc_cb_html_file
    - seurat_data_rds
    - datasets_metadata
    - stdout_log
    - stderr_log

  folder_pdf_plots:
    run: ../tools/files-to-folder.cwl
    in:
      input_files:
        source:
        - sc_atac_filter/all_plots_pdf
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

label: "Single-Cell ATAC-Seq Filtering Analysis"
s:name: "Single-Cell ATAC-Seq Filtering Analysis"
s:alternateName: "Single-Cell ATAC-Seq Filtering Analysis"

s:downloadUrl: https://raw.githubusercontent.com/Barski-lab/workflows-datirium/master/workflows/sc-atac-filter.cwl
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
  Single-Cell ATAC-Seq Filtering Analysis

  Removes low-quality cells from the outputs of either the
  “Cell Ranger Count (ATAC)” or “Cell Ranger Aggregate (ATAC)”
  pipeline. The results of this workflow are used in the
  “Single-Cell ATAC-Seq Dimensionality Reduction Analysis”
  pipeline.