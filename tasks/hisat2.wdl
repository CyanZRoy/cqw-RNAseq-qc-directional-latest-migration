task hisat2 {
   File idx
   File Trim_R1
   File Trim_R2
   String idx_prefix
   String sample_id
   String docker
   String cluster
   String disk_size
   String pen_intronlen
   Int pen_cansplice
   Int pen_noncansplice
   Int min_intronlen
   Int max_intronlen
   Int maxins
   Int minins
   
   command <<<
		set -e
		call_dir="$PWD"
		local_work="/tmp/${sample_id}_hisat2"
		copy_task_logs() {
			cp -f "$call_dir/script" "$call_dir/script.txt" 2>/dev/null || true
			cp -f "$call_dir/stdout" "$call_dir/stdout.txt" 2>/dev/null || true
			cp -f "$call_dir/stderr" "$call_dir/stderr.txt" 2>/dev/null || true
			cp -f "$local_work/${sample_id}.hisat2_summary.txt" "$call_dir/" 2>/dev/null || true
		}
		trap copy_task_logs EXIT

		mkdir -p "$local_work/tmp"
		export TMPDIR="$local_work/tmp"
		export TMP="$TMPDIR"
		export TEMP="$TMPDIR"
		cd "$local_work"
		nt=$(nproc)
		hisat2 -t -p $nt \
			-x ${idx}/${idx_prefix} \
			--pen-cansplice ${pen_cansplice} \
			--pen-noncansplice ${pen_noncansplice} \
			--pen-canintronlen ${pen_intronlen} \
			--min-intronlen ${min_intronlen} \
			--max-intronlen ${max_intronlen} \
			--maxins ${maxins} --minins ${minins} \
			--rna-strandness RF \
			--un-conc-gz ${sample_id}_un.fq.gz \
			-1 ${Trim_R1} \
			-2 ${Trim_R2} \
			-S ${sample_id}.sam \
			2> ${sample_id}.hisat2_summary.txt

		cat ${sample_id}.hisat2_summary.txt >&2
		cp -f \
			${sample_id}.sam \
			${sample_id}_un.fq.1.gz \
			${sample_id}_un.fq.2.gz \
			${sample_id}.hisat2_summary.txt \
			"$call_dir/"
   >>>
   
   runtime { 
		docker: docker 
		instanceTypes: [cluster]
		systemDisk: "cloud " + disk_size
		timeout: 864000
   }

   output {
      File sam = "${sample_id}.sam"
      File unmapread_1p = "${sample_id}_un.fq.1.gz"
      File unmapread_2p = "${sample_id}_un.fq.2.gz"
      File hisat2_summary = "${sample_id}.hisat2_summary.txt"
   }
}
