# textcollect
extracts information from a piece of text and emits it,
somehow structured. Currently, this generates YAML output.

This can be configured for the the structure expected
as its input.

This is designed be easily configured to minimize
information loss.

## Motivation
This has come into being while attempting to extract
booking information from PDF-formatted input. In this
context, it may be used in connection with the
TextCollect functionality of the Apache pdfbox project.

We tolerate having to adapt the configuration to changes
in the input format, rather than risking false output
or information loss.
