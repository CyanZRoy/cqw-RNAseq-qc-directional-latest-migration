# Changelog

## Unreleased

- Fixed fastp parameter branching so all supported configurations produce clean FASTQ and JSON/HTML reports in one run.
- Fixed StringTie's Ballgown output directory and removed the undeclared `genecount` artifact.
- Removed retired MultiQC code and stale `fasta`/`ref_dir` inputs.
- Added task-specific temporary working directories and best-effort `script.txt`, `stdout.txt`, and `stderr.txt` preservation.
- Added a standalone HISAT2 summary output and preserved complete samtools stats.
- Documented the intentional 10% Qualimap sampling method and current runtime behavior.
