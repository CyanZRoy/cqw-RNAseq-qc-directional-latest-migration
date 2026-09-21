task stringtie {
    File bam
    File gtf
    String docker
    String sample_id
    String cluster
    String disk_size
    Int minimum_length_allowed_for_the_predicted_transcripts
    Int Junctions_no_spliced_reads
    Float minimum_isoform_abundance
    Float maximum_fraction_of_muliplelocationmapped_reads

    command <<<
		set -e
		call_dir="$PWD"
		local_work="/tmp/${sample_id}_stringtie"
		copy_task_logs() {
			cp -f "$call_dir/script" "$call_dir/script.txt" 2>/dev/null || true
			cp -f "$call_dir/stdout" "$call_dir/stdout.txt" 2>/dev/null || true
			cp -f "$call_dir/stderr" "$call_dir/stderr.txt" 2>/dev/null || true
		}
		trap copy_task_logs EXIT

		mkdir -p "$local_work/tmp" "$local_work/ballgown/${sample_id}"
		export TMPDIR="$local_work/tmp"
		export TMP="$TMPDIR"
		export TEMP="$TMPDIR"
		cd "$local_work"
		nt=$(nproc)
		/opt/conda/bin/stringtie -e \
			-B \
			-p $nt \
			-f ${minimum_isoform_abundance} \
			-m ${minimum_length_allowed_for_the_predicted_transcripts} \
			-a ${Junctions_no_spliced_reads} \
			-M ${maximum_fraction_of_muliplelocationmapped_reads} \
			-G ${gtf} \
			--rf \
			-o ballgown/${sample_id}/${sample_id}.gtf \
			-C ${sample_id}.cov.ref.gtf \
			-A ${sample_id}.gene.abundance.txt \
			${bam}

		cp -f ${sample_id}.cov.ref.gtf ${sample_id}.gene.abundance.txt "$call_dir/"
		mkdir -p "$call_dir/ballgown"
		cp -r ballgown/${sample_id} "$call_dir/ballgown/"
    >>>
    
    runtime {
      docker: docker
      instanceTypes: [cluster]
      systemDisk: "cloud " + disk_size
    }
    
    output {
      File covered_transcripts = "${sample_id}.cov.ref.gtf"
      File gene_abundance = "${sample_id}.gene.abundance.txt"
      Array[File] ballgown = ["ballgown/${sample_id}/${sample_id}.gtf", "ballgown/${sample_id}/e2t.ctab", "ballgown/${sample_id}/e_data.ctab", "ballgown/${sample_id}/i2t.ctab", "ballgown/${sample_id}/i_data.ctab", "ballgown/${sample_id}/t_data.ctab"]
    }
}
