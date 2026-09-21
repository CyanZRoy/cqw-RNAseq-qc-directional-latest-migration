task fastq_screen {
	String sample_id
	File read1
	File read2
	File screen_ref_dir
	File fastq_screen_conf
	String read1name = basename(read1,".fastq.gz")
	String read2name = basename(read2,".fastq.gz")
	String docker
	String cluster_config
	String disk_size

	command <<<
		set -o pipefail
		set -e
		call_dir="$PWD"
		local_work="/tmp/${sample_id}_fastqscreen"
		copy_task_logs() {
			cp -f "$call_dir/script" "$call_dir/script.txt" 2>/dev/null || true
			cp -f "$call_dir/stdout" "$call_dir/stdout.txt" 2>/dev/null || true
			cp -f "$call_dir/stderr" "$call_dir/stderr.txt" 2>/dev/null || true
		}
		trap copy_task_logs EXIT

		mkdir -p "$local_work/tmp" /cromwell_root/tmp
		export TMPDIR="$local_work/tmp"
		export TMP="$TMPDIR"
		export TEMP="$TMPDIR"
		nt=$(nproc)
		cp -r ${screen_ref_dir} /cromwell_root/tmp/
		cd "$local_work"
		#sed -i "s#/cromwell_root/fastq_screen_reference#${screen_ref_dir}#g" ${fastq_screen_conf}
		fastq_screen --aligner bowtie2 --conf ${fastq_screen_conf} --top 100000 --threads $nt ${read1}
		fastq_screen --aligner bowtie2 --conf ${fastq_screen_conf} --top 100000 --threads $nt ${read2}
		cp -f \
			${read1name}_screen.png \
			${read1name}_screen.txt \
			${read1name}_screen.html \
			${read2name}_screen.png \
			${read2name}_screen.txt \
			${read2name}_screen.html \
			"$call_dir/"
	>>>

	runtime {
		docker:docker
    	instanceTypes: [cluster_config]
    	systemDisk: "cloud " + disk_size
	}
	output {
		File png1 = "${read1name}_screen.png"
		File txt1 = "${read1name}_screen.txt"
		File html1 = "${read1name}_screen.html"
		File png2 = "${read2name}_screen.png"
		File txt2 = "${read2name}_screen.txt"
		File html2 = "${read2name}_screen.html"
	}
}
