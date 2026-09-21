task qualimapBAMqc {
	File bam
	String bamname = basename(bam,".bam")
	String docker
	String cluster_config
	String disk_size

	command <<<
		set -o pipefail
		set -e
		call_dir="$PWD"
		local_work="/tmp/${bamname}_qualimap_bamqc"
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
		/opt/qualimap/qualimap bamqc -bam ${bam} -outformat PDF:HTML -nt $nt -outdir ${bamname}_bamqc --java-mem-size=32G 
		tar -zcvf ${bamname}_bamqc_qualimap.tar.gz ${bamname}_bamqc
		cp -f ${bamname}_bamqc_qualimap.tar.gz "$call_dir/"
	>>>

	runtime {
		docker:docker
		instanceTypes: [cluster_config]
		systemDisk: "cloud " + disk_size
	}

	output {
		File bamqc_zip = "${bamname}_bamqc_qualimap.tar.gz"
	}
}
