cwlVersion: v1.0
class: Workflow


requirements:
- class: SubworkflowFeatureRequirement
- class: StepInputExpressionRequirement
- class: InlineJavascriptRequirement
- class: MultipleInputFeatureRequirement


inputs:

  alias:
    type: string
    label: "Experiment short name/Alias"
    sd:preview:
      position: 1

  srr_id:
    type: string
    label: "SRR Identifier"
    doc: |
      Single SRR Identifier

  splitby:
    type:
    - "null"
    - type: enum
      symbols:
      - "Split into all available files"
      - "3-way splitting for mate-pairs"
      - "Do not split"
    default: "3-way splitting for mate-pairs"
    label: "Split reads by"
    doc:
      Split into all available files.
      Write reads into separate files.
      Read number will be suffixed to
      the file name. In cases where not
      all spots have the same number of
      reads, this option will produce 
      files that WILL CAUSE ERRORS in
      most programs which process split
      pair fastq files.

      3-way splitting for mate-pairs.
      For each spot, if there are two
      biological reads satisfying filter
      conditions, the first is placed in
      the `*_1.fastq` file, and the second
      is placed in the `*_2.fastq` file.
      If there is only one biological read
      satisfying the filter conditions, it
      is placed in the `*.fastq` file. All
      other reads in the spot are ignored.

      Do not split.
      Output all reads into as a single
      FASTQ file

  http_proxy:
    type: string?
    label: "Optional HTTP proxy settings"
    doc: |
      Optional HTTP proxy settings
    'sd:layout':
      advanced: true


outputs:

  fastq_files:
    type:
    - "null"
    - type: array
      items: File
    outputSource: fastq_dump/fastq_files
    label: "Gzip-compressed FASTQ files"
    doc: |
      Gzip-compressed FASTQ files

  report_md:
    type: File
    outputSource: collect_report/output_file
    label: "Collected report for downloaded FASTQ files"
    doc: |
      Collected report for downloaded FASTQ files
      in Markdown format
    'sd:visualPlugins':
    - markdownView:
        tab: 'Overview'

  fastq_dump_stdout_log:
    type: File
    outputSource: fastq_dump/stdout_log
    label: "stdout log generated by fastq_dump"
    doc: |
      stdout log generated by fastq_dump

  fastq_dump_stderr_log:
    type: File
    outputSource: fastq_dump/stderr_log
    label: "stderr log generated by fastq_dump"
    doc: |
      stderr log generated by fastq_dump


steps:

  fastq_dump:
    run: ../tools/fastq-dump.cwl
    in:
      srr_id: srr_id
      split_files:
        source: splitby
        valueFrom: $(self=="Split into all available files"?true:null)
      split_3:
        source: splitby
        valueFrom: $(self=="3-way splitting for mate-pairs"?true:null)
      http_proxy:
        source: http_proxy
        valueFrom: $(self==""?null:self)                 # safety measure
    out:
    - fastq_files
    - stdout_log
    - stderr_log

  collect_report:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      hints:
      - class: DockerRequirement
        dockerPull: biowardrobe2/scidap:v0.0.3
      inputs:
        script:
          type: string?
          default: |
            #!/bin/bash
            set -- "$0" "$@"
            if [ "$#" -eq 1 ] && [ "$0" = "/bin/bash" ]; then
                echo "Failed to download FASTQ files. Check logs for errors." > report.md
                exit 0
            fi
            echo "## Collected Report" > report.md
            j=1
            for i in "${@}"; do
              echo "### `basename $i`" >> report.md
              echo "**`zcat $i | wc -l`** lines, **`stat -c%s $i`** bytes" >> report.md
              echo "Top 5 reads" >> report.md
              echo "\`\`\`" >> report.md
              echo "`zcat $i | head -n 20`" >> report.md
              echo "\`\`\`" >> report.md
              (( j++ ))
            done;
          inputBinding:
            position: 1
        input_file:
          type:
          - "null"
          - type: array
            items: File
          inputBinding:
            position: 2
      outputs:
        output_file:
          type: File
          outputBinding:
            glob: "*"
      baseCommand: [bash, '-c']
    in:
      input_file: fastq_dump/fastq_files
    out:
    - output_file


$namespaces:
  s: http://schema.org/

$schemas:
- https://github.com/schemaorg/schemaorg/raw/main/data/releases/11.01/schemaorg-current-http.rdf

label: "FASTQ Download"
s:name: "FASTQ Download"
s:alternateName: "Download FASTQ files using fastq-dump from SRA Toolkit"

s:downloadUrl: https://raw.githubusercontent.com/datirium/workflows/master/workflows/fastq-download.cwl
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
  FASTQ Download
  
  Download FASTQ files using fastq-dump from SRA Toolkit
