workflow build_normalDB {

	call CreateNormalDB
	
	meta {
		author: "Sehyun Oh"
        email: "shbrief@gmail.com"
        description: "NormalDB.R of PureCN: build a normal database"
    }
}

task CreateNormalDB {
  # Create a file list
  Array[File] loess
  String fname
  
  # Create normalDB
	File normal_panel   # normals.merged.min5.vcf.gz
	File normal_panel_idx   # normals.merged.min5.vcf.gz.tbi
	String outdir   # .
	
	# Runtime parameters
	Int? machine_mem_gb
	Int? disk_space_gb
	Int disk_size = ceil(size(normal_panel, "GB")) + 20

	command <<<
	  mv ${write_lines(loess)} ${fname}.list
	  mkdir ${outdir}
	  
		Rscript /usr/local/lib/R/site-library/PureCN/extdata/NormalDB.R \
		--outdir ${outdir} \
		--coveragefiles ${fname}.list \
		--normal_panel ${normal_panel} \
		--genome hg19 --force
	>>>

	runtime {
		docker: "quay.io/shbrief/pcn_docker"
		cpu : 2
		memory: "32 GB"
    	disks: "local-disk " + select_first([disk_space_gb, disk_size]) + " SSD"
	}
	
	output {
	  File normalDB_list = "${fname}.list"
		File normalDB = "normalDB.rds"
		File mappingBiase = "mapping_bias.rds"
		File targetWeight = "target_weight.txt"
	}
}