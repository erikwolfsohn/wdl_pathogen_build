version 1.0

task nextstrain_build {
  input {
    File? sequence_fasta
    File? metadata_tsv

    File? build_yaml
    File? custom_zip      # <= since custom is private
    String? active_builds # Wisconsin,Minnesota,Washington

    String? AWS_ACCESS_KEY_ID
    String? AWS_SECRET_ACCESS_KEY
    String? s3deploy      # "s3://nextstrain-staging/"
    
    String dockerImage = "nextstrain/base:latest"
    String pathogen_giturl = "https://github.com/nextstrain/ncov/archive/refs/heads/master.zip"
    # String? custom_url = "path to public github"  # Our custom config files are private

    Int cpu = 8
    Int disk_size = 30  # In GiB.  Could also check size of sequence or metadata files
    Float memory = 3.5 
  }
  command <<<
    
    # Pull ncov, zika or similar pathogen repo
    wget -O master.zip ~{pathogen_giturl}
    INDIR=`unzip -Z1 master.zip | head -n1 | sed 's:/::g'`
    unzip master.zip  

    if [ -n "~{sequence_fasta}" ]
    then
      mv ~{sequence_fasta} $INDIR/.
      mv ~{metadata_tsv} $INDIR/.
    fi

    if [ -n "~{custom_zip}" ]
    then
      # Link custom profile (zipped version)
      cp ~{custom_zip} here_custom.zip
      CUSTOM_DIR=`unzip -Z1 here_custom.zip | head -n1 | sed 's:/::g'`
      unzip here_custom.zip
      cp -r $CUSTOM_DIR/*_profile $INDIR/.
    fi

    # Draft: if passing build file from zip folder
    # BUILDYAML=`ls -1 $CUSTOM_DIR/*.yaml | head -n1`
    # cp $BUILDYAML $INDIR/build_custom.yaml
    
    # Max out the number of threads
    PROC=`nproc`  

    # Run nextstrain
    nextstrain build \
      --cpus $PROC \
      --memory  ~{memory}Gib \
      --native $INDIR ~{"--configfile " + build_yaml} \
      ~{"--config active_builds=" + active_builds}

    if [ -n "~{s3deploy}" ]
    then
      # s3 deploy
      export AWS_ACCESS_KEY_ID=~{AWS_ACCESS_KEY_ID}
      export AWS_SECRET_ACCESS_KEY=~{AWS_SECRET_ACCESS_KEY}
      
      # Upload all json files to staging, maybe check for filename collisions
      nextstrain deploy ~{s3deploy} $INDIR/auspice/*.json
    fi
      
    # Prepare output
    mv $INDIR/auspice .
    zip -r auspice.zip auspice
    
    # For debugging
    mv $INDIR/results .
    cp $INDIR/.snakemake/log/*.log results/.
    zip -r results.zip results
  >>>
  output {
    File auspice_zip = "auspice.zip"  # json files for auspice
    File results_zip = "results.zip"  # for debugging
    File align_log = "align_usa.txt" # save logfiles
  }
  runtime {
    docker: dockerImage
    cpu : cpu
    memory: memory + " GiB"
    disks: "local-disk " + disk_size + " HDD"
  }
}
