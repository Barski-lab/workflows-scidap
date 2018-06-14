cwlVersion: v1.0
class: Workflow

inputs:
  cells:
    type: string
    label: "Cells"
  conditions:
    type: string
    label: "Conditions"
  alias:
    type: string
    label: "Experiment short name/Alias"
  description:
    type: string?
    'sd:type': 'text'
    label: "Description"

outputs: []
steps: []

