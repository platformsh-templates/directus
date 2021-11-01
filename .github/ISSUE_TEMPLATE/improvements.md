name: Improvements
description: For changes to improve this template.
labels:
  - ungroomed
body:
  - type: markdown
    attributes:
      value: |
        Thanks for your interest in helping improve the Platform.sh templates!
        Please fill in the fields below so we can understand what changes you'd like to see.

  - type: textarea
    attributes:
      label: What in this template can be improved or added as a feature?
      description: Descripe the improvements you'd like to see.
      placeholder: |
        - Examples for connecting with GitHub actions/
        - What do you expect as an outcome?
    validations:
      required: true

  - type: textarea
    attributes:
      label: What exactly should be updated?
      description: |
        - Share as much detail as you can to help us understand the suggestion. 
        - What do you expect as an outcome?
    validations:
      required: true

  - type: textarea
    attributes:
      label: Additional context
      description: Optionally add any other information or screenshots that could help us understand and implement the change.
    validations:
      required: false
