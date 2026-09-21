# Project Guidance

- MultiQC is retired from this workflow. Do not reintroduce it unless the project requirements explicitly change.
- Qualimap BAM QC and RNA-seq QC intentionally run on the BAM produced by `samtools view -bs 42.1`, which is a reproducible sample of approximately 10% of reads.
- Preserve the standalone HISAT2 summary and full samtools stats outputs; downstream reporting depends on these source results.
- Tasks compute in task-specific `/tmp/<sample>_<task>` directories and copy declared outputs back to the Cromwell call directory.
- Upstream QC table aggregation is intentionally deferred until the metric definitions and expected source files are confirmed.
