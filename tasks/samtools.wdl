task samtools {
    File sam
    String sample_id
    String bam = sample_id + ".bam"
    String sorted_bam = sample_id + ".sorted.bam"
    String percent_bam = sample_id + ".percent.bam"
    String sorted_bam_index = sample_id + ".sorted.bam.bai"
    String ins_size = sample_id + ".ins_size"
    String stats_file = sample_id + ".samtools.stats.txt"
    String docker
    String cluster
    String disk_size
    Int insert_size

    command <<<
		set -o pipefail
		set -e
		call_dir="$PWD"
		local_work="/tmp/${sample_id}_samtools"
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
		/opt/conda/bin/samtools view -bS ${sam} > ${bam}
		/opt/conda/bin/samtools sort -m 1000000000 ${bam} -o ${sorted_bam}
		/opt/conda/bin/samtools index ${sorted_bam}
		/opt/conda/bin/samtools view -bs 42.1 ${sorted_bam} > ${percent_bam}
		/opt/conda/bin/samtools stats -i ${insert_size} ${sorted_bam} > ${stats_file}
		grep '^IS' ${stats_file} | cut -f 2- > ${ins_size}
		cp -f \
			${sorted_bam} \
			${sorted_bam_index} \
			${percent_bam} \
			${ins_size} \
			${stats_file} \
			"$call_dir/"
    >>>

    runtime {
       docker: docker
       instanceTypes: [cluster]
       systemDisk: "cloud " + disk_size
    }

    output {
      File out_bam = sorted_bam
      File out_percent = percent_bam
      File out_bam_index = sorted_bam_index
      File out_ins_size = ins_size
      File out_stats = stats_file
    }

}
