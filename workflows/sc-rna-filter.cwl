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
  sc_rna_sample:
  - "cellranger-aggr.cwl"
  - "single-cell-preprocess-cellranger.cwl"
  - "cellranger-multi.cwl"
  - "sc-format-transform.cwl"


inputs:

  alias:
    type: string
    label: "Analysis name"
    sd:preview:
      position: 1

  filtered_feature_bc_matrix_folder:
    type: File
    label: "Cell Ranger RNA or RNA+VDJ Sample"
    doc: |
      Any "Cell Ranger RNA or RNA+VDJ Sample"
      that produces gene expression data in
      a form of compressed feature-barcode
      matrix in a MEX format, optional annotated
      V(D)J contigs data, and optional aggregation
      metadata file in TSV/CSV format. This
      sample can be obtained from one of the
      following pipelines: "Cell Ranger Count
      (RNA)", "Cell Ranger Count (RNA+VDJ)",
      or "Cell Ranger Aggregate (RNA, RNA+VDJ)"
    "sd:upstreamSource": "sc_rna_sample/filtered_feature_bc_matrix_folder"
    "sd:localLabel": true

  aggregation_metadata:
    type: File?
    "sd:upstreamSource": "sc_rna_sample/aggregation_metadata"

  grouping_data:
    type: File?
    label: "Datasets grouping (optional)"
    doc: |
      If the selected "Cell Ranger RNA or
      RNA+VDJ Sample" includes multiple
      aggregated datasets, each dataset
      can be assigned to a separate group
      by providing a TSV/CSV file with
      "library_id" and "condition"
      columns. Obtain this file from
      the "aggregation_metadata.csv"
      output generated by "Cell Ranger
      Aggregate (RNA, RNA+VDJ)" and
      accessible on the "Files" tab. Remove
      all columns except the "library_id".
      Add the group names for each dataset
      in a separate column named "condition".

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
      from "Cell Ranger RNA or RNA+VDJ Sample"
      and can be utilized in the current or
      future steps of analysis.

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

  minimum_umis:
    type: string?
    default: "500"
    label: "Minimum number of RNA reads per cell"
    doc: |
      Quality control filtering threshold
      to exclude from the analysis all
      cells with the number of RNA reads
      smaller than the provided value.
      If the selected "Cell Ranger RNA or
      RNA+VDJ Sample" includes multiple
      aggregated datasets, each of them
      can be filtered independently by
      providing comma or space-separated
      list of filtering thresholds. The
      order and number of the specified
      values need to match with the datasets
      order from the "aggregation_metadata.csv"
      output generated by "Cell Ranger RNA or
      RNA+VDJ Sample" and accessible on the
      "Files" tab.
      Default: 500
    "sd:layout":
      advanced: true

  minimum_genes:
    type: string?
    default: "250"
    label: "Minimum number of genes per cell"
    doc: |
      Quality control filtering threshold
      to exclude from the analysis all
      cells with the number of expressed
      genes smaller than the provided value.
      If the selected "Cell Ranger RNA or
      RNA+VDJ Sample" includes multiple
      aggregated datasets, each of them
      can be filtered independently by
      providing comma or space-separated
      list of filtering thresholds. The
      order and number of the specified
      values need to match with the datasets
      order from the "aggregation_metadata.csv"
      output generated by "Cell Ranger RNA or
      RNA+VDJ Sample" and accessible on the
      "Files" tab.
      Default: 250
    "sd:layout":
      advanced: true

  maximum_genes:
    type: string?
    default: "5000"
    label: "Maximum number of genes per cell"
    doc: |
      Quality control filtering threshold
      to exclude from the analysis all
      cells with the number of expressed
      genes bigger than the provided value.
      If the selected "Cell Ranger RNA or
      RNA+VDJ Sample" includes multiple
      aggregated datasets, each of them
      can be filtered independently by
      providing comma or space-separated
      list of filtering thresholds. The
      order and number of the specified
      values need to match with the datasets
      order from the "aggregation_metadata.csv"
      output generated by "Cell Ranger RNA or
      RNA+VDJ Sample" and accessible on the
      "Files" tab.
      Default: 5000
    "sd:layout":
      advanced: true

  mito_pattern:
    type: string?
    default: "^mt-|^MT-"
    label: "Mitochondrial genes pattern"
    doc: |
      Regex pattern to identify mitochondrial
      genes based on their names.
      Default: "^mt-|^MT-"
    "sd:layout":
      advanced: true

  maximum_mito_perc:
    type: float?
    default: 5
    label: "Maximum mitochondrial percentage per cell"
    doc: |
      Quality control filtering threshold
      to exclude from the analysis all
      cells with the percentage of RNA reads
      mapped to mitochondrial genes exceeding
      the provided value.
      Default: 5
    "sd:layout":
      advanced: true

  minimum_novelty_score:
    type: string?
    default: "0.8"
    label: "Minimum novelty score per cell"
    doc: |
      Quality control filtering threshold
      to exclude from the analysis all
      cells with the novelty scores
      smaller than the provided value.
      This QC metrics indicates the overall
      transcriptomic dissimilarity of the
      cells and is calculated as the ratio
      of log10(Genes) to log10(RNA UMI).
      If the selected "Cell Ranger RNA or
      RNA+VDJ Sample" includes multiple
      aggregated datasets, each of them
      can be filtered independently by
      providing comma or space-separated
      list of filtering thresholds. The
      order and number of the specified
      values need to match with the datasets
      order from the "aggregation_metadata.csv"
      output generated by "Cell Ranger RNA or
      RNA+VDJ Sample" and accessible on the
      "Files" tab.
      tab. Default: 0.8
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
    label: "Color theme for all generated plots"
    doc: |
      Color theme for all generated plots. One of gray, bw, linedraw, light,
      dark, minimal, classic, void.
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
    label: "Number of cores/cpus to use"
    doc: |
      Parallelization parameter to define the
      number of cores/CPUs that can be utilized
      simultaneously.
      Default: 1
    "sd:layout":
      advanced: true


