cwlVersion: v1.0
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
  sc_tools_sample:
  - "sc-rna-cluster.cwl"
  - "sc-atac-cluster.cwl"
  - "sc-wnn-cluster.cwl"
  - "sc-ctype-assign.cwl"


inputs:

  alias:
    type: string
    label: "Analysis name"
    sd:preview:
      position: 1

  query_data_rds:
    type: File
    label: "Single-cell Analysis with Clustered RNA/ATAC-Seq or WNN Datasets"
    doc: |
      Analysis that includes single-cell
      multiome RNA and ATAC-Seq or just
      RNA-Seq datasets run through either
      "Single-Cell Manual Cell Type
      Assignment", "Single-Cell RNA-Seq
      Cluster Analysis", "Single-Cell
      ATAC-Seq Cluster Analysis", or
      "Single-Cell WNN Cluster Analysis"
      at any of the processing stages.
    "sd:upstreamSource": "sc_tools_sample/seurat_data_rds"
    "sd:localLabel": true

  query_reduction:
    type:
    - "null"
    - type: enum
      symbols:
      - "RNA"
      - "ATAC"
      - "WNN"
    default: "RNA"
    label: "Dimensionality reduction"
    doc: |
      Dimensionality reduction to be used
      for generating UMAP plots.

  dimensions:
    type: int?
    default: 10
    label: "Dimensionality to be used when running differential abundance analysis (from 1 to 50)"
    doc: |
      Dimensionality to be used when running differential
      abundance analysis with DAseq (from 1 to 50).
      Default: 10

  groupby:
    type: string
    label: "Grouping category (cluster, cell type, etc.)"
    doc: |
      Single cell metadata column to group
      cells by categories, such as clusters,
      cell types, etc., when generating UMAP
      and composition plots. Custom groups
      can be defined based on any single cell
      metadata added through the "Datasets
      metadata (optional)" or "Selected cell
      barcodes (optional)"
      inputs.

  splitby:
    type: string
    label: "Comparison category"
    doc: |
      Single cell metadata column to split
      cells into two comparison groups before
      running differential abundance analysis.
      To split cells by dataset, use "dataset".
      Custom groups can be defined based on
      any single cell metadata added through
      the "Datasets metadata (optional)" or
      "Selected cell barcodes (optional)"
      inputs. The direction of comparison is
      always "Second comparison group" vs
      "First comparison group".

  first_cond:
    type: string
    label: "First comparison group"
    doc: |
      Value from the single cell metadata
      column selected in "Comparison category"
      input to define the first group of cells
      for differential abundance analysis.

  second_cond:
    type: string
    label: "Second comparison group"
    doc: |
      Value from the single cell metadata
      column selected in "Comparison category"
      input to define the second group of cells
      for differential abundance analysis.

  ranges:
    type: string?
    default: ""
    label: "Minimum and maximum thresholds for differential abundance scores"
    doc: |
      Minimum and maximum thresholds to filter
      out cells with the low (by absolute
      values) differential abundance scores.
      Can be set in a form of a comma- or
      space-separated list.
      Default: calculated based on the
      permutation test.

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
      grouping categories.

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
      RNA/ATAC-Seq or WNN Datasets" and can be
      utilized in the current or future steps
      of the analysis.

  export_loupe_data:
    type: boolean?
    default: false
    label: "Save raw counts to Loupe file. I confirm that data is generated by 10x technology and accept the EULA available at https://10xgen.com/EULA"
    doc: |
      Save raw counts from the RNA assay to Loupe file. By
      enabling this feature you accept the End-User License
      Agreement available at https://10xgen.com/EULA.
      Default: false
    "sd:layout":
      advanced: true

  export_html_report:
    type: boolean?
    default: true
    label: "Show HTML report"
    doc: |
      Export tehcnical report in HTML format.
      Default: true
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
      Default: 6
    "sd:layout":
      advanced: true


