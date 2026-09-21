task fastqc {
	String sample_id
	File read1
	File read2
	String docker
	String cluster_config
	String disk_size

	command <<<
		set -o pipefail
		set -e
		call_dir="$PWD"
		local_work="/tmp/${sample_id}_fastqc"
		copy_task_logs() {
			cp -f "$call_dir/script" "$call_dir/script.txt" 2>/dev/null || true
			cp -f "$call_dir/stdout" "$call_dir/stdout.txt" 2>/dev/null || true
			cp -f "$call_dir/stderr" "$call_dir/stderr.txt" 2>/dev/null || true
		}
		trap copy_task_logs EXIT

		mkdir -p "$local_work/tmp"
		export TMPDIR="$local_work/tmp"
		export TMP="$TMPDIR"
		export TEMP="$TMPDIR"
		cd "$local_work"
		nt=$(nproc)
		fastqc -t $nt -o ./ ${read1}
		fastqc -t $nt -o ./ ${read2}
		cp -f *_fastqc.html *_fastqc.zip "$call_dir/"
	>>>

	runtime {
		docker:docker
    	instanceTypes: [cluster_config]
    	systemDisk: "cloud " + disk_size
	}
	output {
		File read1_html = sub(basename(read1), "\\.(fastq|fq)\\.gz$", "_fastqc.html")
		File read1_zip = sub(basename(read1), "\\.(fastq|fq)\\.gz$", "_fastqc.zip")
		File read2_html = sub(basename(read2), "\\.(fastq|fq)\\.gz$", "_fastqc.html")
		File read2_zip = sub(basename(read2), "\\.(fastq|fq)\\.gz$", "_fastqc.zip")
	}
}