outputs:

  raw_1_2_qc_mtrcs_pca_plot_png:
    type: File?
    outputSource: sc_rna_filter/raw_1_2_qc_mtrcs_pca_plot_png
    label: "QC metrics PCA (1,2), raw"
    doc: |
      PC1 and PC2 from the QC metrics
      PCA for raw data
    "sd:visualPlugins":
    - image:
        tab: "Raw"
        Caption: "QC metrics PCA (1,2)"

  raw_2_3_qc_mtrcs_pca_plot_png:
    type: File?
    outputSource: sc_rna_filter/raw_2_3_qc_mtrcs_pca_plot_png
    label: "QC metrics PCA (2,3), raw"
    doc: |
      PC2 and PC3 from the QC metrics
      PCA for raw data
    "sd:visualPlugins":
    - image:
        tab: "Raw"
        Caption: "QC metrics PCA (2,3)"

  raw_cells_count_plot_png:
    type: File?
    outputSource: sc_rna_filter/raw_cells_count_plot_png
    label: "Cells per dataset, raw"
    doc: |
      Number of cells per dataset
      for raw data
    "sd:visualPlugins":
    - image:
        tab: "Raw"
        Caption: "Cells per dataset"

  raw_umi_dnst_plot_png:
    type: File?
    outputSource: sc_rna_filter/raw_umi_dnst_plot_png
    label: "RNA reads per cell, raw"
    doc: |
      RNA reads per cell density
      for raw data
    "sd:visualPlugins":
    - image:
        tab: "Raw"
        Caption: "RNA reads per cell"

  raw_gene_dnst_plot_png:
    type: File?
    outputSource: sc_rna_filter/raw_gene_dnst_plot_png
    label: "Genes per cell, raw"
    doc: |
      Genes per cell density
      for raw data
    "sd:visualPlugins":
    - image:
        tab: "Raw"
        Caption: "Genes per cell"

  raw_gene_umi_plot_png:
    type: File?
    outputSource: sc_rna_filter/raw_gene_umi_plot_png
    label: "Genes vs RNA reads, raw"
    doc: |
      Genes vs RNA reads per cell
      for raw data
    "sd:visualPlugins":
    - image:
        tab: "Raw"
        Caption: "Genes vs RNA reads"

  raw_mito_dnst_plot_png:
    type: File?
    outputSource: sc_rna_filter/raw_mito_dnst_plot_png
    label: "Mitochondrial percentage, raw"
    doc: |
      Percentage of RNA reads mapped to
      mitochondrial genes per cell density
      for raw data
    "sd:visualPlugins":
    - image:
        tab: "Raw"
        Caption: "Mitochondrial percentage"

  raw_nvlt_dnst_plot_png:
    type: File?
    outputSource: sc_rna_filter/raw_nvlt_dnst_plot_png
    label: "Novelty score, raw"
    doc: |
      Novelty score per cell density
      for raw data
    "sd:visualPlugins":
    - image:
        tab: "Raw"
        Caption: "Novelty score"

  raw_qc_mtrcs_dnst_plot_png:
    type: File?
    outputSource: sc_rna_filter/raw_qc_mtrcs_dnst_plot_png
    label: "Main QC metrics, raw"
    doc: |
      Main QC metrics per cell densities
      for raw data
    "sd:visualPlugins":
    - image:
        tab: "Raw"
        Caption: "Main QC metrics"

  raw_rnadbl_plot_png:
    type: File?
    outputSource: sc_rna_filter/raw_rnadbl_plot_png
    label: "RNA doublets, raw"
    doc: |
      Percentage of RNA doublets per
      dataset for raw data
    "sd:visualPlugins":
    - image:
        tab: "Raw"
        Caption: "RNA doublets"

  raw_umi_dnst_spl_cnd_plot_png:
    type: File?
    outputSource: sc_rna_filter/raw_umi_dnst_spl_cnd_plot_png
    label: "RNA reads per cell, raw, split by condition"
    doc: |
      Split by grouping condition RNA reads
      per cell density for raw data
    "sd:visualPlugins":
    - image:
        tab: "Raw, by condition"
        Caption: "RNA reads per cell"

  raw_gene_dnst_spl_cnd_plot_png:
    type: File?
    outputSource: sc_rna_filter/raw_gene_dnst_spl_cnd_plot_png
    label: "Genes per cell, raw, split by condition"
    doc: |
      Split by grouping condition genes
      per cell for raw data
    "sd:visualPlugins":
    - image:
        tab: "Raw, by condition"
        Caption: "Genes per cell"

  raw_mito_dnst_spl_cnd_plot_png:
    type: File?
    outputSource: sc_rna_filter/raw_mito_dnst_spl_cnd_plot_png
    label: "Mitochondrial percentage, raw, split by condition"
    doc: |
      Split by grouping condition the
      percentage of RNA reads mapped to
      mitochondrial genes per cell density
      for raw data
    "sd:visualPlugins":
    - image:
        tab: "Raw, by condition"
        Caption: "Mitochondrial percentage"

  raw_nvlt_dnst_spl_cnd_plot_png:
    type: File?
    outputSource: sc_rna_filter/raw_nvlt_dnst_spl_cnd_plot_png
    label: "Novelty score, raw, split by condition"
    doc: |
      Split by grouping condition the
      novelty score per cell density
      for raw data
    "sd:visualPlugins":
    - image:
        tab: "Raw, by condition"
        Caption: "Novelty score"

  fltr_1_2_qc_mtrcs_pca_plot_png:
    type: File?
    outputSource: sc_rna_filter/fltr_1_2_qc_mtrcs_pca_plot_png
    label: "QC metrics PCA (1,2), filtered"
    doc: |
      PC1 and PC2 from the QC metrics
      PCA for filtered data
    "sd:visualPlugins":
    - image:
        tab: "Filtered"
        Caption: "QC metrics PCA (1,2)"

  fltr_2_3_qc_mtrcs_pca_plot_png:
    type: File?
    outputSource: sc_rna_filter/fltr_2_3_qc_mtrcs_pca_plot_png
    label: "QC metrics PCA (2,3), filtered"
    doc: |
      PC2 and PC3 from the QC metrics
      PCA for filtered data
    "sd:visualPlugins":
    - image:
        tab: "Filtered"
        Caption: "QC metrics PCA (2,3)"

  fltr_cells_count_plot_png:
    type: File?
    outputSource: sc_rna_filter/fltr_cells_count_plot_png
    label: "Cells per dataset, filtered"
    doc: |
      Number of cells per dataset
      for filtered data
    "sd:visualPlugins":
    - image:
        tab: "Filtered"
        Caption: "Cells per dataset"

  fltr_umi_dnst_plot_png:
    type: File?
    outputSource: sc_rna_filter/fltr_umi_dnst_plot_png
    label: "RNA reads per cell, filtered"
    doc: |
      RNA reads per cell density
      for filtered data
    "sd:visualPlugins":
    - image:
        tab: "Filtered"
        Caption: "RNA reads per cell"

  fltr_gene_dnst_plot_png:
    type: File?
    outputSource: sc_rna_filter/fltr_gene_dnst_plot_png
    label: "Genes per cell, filtered"
    doc: |
      Genes per cell density
      for filtered data
    "sd:visualPlugins":
    - image:
        tab: "Filtered"
        Caption: "Genes per cell"

  fltr_gene_umi_plot_png:
    type: File?
    outputSource: sc_rna_filter/fltr_gene_umi_plot_png
    label: "Genes vs RNA reads, filtered"
    doc: |
      Genes vs RNA reads per cell
      for filtered data
    "sd:visualPlugins":
    - image:
        tab: "Filtered"
        Caption: "Genes vs RNA reads"

  fltr_mito_dnst_plot_png:
    type: File?
    outputSource: sc_rna_filter/fltr_mito_dnst_plot_png
    label: "Mitochondrial percentage, filtered"
    doc: |
      Percentage of RNA reads mapped to
      mitochondrial genes per cell density
      for filtered data
    "sd:visualPlugins":
    - image:
        tab: "Filtered"
        Caption: "Mitochondrial percentage"

  fltr_nvlt_dnst_plot_png:
    type: File?
    outputSource: sc_rna_filter/fltr_nvlt_dnst_plot_png
    label: "Novelty score, filtered"
    doc: |
      Novelty score per cell density
      for filtered data
    "sd:visualPlugins":
    - image:
        tab: "Filtered"
        Caption: "Novelty score"

  fltr_qc_mtrcs_dnst_plot_png:
    type: File?
    outputSource: sc_rna_filter/fltr_qc_mtrcs_dnst_plot_png
    label: "Main QC metrics, filtered"
    doc: |
      Main QC metrics per cell densities
      for filtered data
    "sd:visualPlugins":
    - image:
        tab: "Filtered"
        Caption: "Main QC metrics"

  fltr_rnadbl_plot_png:
    type: File?
    outputSource: sc_rna_filter/fltr_rnadbl_plot_png
    label: "RNA doublets, filtered"
    doc: |
      Percentage of RNA doublets per
      dataset for filtered data
    "sd:visualPlugins":
    - image:
        tab: "Filtered"
        Caption: "RNA doublets"

  fltr_umi_dnst_spl_cnd_plot_png:
    type: File?
    outputSource: sc_rna_filter/fltr_umi_dnst_spl_cnd_plot_png
    label: "RNA reads per cell, filtered, split by condition"
    doc: |
      Split by grouping condition RNA reads
      per cell density for filtered data
    "sd:visualPlugins":
    - image:
        tab: "Filtered, by condition"
        Caption: "RNA reads per cell"

  fltr_gene_dnst_spl_cnd_plot_png:
    type: File?
    outputSource: sc_rna_filter/fltr_gene_dnst_spl_cnd_plot_png
    label: "Genes per cell, filtered, split by condition"
    doc: |
      Split by grouping condition genes
      per cell for filtered data
    "sd:visualPlugins":
    - image:
        tab: "Filtered, by condition"
        Caption: "Genes per cell"

  fltr_mito_dnst_spl_cnd_plot_png:
    type: File?
    outputSource: sc_rna_filter/fltr_mito_dnst_spl_cnd_plot_png
    label: "Mitochondrial percentage, filtered, split by condition"
    doc: |
      Split by grouping condition the
      percentage of RNA reads mapped to
      mitochondrial genes per cell density
      for filtered data
    "sd:visualPlugins":
    - image:
        tab: "Filtered, by condition"
        Caption: "Mitochondrial percentage"

  fltr_nvlt_dnst_spl_cnd_plot_png:
    type: File?
    outputSource: sc_rna_filter/fltr_nvlt_dnst_spl_cnd_plot_png
    label: "Novelty score, filtered, split by condition"
    doc: |
      Split by grouping condition the
      novelty score per cell density
      for filtered data
    "sd:visualPlugins":
    - image:
        tab: "Filtered, by condition"
        Caption: "Novelty score"

  ucsc_cb_html_data:
    type: Directory
    outputSource: sc_rna_filter/ucsc_cb_html_data
    label: "UCSC Cell Browser data"
    doc: |
      Directory with UCSC Cell Browser
      data

  ucsc_cb_html_file:
    type: File
    outputSource: sc_rna_filter/ucsc_cb_html_file
    label: "UCSC Cell Browser"
    doc: |
      UCSC Cell Browser HTML index file
    "sd:visualPlugins":
    - linkList:
        tab: "Overview"
        target: "_blank"

  seurat_data_rds:
    type: File
    outputSource: sc_rna_filter/seurat_data_rds
    label: "Processed seurat data in RDS format"
    doc: |
      Processed seurat data in RDS format

  datasets_metadata:
    type: File
    outputSource: sc_rna_filter/datasets_metadata
    label: "Example of datasets metadata"
    doc: |
      Example of datasets metadata file
      in TSV format

  pdf_plots:
    type: File
    outputSource: compress_pdf_plots/compressed_folder
    label: "Plots in PDF format"
    doc: |
      Compressed folder with plots
      in PDF format

  sc_rna_filter_stdout_log:
    type: File
    outputSource: sc_rna_filter/stdout_log
    label: "Output log, filtering step"
    doc: |
      stdout log generated by
      sc_rna_filter step

  sc_rna_filter_stderr_log:
    type: File
    outputSource: sc_rna_filter/stderr_log
    label: "Error log, filtering step"
    doc: |
      stderr log generated by
      sc_rna_filter step