outputs:

  umap_gr_tst_plot_png:
    type: File?
    outputSource: da_cells/umap_gr_tst_plot_png
    label: "UMAP colored by tested condition (downsampled)"
    doc: |
      UMAP colored by tested condition. First downsampled
      to the smallest dataset, then downsampled to the
      smallest tested condition group.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "QC"
        Caption: "UMAP colored by tested condition (downsampled)"

  umap_da_scr_cnt_plot_png:
    type: File?
    outputSource: da_cells/umap_da_scr_cnt_plot_png
    label: "UMAP colored by differential abundance score (all cells, continuous scale)"
    doc: |
      UMAP colored by differential abundance score,
      continuous scale. All cells.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "QC"
        Caption: "UMAP colored by differential abundance score (all cells, continuous scale)"

  rank_da_scr_plot_png:
    type: File?
    outputSource: da_cells/rank_da_scr_plot_png
    label: "Estimated thresholds for differential abundance score (all cells)"
    doc: |
      Estimated thresholds for
      differential abundance score.
      All cells.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "QC"
        Caption: "Estimated thresholds for differential abundance score (all cells)"

  umap_da_scr_ctg_plot_png:
    type: File?
    outputSource: da_cells/umap_da_scr_ctg_plot_png
    label: "UMAP colored by differential abundance score (all cells, categorical scale)"
    doc: |
      UMAP colored by differential abundance score,
      categorical scale. All cells; categories are
      defined based on the selected ranges for
      the differential abundance score.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "QC"
        Caption: "UMAP colored by differential abundance score (all cells, categorical scale)"

  umap_gr_clst_spl_tst_plot_png:
    type: File?
    outputSource: da_cells/umap_gr_clst_spl_tst_plot_png
    label: "UMAP colored by cluster (split by tested condition, downsampled)"
    doc: |
      UMAP colored by cluster. Split by tested condition;
      first downsampled to the smallest dataset, then
      downsampled to the smallest tested condition group.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Composition"
        Caption: "UMAP colored by cluster (split by tested condition, downsampled)"

  cmp_gr_tst_spl_clst_plot_png:
    type: File?
    outputSource: da_cells/cmp_gr_tst_spl_clst_plot_png
    label: "Composition plot colored by tested condition (split by cluster, downsampled)"
    doc: |
      Composition plot colored by tested condition. Split by
      cluster; first downsampled to the smallest dataset,
      then downsampled to the smallest tested condition group.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Composition"
        Caption: "Composition plot colored by tested condition (split by cluster, downsampled)"

  cmp_gr_clst_spl_tst_plot_png:
    type: File?
    outputSource: da_cells/cmp_gr_clst_spl_tst_plot_png
    label: "Composition plot colored by cluster (split by tested condition, downsampled)"
    doc: |
      Composition plot colored by cluster. Split by tested
      condition; first downsampled to the smallest dataset,
      then downsampled to the smallest tested condition group.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Composition"
        Caption: "Composition plot colored by cluster (split by tested condition, downsampled)"

  cmp_bp_gr_tst_spl_clst_plot_png:
    type: File?
    outputSource: da_cells/cmp_bp_gr_tst_spl_clst_plot_png
    label: "Composition box plot colored by tested condition (split by cluster, downsampled)"
    doc: |
      Composition box plot colored by tested condition.
      Split by cluster; downsampled to the smallest
      dataset. P-values were adjusted by the Benjamini–
      Hochberg procedure.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Composition"
        Caption: "Composition box plot colored by tested condition (split by cluster, downsampled)"

  ucsc_cb_html_data:
    type: Directory?
    outputSource: da_cells/ucsc_cb_html_data
    label: "UCSC Cell Browser (data)"
    doc: |
      UCSC Cell Browser html data.

  ucsc_cb_html_file:
    type: File?
    outputSource: da_cells/ucsc_cb_html_file
    label: "UCSC Cell Browser"
    doc: |
      UCSC Cell Browser html index.
    "sd:visualPlugins":
    - linkList:
        tab: "Overview"
        target: "_blank"

  seurat_data_rds:
    type: File
    outputSource: da_cells/seurat_data_rds
    label: "Seurat object in RDS format"
    doc: |
      Seurat object.
      RDS format.

  seurat_data_scope:
    type: File?
    outputSource: da_cells/seurat_data_scope
    label: "Seurat object in SCope compatible loom format"
    doc: |
      Seurat object.
      SCope compatible.
      Loom format.

  seurat_rna_data_cloupe:
    type: File?
    outputSource: da_cells/seurat_rna_data_cloupe
    label: "Seurat object in Loupe format"
    doc: |
      Seurat object.
      RNA counts.
      Loupe format.

  pdf_plots:
    type: File
    outputSource: compress_pdf_plots/compressed_folder
    label: "Compressed folder with all PDF plots"
    doc: |
      Compressed folder with all PDF plots.

  sc_report_html_file:
    type: File?
    outputSource: da_cells/sc_report_html_file
    label: "Analysis log"
    doc: |
      Tehcnical report.
      HTML format.
    "sd:visualPlugins":
    - linkList:
        tab: "Overview"
        target: "_blank"

  da_cells_human_log:
    type: File
    outputSource: da_cells/human_log
    label: "Human readable error log"
    doc: |
      Human readable error log
      from the da_cells step.

  da_cells_stdout_log:
    type: File
    outputSource: da_cells/stdout_log
    label: "Output log"
    doc: |
      Stdout log from the da_cells step.

  da_cells_stderr_log:
    type: File
    outputSource: da_cells/stderr_log
    label: "Error log"
    doc: |
      Stderr log from the da_cells step.


