version 1.0

task ncov_ingest {
  input {
    # based off of https://github.com/nextstrain/ncov-ingest#required-environment-variables
    String GISAID_API_ENDPOINT
    String GISAID_USERNAME_AND_PASSWORD
    String AWS_DEFAULT_REGION
    String AWS_ACCESS_KEY_ID
    String AWS_SECRET_ACCESS_KEY
    #String? SLACK_TOKEN
    #String? SLACK_CHANNEL

    String giturl = "https://github.com/nextstrain/ncov-ingest/archive/refs/heads/master.zip"

    String docker_img = "nextstrain/ncov-ingest:latest"

    Int cpu = 16
    Int disk_size = 48  # In GiB
    Float memory = 3.5
  }

  command <<<
    # Set up env variables
    export GISAID_API_ENDPOINT=~{GISAID_API_ENDPOINT}
    export GISAID_USERNAME_AND_PASSWORD=~{GISAID_USERNAME_AND_PASSWORD}
    export AWS_DEFAULT_REGION=~{AWS_DEFAULT_REGION}
    export AWS_ACCESS_KEY_ID=~{AWS_ACCESS_KEY_ID}
    export AWS_SECRET_ACCESS_KEY=~{AWS_SECRET_ACCESS_KEY}

    # Pull ncov-ingest repo
    wget -O master.zip ~{giturl}
    NCOV_INGEST_DIR=`unzip -Z1 master.zip | head -n1 | sed 's:/::g'`
    unzip master.zip

    PROC=`nproc` # Max out processors, although not sure if it matters here
    mem_mb=`$((~{disk_size}-1))000`

    # Navigate to ncov-ingest directory, and call snakemake
    cd $NCOV_INGEST_DIR

    # Needed for the --config flag
    declare -a config
    config+=(
      fetch_from_database=True
      trigger_rebuild=False
    )

    # Native run of snakemake
    nextstrain build \
      --native \
      --cpus $PROC \
      --memory ~{disk_size}GiB \
      --exec env \
      . \
        snakemake \
          --configfile config/gisaid.yaml \
          --config "${config[@]}" \
          --cores $PROC \
          --resources mem_mb=$mem_mb \
          --printshellcmds

      # --exec bash
      #   --config "${config[@]}" \
      # --resources mem_mb=~{disk_size}000 \

    # Or maybe simplier? https://github.com/nextstrain/ncov-ingest/blob/master/.github/workflows/rebuild-open.yml#L26
    #./bin/rebuild open       # Make sure these aren't calling aws before using them
    #./bin/rebuild gisaid

    # === prepare output
    cd ..
    zip -r ncov_ingest.zip $NCOV_INGEST_DIR
  >>>

  output {
    File ncov_ingest_zip = "ncov_ingest.zip"
  }
  
  runtime {
    docker: docker_img
    cpu : cpu
    memory: memory + " GiB"
    disks: "local-disk " + disk_size + " HDD"
  }
}