steps:

  uncompress_feature_bc_matrices:
    doc: |
      Extracts the content of TAR file into a folder
    run: ../tools/tar-extract.cwl
    in:
      file_to_extract: filtered_feature_bc_matrix_folder
    out:
    - extracted_folder

  sc_rna_filter:
    doc: |
      Filters single-cell RNA-Seq datasets based on the common QC metrics
    run: ../tools/sc-rna-filter.cwl
    in:
      feature_bc_matrices_folder: uncompress_feature_bc_matrices/extracted_folder
      aggregation_metadata: aggregation_metadata
      grouping_data: grouping_data
      barcodes_data: barcodes_data
      rna_minimum_cells:
        default: 1
      minimum_genes:
        source: minimum_genes
        valueFrom: $(split_numbers(self))
      maximum_genes: 
        source: maximum_genes
        valueFrom: $(split_numbers(self))
      minimum_umis:
        source: minimum_umis
        valueFrom: $(split_numbers(self))
      minimum_novelty_score:
        source: minimum_novelty_score
        valueFrom: $(split_numbers(self))
      mito_pattern: mito_pattern
      maximum_mito_perc: maximum_mito_perc
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
    - raw_cells_count_plot_png
    - raw_umi_dnst_plot_png
    - raw_gene_dnst_plot_png
    - raw_gene_umi_plot_png
    - raw_mito_dnst_plot_png
    - raw_nvlt_dnst_plot_png
    - raw_qc_mtrcs_dnst_plot_png
    - raw_rnadbl_plot_png
    - raw_umi_dnst_spl_cnd_plot_png
    - raw_gene_dnst_spl_cnd_plot_png
    - raw_mito_dnst_spl_cnd_plot_png
    - raw_nvlt_dnst_spl_cnd_plot_png
    - fltr_1_2_qc_mtrcs_pca_plot_png
    - fltr_2_3_qc_mtrcs_pca_plot_png
    - fltr_cells_count_plot_png
    - fltr_umi_dnst_plot_png
    - fltr_gene_dnst_plot_png
    - fltr_gene_umi_plot_png
    - fltr_mito_dnst_plot_png
    - fltr_nvlt_dnst_plot_png
    - fltr_qc_mtrcs_dnst_plot_png
    - fltr_rnadbl_plot_png
    - fltr_umi_dnst_spl_cnd_plot_png
    - fltr_gene_dnst_spl_cnd_plot_png
    - fltr_mito_dnst_spl_cnd_plot_png
    - fltr_nvlt_dnst_spl_cnd_plot_png
    - raw_1_2_qc_mtrcs_pca_plot_pdf
    - raw_2_3_qc_mtrcs_pca_plot_pdf
    - raw_cells_count_plot_pdf
    - raw_umi_dnst_plot_pdf
    - raw_gene_dnst_plot_pdf
    - raw_gene_umi_plot_pdf
    - raw_mito_dnst_plot_pdf
    - raw_nvlt_dnst_plot_pdf
    - raw_qc_mtrcs_dnst_plot_pdf
    - raw_rnadbl_plot_pdf
    - raw_umi_dnst_spl_cnd_plot_pdf
    - raw_gene_dnst_spl_cnd_plot_pdf
    - raw_mito_dnst_spl_cnd_plot_pdf
    - raw_nvlt_dnst_spl_cnd_plot_pdf
    - fltr_1_2_qc_mtrcs_pca_plot_pdf
    - fltr_2_3_qc_mtrcs_pca_plot_pdf
    - fltr_cells_count_plot_pdf
    - fltr_umi_dnst_plot_pdf
    - fltr_gene_dnst_plot_pdf
    - fltr_gene_umi_plot_pdf
    - fltr_mito_dnst_plot_pdf
    - fltr_nvlt_dnst_plot_pdf
    - fltr_qc_mtrcs_dnst_plot_pdf
    - fltr_rnadbl_plot_pdf
    - fltr_umi_dnst_spl_cnd_plot_pdf
    - fltr_gene_dnst_spl_cnd_plot_pdf
    - fltr_mito_dnst_spl_cnd_plot_pdf
    - fltr_nvlt_dnst_spl_cnd_plot_pdf
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
        - sc_rna_filter/raw_1_2_qc_mtrcs_pca_plot_pdf
        - sc_rna_filter/raw_2_3_qc_mtrcs_pca_plot_pdf
        - sc_rna_filter/raw_cells_count_plot_pdf
        - sc_rna_filter/raw_umi_dnst_plot_pdf
        - sc_rna_filter/raw_gene_dnst_plot_pdf
        - sc_rna_filter/raw_gene_umi_plot_pdf
        - sc_rna_filter/raw_mito_dnst_plot_pdf
        - sc_rna_filter/raw_nvlt_dnst_plot_pdf
        - sc_rna_filter/raw_qc_mtrcs_dnst_plot_pdf
        - sc_rna_filter/raw_rnadbl_plot_pdf
        - sc_rna_filter/raw_umi_dnst_spl_cnd_plot_pdf
        - sc_rna_filter/raw_gene_dnst_spl_cnd_plot_pdf
        - sc_rna_filter/raw_mito_dnst_spl_cnd_plot_pdf
        - sc_rna_filter/raw_nvlt_dnst_spl_cnd_plot_pdf
        - sc_rna_filter/fltr_1_2_qc_mtrcs_pca_plot_pdf
        - sc_rna_filter/fltr_2_3_qc_mtrcs_pca_plot_pdf
        - sc_rna_filter/fltr_cells_count_plot_pdf
        - sc_rna_filter/fltr_umi_dnst_plot_pdf
        - sc_rna_filter/fltr_gene_dnst_plot_pdf
        - sc_rna_filter/fltr_gene_umi_plot_pdf
        - sc_rna_filter/fltr_mito_dnst_plot_pdf
        - sc_rna_filter/fltr_nvlt_dnst_plot_pdf
        - sc_rna_filter/fltr_qc_mtrcs_dnst_plot_pdf
        - sc_rna_filter/fltr_rnadbl_plot_pdf
        - sc_rna_filter/fltr_umi_dnst_spl_cnd_plot_pdf
        - sc_rna_filter/fltr_gene_dnst_spl_cnd_plot_pdf
        - sc_rna_filter/fltr_mito_dnst_spl_cnd_plot_pdf
        - sc_rna_filter/fltr_nvlt_dnst_spl_cnd_plot_pdf
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

label: "Single-Cell RNA-Seq Filtering Analysis"
s:name: "Single-Cell RNA-Seq Filtering Analysis"
s:alternateName: "Removes low-quality cells"

s:downloadUrl: https://raw.githubusercontent.com/Barski-lab/workflows-datirium/master/workflows/sc-rna-filter.cwl
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
  Single-Cell RNA-Seq Filtering Analysis

  Removes low-quality cells from the outputs of “Cell Ranger Count (RNA)”,
  “Cell Ranger Count (RNA+VDJ)”, and “Cell Ranger Aggregate (RNA, RNA+VDJ)”
  pipelines. The results of this workflow are primarily used in “Single-Cell
  RNA-Seq Dimensionality Reduction Analysis” pipeline.