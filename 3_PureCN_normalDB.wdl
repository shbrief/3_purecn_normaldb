workflow build_normalDB {

  Array[File] normal_covs
  
  scatter (normal_cov in normal_covs) {
    File normal_cov = normal_cov
    
    call CreateFoFN {
      input:
        normal_cov = normal_cov
    }
  }
  
	call CreateNormalDB {
	  input:
	    normalDB_list = CreateFoFN.fofn_list
	  }
	
	output {
		File normalDB = CreateNormalDB.normalDB
		File mappingBiase = CreateNormalDB.mappingBiase
		File targetWeight = CreateNormalDB.targetWeight 
	  }
	
	meta {
		author: "Sehyun Oh"
        email: "shbrief@gmail.com"
        description: "NormalDB.R of PureCN: build a normal database"
    }
}

task CreateFoFN {
  # Command parameters
  File normal_cov
  String fofn_name

  command <<<
    mv ${write_lines(normal_cov)} ${fofn_name}.list
  >>>

  output {
    File fofn_list = "${fofn_name}.list"
  }

  runtime {
    docker: "ubuntu:latest"
  }
}

task CreateNormalDB {
	File normalDB_list   # a list of normal coverage files
	File normal_panel   # normals.merged.min5.vcf.gz
	String outdir   # .

	# Runtime parameters
	Int? machine_mem_gb
	Int? disk_space_gb
	Int disk_size = ceil(size(normal_panel, "GB")) + 20

	command <<<
		Rscript /usr/local/lib/R/site-library/PureCN/extdata/Coverage.R \
		--outdir ${outdir} \
		--coveragefiles ${normalDB_list} \
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
		File normalDB = "normalDB.rds"
		File mappingBiase = "mapping_bias.rds"
		File targetWeight = "target_weight.txt"
	}
}