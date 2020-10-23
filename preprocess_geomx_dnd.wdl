workflow preprocess_geomx_dnd {

    String version = "dev"
    #File monitoring_script = "gs://aryeelab/scripts/monitor_v2.sh"
    File monitoring_script = "monitor_v2.sh"
    String run_id
    File fastq_zip
    File config_ini

    Int disk_size = ceil(size(fastq_zip, "GB")) * 10 + 20

    # Run GeoMx NGS Pipeline (DND)
    call dnd {input:    run_id = run_id, 
                    	fastq_zip = fastq_zip,
                    	config_ini = config_ini, 
                        disk_size = disk_size,
                        monitoring_script = monitoring_script}

    #call sample_sheet {input: run_id = run_id,
    #						  summary = dnd.dnd_summary,
    #						  dedup_counts = dnd.dedup_counts,
    #                          dccs = dnd.dccs,
    #                          version = version}
    
    output {
        File dnd_log_zip = dnd.log_zip
        File dnd_summary = dnd.summary
        File dcc_zip = dnd.dcc_zip
        File count_table_zip = dnd.count_table_zip
        #File sample_sheet = sample_sheet.sample_sheet
        String pipeline_version = "${version}"
    }

}

task dnd {
	String run_id
	File fastq_zip
    File config_ini
    Int disk_size
    File monitoring_script

	command <<<
    	chmod u+x ${monitoring_script}
        ${monitoring_script} > monitoring.log &
	
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
        wget https://storage.googleapis.com/aryeelab/geomx/Run1DCCs.zip
        unzip Run1DCCs.zip
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
        docker: "gcr.io/aryeelab/geomx-dnd"
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

