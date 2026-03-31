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
		nt=$(nproc)
		hisat2 -t -p $nt \
			-x ~{idx}/~{idx_prefix} \
			--pen-cansplice ~{pen_cansplice} \
			--pen-noncansplice ~{pen_noncansplice} \
			--pen-canintronlen ~{pen_intronlen} \
			--min-intronlen ~{min_intronlen} \
			--max-intronlen ~{max_intronlen} \
			--maxins ~{maxins} --minins ~{minins} \
			--rna-strandness RF \
			--un-conc-gz ~{sample_id}_un.fq.gz \
			-1 ~{Trim_R1} \
			-2 ~{Trim_R2} \
			-S ~{sample_id}.sam 
   >>>
   
   runtime { 
		docker: docker 
		instanceTypes: [cluster]
		systemDisk: "cloud " + disk_size
		timeout: 864000
   }

   output {
      File sam = "~{sample_id}.sam"
      File unmapread_1p = "~{sample_id}_un.fq.1.gz"
      File unmapread_2p = "~{sample_id}_un.fq.2.gz"
   }
}
