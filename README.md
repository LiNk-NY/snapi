
# Overview

**snapi** is an R package for querying the
[dbSNP](https://www.ncbi.nlm.nih.gov/snp/) dataset via the [Clinical
Table Search
Service](https://clinicaltables.nlm.nih.gov/apidoc/snps/v3/doc.html)
(NLM). It wraps the SNP search API and returns results as
[`GPos`](https://bioconductor.org/packages/GenomicRanges/) objects,
making them immediately usable in Bioconductor workflows.

# Installation

``` r
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("LiNk-NY/snapi")
```

# Usage

``` r
library(snapi)
```

## Search by rsID

``` r
snp_search("rs7927381")
#> UnstitchedGPos object with 7 positions and 3 metadata columns:
#>       seqnames       pos strand |       rsids     alleles        genes
#>          <Rle> <integer>  <Rle> | <character> <character>  <character>
#>   [1]       11  67579271      * |   rs7927381         T/C
#>   [2]        1 179599437      * |  rs79273813         A/G        TDRD5
#>   [3]       11  70746832      * |  rs79273815    C/G, C/T       SHANK2
#>   [4]        1   5066529      * |  rs79273819    G/A, G/C
#>   [5]        5 107006951      * |  rs79273817    T/C, T/G LOC102467213
#>   [6]        8  95077418      * |  rs79273811    G/A, G/T      NDUFAF6
#>   [7]        8  43582071      * |  rs79273814    G/A, G/T
#>   -------
#>   seqinfo: 4 sequences from GRCh38 genome; no seqlengths
```

## Search by gene symbol

``` r
snp_search("TP53")
#> UnstitchedGPos object with 7 positions and 3 metadata columns:
#>       seqnames       pos strand |        rsids     alleles       genes
#>          <Rle> <integer>  <Rle> |  <character> <character> <character>
#>   [1]       17   7680656      * | rs1167829503         T/C        TP53
#>   [2]       17   7676793      * | rs1177040410         C/T        TP53
#>   [3]       17   7668292      * |  rs981820111         C/T        TP53
#>   [4]       17   7678979      * |  rs932155881         C/T        TP53
#>   [5]       17   7674581      * |  rs962488307         G/A        TP53
#>   [6]       17   7671674      * | rs1001269361         G/C        TP53
#>   [7]       17   7672275      * | rs1036316448         G/C        TP53
#>   -------
#>   seqinfo: 1 sequence from GRCh38 genome; no seqlengths
```

## Search with multiple terms

Multiple terms are combined with an implicit AND:

``` r
snp_search(c("rs12345", "CRYBB2P1"))
#> UnstitchedGPos object with 3 positions and 3 metadata columns:
#>       seqnames       pos strand |        rsids     alleles            genes
#>          <Rle> <integer>  <Rle> |  <character> <character>      <character>
#>   [1]       22  25459491      * |      rs12345    G/A, G/C         CRYBB2P1
#>   [2]       22  25448139      * | rs1234547361         A/G         CRYBB2P1
#>   [3]       22  25454061      * | rs1234568599         G/A CRYBB2P1 MIR6817
#>   -------
#>   seqinfo: 1 sequence from GRCh38 genome; no seqlengths
```

## Control the number of results

``` r
snp_search("TP53", count = 20L)
#> UnstitchedGPos object with 20 positions and 3 metadata columns:
#>        seqnames       pos strand |        rsids     alleles       genes
#>           <Rle> <integer>  <Rle> |  <character> <character> <character>
#>    [1]       17   7680656      * | rs1167829503         T/C        TP53
#>    [2]       17   7676793      * | rs1177040410         C/T        TP53
#>    [3]       17   7668292      * |  rs981820111         C/T        TP53
#>    [4]       17   7678979      * |  rs932155881         C/T        TP53
#>    [5]       17   7674581      * |  rs962488307         G/A        TP53
#>    ...      ...       ...    ... .          ...         ...         ...
#>   [16]       17   7672053      * |  rs959085352         C/G        TP53
#>   [17]       17   7669971      * |  rs930508964         C/T        TP53
#>   [18]       17   7678218      * |  rs895386630         C/G        TP53
#>   [19]       17   7681733      * |  rs898012395    C/G, C/T        TP53
#>   [20]       17   7678384      * | rs1171527973         C/G        TP53
#>   -------
#>   seqinfo: 1 sequence from GRCh38 genome; no seqlengths
```

## Use GRCh37 coordinates

``` r
snp_search("rs7927381", assembly = "GRCh37")
#> UnstitchedGPos object with 7 positions and 3 metadata columns:
#>       seqnames       pos strand |       rsids     alleles       genes
#>          <Rle> <integer>  <Rle> | <character> <character> <character>
#>   [1]       11  67346742      * |   rs7927381         T/C
#>   [2]        1 179568572      * |  rs79273813         A/G
#>   [3]       11  70592937      * |  rs79273815    C/G, C/T
#>   [4]        1   5126589      * |  rs79273819    G/A, G/C
#>   [5]        5 106342652      * |  rs79273817    T/C, T/G
#>   [6]        8  96089646      * |  rs79273811    G/A, G/T
#>   [7]        8  43437214      * |  rs79273814    G/A, G/T
#>   -------
#>   seqinfo: 4 sequences from GRCh37 genome; no seqlengths
```

## Pagination

Use `count` (page size, max 500) and `offset` (0-based start) together.
The total number of retrievable results (offset + count) is capped at
7,500.

``` r
snp_search("TP53", count = 50L, offset = 50L)
#> UnstitchedGPos object with 50 positions and 3 metadata columns:
#>        seqnames       pos strand |        rsids     alleles       genes
#>           <Rle> <integer>  <Rle> |  <character> <character> <character>
#>    [1]       17   7673760      * |  rs587782006         C/T        TP53
#>    [2]       17   7674186      * |  rs745425759    T/A, T/C        TP53
#>    [3]       17   7676056      * |  rs745692731         C/T        TP53
#>    [4]       17   7679790      * |  rs149598341         A/T        TP53
#>    [5]       17   7682859      * | rs1393924482       T/TTT        TP53
#>    ...      ...       ...    ... .          ...         ...         ...
#>   [46]       17   7681127      * |  rs923700009         G/A        TP53
#>   [47]       17   7672831      * |  rs867033084         C/T        TP53
#>   [48]       17   7682370      * | rs1022052538    G/A, G/C        TP53
#>   [49]       17   7679887      * |  rs920889081         T/G        TP53
#>   [50]       17   7671686      * |    rs2856753         C/T        TP53
#>   -------
#>   seqinfo: 1 sequence from GRCh38 genome; no seqlengths
```

# Function Reference

## `snp_search()`

    snp_search(terms, count = 7L, offset = 0L, assembly = c("GRCh38", "GRCh37"))

| Argument   | Default      | Description                                                                                 |
|------------|--------------|---------------------------------------------------------------------------------------------|
| `terms`    | *(required)* | Search string or character vector of terms. Multiple terms are joined with an implicit AND. |
| `count`    | `7`          | Number of results to return (page size). Maximum is 500.                                    |
| `offset`   | `0`          | 0-based starting result index for pagination.                                               |
| `assembly` | `"GRCh38"`   | Genome assembly for reported coordinates. One of `"GRCh38"` or `"GRCh37"`.                  |

**Returns:** A `GPos` object (from
[`GenomicRanges`](https://bioconductor.org/packages/GenomicRanges/))
with one entry per SNP. Extra columns carried on the object include:

| Column    | Description                                         |
|-----------|-----------------------------------------------------|
| `rsids`   | Reference SNP accession number (e.g. `"rs7927381"`) |
| `alleles` | Alleles at the SNP position                         |
| `genes`   | Gene symbols associated with the SNP                |

The `genome()` slot of the returned object is set to the requested
assembly (`"GRCh38"` or `"GRCh37"`).

# API Details

The package queries the Clinical Tables SNP Search API at:

    https://clinicaltables.nlm.nih.gov/api/snps/v3/search (+ query parameters)

The underlying index is built from the dbSNP JSON data release. Both
GRCh37 and GRCh38 assemblies are indexed. Full API documentation is
available at
<https://clinicaltables.nlm.nih.gov/apidoc/snps/v3/doc.html>.

# Dependencies

| Package                                                             | Role                                       |
|---------------------------------------------------------------------|--------------------------------------------|
| [`httr2`](https://httr2.r-lib.org/)                                 | HTTP requests to the Clinical Tables API   |
| [`GenomicRanges`](https://bioconductor.org/packages/GenomicRanges/) | Represents query results as `GPos` objects |

# Session Information

``` r
sessionInfo()
#> R version 4.6.0 Patched (2026-04-24 r89961)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Ubuntu 24.04.4 LTS
#>
#> Matrix products: default
#> BLAS:   /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.12.0
#> LAPACK: /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.12.0  LAPACK version 3.12.0
#>
#> locale:
#>  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C
#>  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8
#>  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8
#>  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C
#>  [9] LC_ADDRESS=C               LC_TELEPHONE=C
#> [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C
#>
#> time zone: America/New_York
#> tzcode source: system (glibc)
#>
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base
#>
#> other attached packages:
#> [1] snapi_0.99.0
#>
#> loaded via a namespace (and not attached):
#>  [1] vctrs_0.7.3          cli_3.6.6            knitr_1.51
#>  [4] rlang_1.2.0          xfun_0.57            otel_0.2.0
#>  [7] processx_3.9.0       generics_0.1.4       jsonlite_2.0.0
#> [10] glue_1.8.1           S4Vectors_0.51.1     htmltools_0.5.9
#> [13] pkgbuild_1.4.8       ps_1.9.3             stats4_4.6.0
#> [16] rappdirs_0.3.4       rmarkdown_2.31       Seqinfo_1.3.0
#> [19] evaluate_1.0.5       fastmap_1.2.0        IRanges_2.47.0
#> [22] yaml_2.3.12          lifecycle_1.0.5      httr2_1.2.2
#> [25] BiocManager_1.30.27  compiler_4.6.0       codetools_0.2-20
#> [28] digest_0.6.39        R6_2.6.1             curl_7.1.0
#> [31] pillar_1.11.1        magrittr_2.0.5       callr_3.7.6
#> [34] GenomicRanges_1.65.0 tools_4.6.0          BiocGenerics_0.59.0
#> [37] remotes_2.5.0        desc_1.4.3
```
