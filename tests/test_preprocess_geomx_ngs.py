def test_preprocess_geomx_ngs(workflow_data, workflow_runner):
    inputs = {
        "run_id": workflow_data["run_id"],
        "fastq_zip": workflow_data["fastq_zip"],
        "config_ini": workflow_data["config_ini"]
    }
    expected = workflow_data.get_dict("dcc_zip")
    workflow_runner(
        "preprocess_geomx_dnd.wdl",
        inputs,
        expected
    )