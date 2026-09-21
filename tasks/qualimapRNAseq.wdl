task qualimapRNAseq {
	File bam
	File gtf
	String bamname = basename(bam,".bam")
	String docker
	String cluster_config
	String disk_size

	command <<<
		set -o pipefail
		set -e
		call_dir="$PWD"
		local_work="/tmp/${bamname}_qualimap_rnaseq"
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
		/opt/qualimap/qualimap rnaseq -bam ${bam} -outformat HTML -outdir ${bamname}_RNAseq -gtf ${gtf} -pe --java-mem-size=32G
		tar -zcvf ${bamname}_RNAseq_qualimap.tar.gz ${bamname}_RNAseq
		cp -f ${bamname}_RNAseq_qualimap.tar.gz "$call_dir/"
	>>>

	runtime {
		docker:docker
		instanceTypes: [cluster_config]
		systemDisk: "cloud " + disk_size
	}

	output {
		File rnaseq_zip = "${bamname}_RNAseq_qualimap.tar.gz"
	}
}
