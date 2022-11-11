cwlVersion: v1.0
class: Workflow


requirements:
  - class: SubworkflowFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: MultipleInputFeatureRequirement


'sd:upstream':
  kb_indices:
  - "kb-ref.cwl"


inputs:

  alias:
    type: string
    label: "Experiment short name/alias"
    sd:preview:
      position: 1

  kallisto_index_file:
    type: File
    label: "Kallisto | BUStools Indices"
    doc: |
      kallisto | bustools index file
    'sd:upstreamSource': "kb_indices/kallisto_index_file"
    'sd:localLabel': true

  tx_to_gene_mapping_file:
    type: File
    label: "Kallisto | BUStools Indices"
    doc: |
      Transcript-to-gene mapping TSV file
    'sd:upstreamSource': "kb_indices/tx_to_gene_mapping_file"
    'sd:localLabel': true

  tx_to_capture_mapping_file:
    type: File?
    label: "Kallisto | BUStools Indices"
    doc: |
      Transcripts-to-capture mapping TSV file
    'sd:upstreamSource': "kb_indices/tx_to_capture_mapping_file"
    'sd:localLabel': true

  intron_tx_to_capture_mapping_file:
    type: File?
    label: "Kallisto | BUStools Indices"
    doc: |
      Intron transcripts-to-capture mapping TSV file
    'sd:upstreamSource': "kb_indices/intron_tx_to_capture_mapping_file"
    'sd:localLabel': true

  sc_technology:
    type:
    - type: enum
      name: "sc_technology"
      symbols:
      - "none"
      - "10XV2"       # 2 input files
      - "10XV3"       # 2 input files
      - "CELSEQ"      # 2 input files
      - "CELSEQ2"     # 2 input files
      - "DROPSEQ"     # 2 input files
      - "INDROPSV1"   # 2 input files
      - "INDROPSV2"   # 2 input files
      - "SCRUBSEQ"    # 2 input files
      - "SURECELL"    # 2 input files
    default: "10XV3"
    label: "Single-cell technology used"
    doc: "Single-cell technology used"

  whitelist_barcodes:
    type: File?
    label: "Custom whitelisted barcodes to correct to"
    doc: |
      Path to file of whitelisted barcodes to correct to. If not provided and bustools
      supports the technology, a pre-packaged whitelist is used. If not, the bustools
      whitelist command is used. (`kb --list` to view whitelists)

  workflow_type:
    type:
    - "null"
    - type: enum
      name: "workflow_type"
      symbols:
      - standard
      - lamanno
      - nucleus
      - kite
    default: "lamanno"
    label: "Workflow type"
    doc: |
      Type of workflow. Use lamanno to calculate RNA velocity based
      on La Manno et al. 2018 logic. Use nucleus to calculate RNA
      velocity on single-nucleus RNA-seq reads.
      Default: standard

  fastq_file_r1:
    type:
    - File
    - type: array
      items: File
    label: "FASTQ file(s) R1 (optionally compressed)"
    doc: "FASTQ file(s) R1 (optionally compressed)"

  fastq_file_r2:
    type:
    - File
    - type: array
      items: File
    label: "FASTQ file(s) R2 (optionally compressed)"
    doc: "FASTQ file(s) R2 (optionally compressed)"

  threads:
    type: int?
    default: 4
    label: "Number of threads"
    doc: "Number of threads for those steps that support multithreading"
    'sd:layout':
      advanced: true

  memory_limit:
    type: string?
    default: "4G"
    label: "Maximum memory used"
    doc: "Maximum memory used"
    'sd:layout':
      advanced: true


outputs:

  counts_unfiltered_folder:
    type: File
    outputSource: compress_counts_folder/compressed_folder
    label: "Compressed folder with count matrix files"
    doc: |
      Compressed folder with count matrix files generated by bustools count

  unfiltered_adata_file:
    type: File
    outputSource: kb_count/unfiltered_adata_file
    label: "h5ad file generated from unfiltered count matrix"
    doc: |
      h5ad file generated from unfiltered count matrix

  whitelist_file:
    type: File?
    outputSource: kb_count/whitelist_file
    label: "Whitelisted barcodes"
    doc: |
      Whitelisted barcodes that correspond to the used single-cell technology

  bustools_inspect_report:
    type: File
    outputSource: kb_count/bustools_inspect_report
    label: "Report summarizing BUS file content"
    doc: |
      Report summarizing BUS file content generated by bustools inspect

  collected_statistics:
    type: File
    outputSource: collect_statistics/collected_statistics
    label: "Collected statistics in Markdown format"
    doc: "Collected statistics in Markdown format"
    'sd:visualPlugins':
    - markdownView:
        tab: 'Overview'

  kallisto_bus_report:
    type: File
    outputSource: kb_count/kallisto_bus_report
    label: "Pseudoalignment report"
    doc: |
      Pseudoalignment report generated by kallisto bus

  ec_mapping_file:
    type: File
    outputSource: kb_count/ec_mapping_file
    label: "Mapping equivalence classes to transcripts"
    doc: |
      Mapping equivalence classes to transcripts generated by kallisto bus

  transcripts_file:
    type: File
    outputSource: kb_count/transcripts_file
    label: "Transcript names"
    doc: |
      Transcript names file generated by kallisto bus

  not_sorted_bus_file:
    type: File
    outputSource: kb_count/not_sorted_bus_file
    label: "Not sorted BUS file"
    doc: |
      Not sorted BUS file generated by kallisto bus

  corrected_sorted_bus_file:
    type: File
    outputSource: kb_count/corrected_sorted_bus_file
    label: "Sorted BUS file with corrected barcodes"
    doc: |
      Sorted BUS file with corrected barcodes generated by bustools correct

  kb_count_stdout_log:
    type: File
    outputSource: kb_count/stdout_log
    label: stdout log generated by kb count
    doc: |
      stdout log generated by kb count

  kb_count_stderr_log:
    type: File
    outputSource: kb_count/stderr_log
    label: stderr log generated by kb count
    doc: |
      stderr log generated by kb count


