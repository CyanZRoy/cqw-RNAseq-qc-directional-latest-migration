task fastp {
    String sample_id
    File read1
    File read2
    String adapter_sequence
    String adapter_sequence_r2
    String docker
    String cluster
    String disk_size
    String umi_loc	
    Int trim_front1
    Int trim_tail1
    Int max_len1
    Int trim_front2
    Int trim_tail2
    Int max_len2
    Int disable_adapter_trimming
    Int length_required
    Int umi_len
    Int UMI
    Int qualified_quality_phred
    Int length_required1
    Int disable_quality_filtering
   
	command <<<
		set -e
		call_dir="$PWD"
		local_work="/tmp/${sample_id}_fastp"
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

		quality_args="-q ${qualified_quality_phred} -u ${length_required1}"
		if [ "${disable_quality_filtering}" -eq 0 ]; then
			quality_args="--disable_quality_filtering"
		fi

		adapter_args="--adapter_sequence ${adapter_sequence} --adapter_sequence_r2 ${adapter_sequence_r2} --detect_adapter_for_pe"
		if [ "${disable_adapter_trimming}" -ne 0 ]; then
			adapter_args="--disable_adapter_trimming"
		fi

		umi_args=""
		if [ "${UMI}" -ne 0 ]; then
			umi_args="-U --umi_loc=${umi_loc} --umi_len=${umi_len}"
		fi

		fastp \
			--thread "$nt" \
			--trim_front1 ${trim_front1} \
			--trim_tail1 ${trim_tail1} \
			--max_len1 ${max_len1} \
			--trim_front2 ${trim_front2} \
			--trim_tail2 ${trim_tail2} \
			--max_len2 ${max_len2} \
			-l ${length_required} \
			$quality_args \
			$adapter_args \
			$umi_args \
			-i ${read1} \
			-I ${read2} \
			-o ${sample_id}_R1.fastq.gz \
			-O ${sample_id}_R2.fastq.gz \
			-j ${sample_id}.json \
			-h ${sample_id}.html

		cp -f \
			${sample_id}_R1.fastq.gz \
			${sample_id}_R2.fastq.gz \
			${sample_id}.json \
			${sample_id}.html \
			"$call_dir/"
   >>>
   
   runtime { 
		docker: docker
		instanceTypes: [cluster]
		systemDisk: "cloud " + disk_size
   }

   output {
      File json = "${sample_id}.json"
      File report = "${sample_id}.html"
      File Trim_R1 = "${sample_id}_R1.fastq.gz"
      File Trim_R2 = "${sample_id}_R2.fastq.gz"
   }
}
