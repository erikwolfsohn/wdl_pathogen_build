version 1.0

# import "tasks/nextstrain.wdl" as nextstrain # <= modular method
# import "tasks/buildfile.wdl" as buildfile
# import "tasks/s3.wdl" as nextstrain
import "tasks/ncov_ingest.wdl" as ncov_ingest

workflow Nextstrain_WRKFLW {
  input {
    # === KEYS
    # based off of https://github.com/nextstrain/ncov-ingest#required-environment-variables
    String AWS_ACCESS_KEY_ID
    String AWS_SECRET_ACCESS_KEY
    String GISAID_API_ENDPOINT
    String GISAID_USERNAME_AND_PASSWORD
    String AWS_DEFAULT_REGION
    #String? SLACK_TOKEN
    #String? SLACK_CHANNEL

    # === NCOV Ingest
    String giturl = "https://github.com/nextstrain/ncov-ingest/archive/refs/heads/master.zip"

    String? docker_img = "nextstrain/ncov-ingest:latest"

    Int? cpu = 16
    Float? memory = 3.5
    Int? disk_size = 48  # In GiB

    # === Nextstrain Build
    # # Option 1: run the ncov example workflow
    # File? build_yaml
    # File custom_zip

    # # Option 2: create a build_yaml from sequence and metadata
    # File? sequence_fasta
    # File? metadata_tsv
    # String? build_name
    # It's possible all of the above files are provided

    # Option 3? GISAID augur zip?
    # File? gisaid_zip # tarball

    # String? active_builds # "Wisconsin,Minnesota,Iowa"
 
    # # By default, run the ncov workflow (can swap it for zika or something else)
    # String giturl = "https://github.com/nextstrain/ncov/archive/refs/heads/master.zip"
    # String docker_path = "nextstrain/base:latest"
    # Int? cpu
    # Int? memory       # in GiB
    # Int? disk_size
  }

  # === NCOV Ingest
  call ncov_ingest.ncov_ingest as ncov_ingest {
    input:
      AWS_ACCESS_KEY_ID=AWS_ACCESS_KEY_ID,
      AWS_SECRET_ACCESS_KEY=AWS_SECRET_ACCESS_KEY,
      AWS_DEFAULT_REGION=AWS_DEFAULT_REGION,
      GISAID_API_ENDPOINT=GISAID_API_ENDPOINT,
      GISAID_USERNAME_AND_PASSWORD=GISAID_USERNAME_AND_PASSWORD,
      giturl=giturl,
      docker_img=docker_img,
      cpu=cpu,
      memory=memory,
      disk_size=disk_size
  }

  # === Nextstrain Build
  # if (defined(sequence_fasta)) {
  #   call buildfile.mk_buildconfig as mk_buildconfig {
  #     input:
  #       sequence_fasta = select_first([sequence_fasta]),
  #       metadata_tsv = select_first([metadata_tsv]),
  #       build = build_name,
  #       dockerImage = docker_path
  #   }
  # }

  # # call nextstrain.nextstrain build as build {  # <= modular method
  # call nextstrain.nextstrain_build as build {
  #   input:
  #     build_yaml = select_first([build_yaml, mk_buildconfig.buildconfig]), # Accepts Option 1 or Option 2
  #     custom_zip = custom_zip,
  #     cpu = cpu,
  #     memory = memory,
  #     disk_size = disk_size,
  #     dockerImage = docker_path,
  #     giturl = giturl,
  #     active_builds = active_builds,
  #     AWS_ACCESS_KEY_ID = AWS_ACCESS_KEY_ID,
  #     AWS_SECRET_ACCESS_KEY = AWS_SECRET_ACCESS_KEY
  # }
  output {
    # === NCOV Ingest
    File ncov_ingest_zip = ncov_ingest.ncov_ingest_zip

    # === Nextstrain build
    # File auspice_zip = build.auspice_zip
    # File results_zip = build.results_zip
  }
}
