task ballgown {
    File gene_abundance
    Array[File] ballgown
    String sample_id
    String docker
    String cluster
    String disk_size

    command <<<
		set -e
		call_dir="$PWD"
		local_work="/tmp/${sample_id}_ballgown"
		copy_task_logs() {
			cp -f "$call_dir/script" "$call_dir/script.txt" 2>/dev/null || true
			cp -f "$call_dir/stdout" "$call_dir/stdout.txt" 2>/dev/null || true
			cp -f "$call_dir/stderr" "$call_dir/stderr.txt" 2>/dev/null || true
		}
		trap copy_task_logs EXIT

		mkdir -p "$local_work/tmp" "$local_work/input"
		export TMPDIR="$local_work/tmp"
		export TMP="$TMPDIR"
		export TEMP="$TMPDIR"
		cp -f ${sep=" " ballgown} "$local_work/input/"
		cd "$local_work"
		ballgown "$local_work/input" ${sample_id}.txt
		cp -f ${sample_id}.txt "$call_dir/"
    >>>
    
    runtime {
      docker: docker
      instanceTypes: [cluster]
      systemDisk: "cloud " + disk_size
    }
    
    output {
      File mat_expression = "${sample_id}.txt"
    }
}