steps:

  extract_fastq_r1:
    run: ../tools/extract-fastq.cwl
    in:
      compressed_file: fastq_file_r1
      output_prefix:
        default: "read_1"
    out:
    - fastq_file

  extract_fastq_r2:
    run: ../tools/extract-fastq.cwl
    in:
      compressed_file: fastq_file_r2
      output_prefix:
        default: "read_2"
    out:
    - fastq_file

  kb_count:
    run: ../tools/kb-count.cwl
    in:
      fastq_file_1: extract_fastq_r1/fastq_file
      fastq_file_2: extract_fastq_r2/fastq_file
      kallisto_index_file: kallisto_index_file
      tx_to_gene_mapping_file: tx_to_gene_mapping_file
      tx_to_capture_mapping_file: tx_to_capture_mapping_file
      intron_tx_to_capture_mapping_file: intron_tx_to_capture_mapping_file
      sc_technology: sc_technology
      whitelist_barcodes: whitelist_barcodes
      workflow_type: workflow_type
      h5ad:
        default: true
      threads: threads
      memory_limit: memory_limit
    out:
    - counts_unfiltered_folder
    - unfiltered_adata_file
    - whitelist_file
    - bustools_inspect_report
    - kallisto_bus_report
    - ec_mapping_file
    - transcripts_file
    - not_sorted_bus_file
    - corrected_sorted_bus_file
    - stdout_log
    - stderr_log

  compress_counts_folder:
    run: ../tools/tar-compress.cwl
    in:
      folder_to_compress: kb_count/counts_unfiltered_folder
    out:
    - compressed_folder

  collect_statistics:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      hints:
      - class: DockerRequirement
        dockerPull: rackspacedot/python37
      inputs:
        script:
          type: string?
          default: |
            #!/usr/bin/env python3
            import sys, json, os, yaml
            kallisto_name = os.path.splitext(os.path.basename(sys.argv[1]))[0]
            bustools_name = os.path.splitext(os.path.basename(sys.argv[2]))[0]
            with open(sys.argv[1], "r") as kallisto_stream:
              with open(sys.argv[2], "r") as bustools_stream:
                with open("collected_statistics.md", "w") as report_stream:
                  combined_data = {
                    "Pseudoalignment statistics": json.load(kallisto_stream),
                    "BUS statistics": json.load(bustools_stream)
                  }
                  for line in yaml.dump(combined_data, width=1000, sort_keys=False).split("\n"):
                    if not line.strip():
                      continue
                    if line.startswith("  - "):
                      report_stream.write(line+"\n")
                    elif line.startswith("    "):
                      report_stream.write("<br>"+line+"\n")
                    elif line.startswith("  "):
                      report_stream.write("- "+line+"\n")
                    else:
                      report_stream.write("### "+line+"\n")
          inputBinding:
            position: 5
        kallisto_report:
          type: File
          inputBinding:
            position: 6
        bustools_report:
          type: File
          inputBinding:
            position: 7
      outputs:
        collected_statistics:
          type: File
          outputBinding:
            glob: "*"
      baseCommand: ["python3", "-c"]
    in:
      kallisto_report: kb_count/kallisto_bus_report
      bustools_report: kb_count/bustools_inspect_report
    out:
    - collected_statistics


$namespaces:
  s: http://schema.org/

$schemas:
- https://github.com/schemaorg/schemaorg/raw/main/data/releases/11.01/schemaorg-current-http.rdf

s:name: "Kallisto | BUStools Quantify Gene Expression"
label: "Kallisto | BUStools Quantify Gene Expression"
s:alternateName: "Uses Kallisto to pseudoalign reads and BUStools to quantify the data"

s:downloadUrl: https://raw.githubusercontent.com/Barski-lab/workflows-datirium/master/workflows/kb-count.cwl
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
  Kallisto | BUStools Quantify Gene Expression
  ============================================

  Uses Kallisto to pseudoalign reads and BUStools to quantify the data