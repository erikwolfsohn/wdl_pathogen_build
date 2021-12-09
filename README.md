# WDL Test

**Repos:**

* [ncov](https://github.com/nextstrain/ncov)
* [zika-tutorial/wdl](https://github.com/nextstrain/zika-tutorial/tree/wdl)
* [corneliusroemer/ncov-simplest](https://github.com/corneliusroemer/ncov-simplest)

**Seems to already exist:**

* https://dockstore.org/search?descriptorType=WDL&entryType=workflows&search=nextstrain
* Terra Workspace: https://app.terra.bio/#workspaces/pathogen-genomic-surveillance/COVID-19_Broad_Viral_NGS

**References:**

* [WDL Best Practices](https://docs.dockstore.org/en/develop/advanced-topics/best-practices/wdl-best-practices.html)
* [broadinstitute/viral-pipelines/pipes](https://github.com/broadinstitute/viral-pipelines/tree/master/pipes)
* [Intro to Docker, WDL, CWL](https://bdcatalyst.gitbook.io/biodata-catalyst-documentation/written-documentation/getting-started/analyze-data-1/dockstore/intro-to-docker-wdl-cwl)

## Local testing

The native install seems to require Java 11 (didn't want to mess up my nextflow environment which requires Java 8, I think...). Therefore went the Homebrew route.

* [ONT Installing Dependencies](https://dockstore.org/workflows/github.com/aryeelab/nanopore_tools/combine_sample_sheets:dev?tab=info)

```
brew install cromwell
```


