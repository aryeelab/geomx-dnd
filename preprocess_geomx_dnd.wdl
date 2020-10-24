workflow preprocess_geomx_dnd {

	String version = "dev"
	
	# 'dev' pipeline versions use the image with the 'latest' tag.
	# release pipeline versions use images tagged with the version number itself
	String image_id = sub(version, "dev", "latest")
	
    String run_id
    File fastq_zip
    File config_ini

    Int disk_size = ceil(size(fastq_zip, "GB")) * 10 + 20

    # Run GeoMx NGS Pipeline (DND)
    call dnd {input:    image_id = image_id,
                        run_id = run_id, 
                    	fastq_zip = fastq_zip,
                    	config_ini = config_ini, 
                        disk_size = disk_size}

    #call sample_sheet {input: image_id = image_id,
    #                          run_id = run_id,
    #				 		   summary = dnd.dnd_summary,
    #						   dedup_counts = dnd.dedup_counts,
    #                          dccs = dnd.dccs,
    #                          version = version}

	call version_info {
		input: image_id = image_id
	}
    
    output {
        File dnd_log_zip = dnd.log_zip
        File dnd_summary = dnd.summary
        File dcc_zip = dnd.dcc_zip
        File count_table_zip = dnd.count_table_zip
        #File sample_sheet = sample_sheet.sample_sheet
        String pipeline_version = version_info.pipeline_version
    }

}

task dnd {
    String image_id
	String run_id
	File fastq_zip
    File config_ini
    Int disk_size

	command <<<
        monitor_v2.sh > monitoring.log &
	
	    extension=`echo ${fastq_zip} | sed 's/.*\.//'`
	    if [ $extension == "zip" ]
	    then    
            echo "Unzipping ${fastq_zip}"
            mkdir /fastq
            unzip -d /fastq -j ${fastq_zip}
        else 
            echo "ERROR: Input file does not end in zip."
            exit 1
        fi
        
        # Run DND pipeline. Output stored in output

        # NOTE: This dummy placeholder section simulates a pipeline run
        # by creating output under output. We'll use it until we get 
        # access to the v2 (non-docker) DND code and can replace it
        # with a real DND call.
        curl https://storage.googleapis.com/aryeelab/geomx/3sampleAOIs_20200504_DND/Run1DCCs.tar.gz | tar zxv
        mv Run1DCCs output
        
        # Rename DCC zip file
        mv output/DCC*.zip output/dcc_${run_id}.zip
        
        # Create count table zip file
        zip -j output/count-tables_${run_id}.zip output/Count_Tables/*.tsv
        
        # Create log zip file
        zip -j output/logs_${run_id}.zip output/logs/*
    >>>  

    runtime {
        continueOnReturnCode: false
        docker: "gcr.io/aryeelab/geomx-dnd:${image_id}"
        bootDiskSizeGb: 20
        disks: "local-disk ${disk_size} HDD"
        zones: "us-central1-c"
        preemptible: 0
    }
    
    output {
        File dcc_zip = "output/dcc_${run_id}.zip"
        File count_table_zip = "output/count-tables_${run_id}.zip"
        File log_zip = "output/logs_${run_id}.zip"
        File summary = "output/summary.txt"
        File monitoring_log = "monitoring.log"
    }
	
}

task version_info {
	String image_id
	command <<<
		cat /VERSION
	>>>
	runtime {
            continueOnReturnCode: false
            docker: "gcr.io/aryeelab/geomx-dnd:${image_id}"
            cpu: 1
            memory: "1GB"
        }
	output {
	    String pipeline_version = read_string(stdout())
        }
}