steps:

  da_cells:
    run: ../tools/sc-rna-da-cells.cwl
    in:
      query_data_rds: query_data_rds
      reduction:
        source: query_reduction
        valueFrom: |
          ${
            if (self == "RNA") {
              return "rnaumap";
            } else if (self == "ATAC") {
              return "atacumap";
            } else {
              return "wnnumap";
            }
          }
      dimensions: dimensions
      datasets_metadata: datasets_metadata
      barcodes_data: barcodes_data
      splitby:
        source: splitby
        valueFrom: |
          ${
            if (self == "dataset") {
              return "new.ident";
            } else {
              return self;
            }
          }
      first_cond: first_cond
      second_cond: second_cond
      groupby: groupby
      ranges:
        source: ranges
        valueFrom: $(split_numbers(self))    # "" will return null from split_numbers
      verbose:
        default: true
      export_ucsc_cb:
        default: true
      export_scope_data:
        default: true
      export_loupe_data: export_loupe_data
      export_pdf_plots:
        default: true
      color_theme: color_theme
      parallel_memory_limit:
        default: 32
      vector_memory_limit:
        default: 128
      export_html_report: export_html_report
      threads:
        source: threads
        valueFrom: $(parseInt(self))
    out:
      - cmp_bp_gr_tst_spl_clst_plot_png
      - umap_gr_tst_plot_png
      - umap_da_scr_ctg_plot_png
      - umap_da_scr_cnt_plot_png
      - umap_gr_clst_spl_tst_plot_png
      - cmp_gr_clst_spl_tst_plot_png
      - cmp_gr_tst_spl_clst_plot_png
      - rank_da_scr_plot_png

      - all_plots_pdf
      - ucsc_cb_html_data
      - ucsc_cb_html_file
      - seurat_data_rds
      - seurat_data_scope
      - seurat_rna_data_cloupe
      - sc_report_html_file
      - human_log
      - stdout_log
      - stderr_log

  folder_pdf_plots:
    run: ../tools/files-to-folder.cwl
    in:
      input_files:
        source:
        - da_cells/all_plots_pdf
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

label: "Single-Cell Differential Abundance Analysis"
s:name: "Single-Cell Differential Abundance Analysis"
s:alternateName: "Single-Cell Differential Abundance Analysis"

s:downloadUrl: https://raw.githubusercontent.com/Barski-lab/workflows-datirium/master/workflows/sc-rna-da-cells.cwl
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
  Single-Cell Differential Abundance Analysis

  Compares the composition of cell types between
  two tested conditions