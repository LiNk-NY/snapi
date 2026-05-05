# snapi

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

**snapi** is an R package for querying the [dbSNP](https://www.ncbi.nlm.nih.gov/snp/)
dataset via the
[Clinical Table Search Service](https://clinicaltables.nlm.nih.gov/apidoc/snps/v3/doc.html)
(NLM). It wraps the SNP search API and returns results as
[`GPos`](https://bioconductor.org/packages/GenomicRanges/) objects, making
them immediately usable in Bioconductor workflows.

## Installation

```r
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("LiNk-NY/snapi")
```

## Usage

### Search by rsID

```r
library(snapi)

snp_search("rs7927381")
```

### Search by gene symbol

```r
snp_search("TP53")
```

### Search with multiple terms

Multiple terms are combined with an implicit AND:

```r
snp_search(c("rs12345", "CRYBB2P1"))
```

### Control the number of results

```r
snp_search("TP53", count = 20L)
```

### Use GRCh37 coordinates

```r
snp_search("rs7927381", assembly = "GRCh37")
```

### Pagination

Use `count` (page size, max 500) and `offset` (0-based start) together. The
total number of retrievable results (offset + count) is capped at 7,500.

```r
snp_search("TP53", count = 50L, offset = 50L)
```

## Function Reference

### `snp_search()`

```
snp_search(terms, count = 7L, offset = 0L, assembly = c("GRCh38", "GRCh37"))
```

| Argument   | Default    | Description |
|------------|------------|-------------|
| `terms`    | *(required)* | Search string or character vector of terms. Multiple terms are joined with an implicit AND. |
| `count`    | `7`        | Number of results to return (page size). Maximum is 500. |
| `offset`   | `0`        | 0-based starting result index for pagination. |
| `assembly` | `"GRCh38"` | Genome assembly for reported coordinates. One of `"GRCh38"` or `"GRCh37"`. |

**Returns:** A `GPos` object (from
[`GenomicRanges`](https://bioconductor.org/packages/GenomicRanges/)) with one
entry per SNP. Extra columns carried on the object include:

| Column     | Description |
|------------|-------------|
| `rsids`    | Reference SNP accession number (e.g. `"rs7927381"`) |
| `alleles`  | Alleles at the SNP position |
| `genes`    | Gene symbols associated with the SNP |

The `genome()` slot of the returned object is set to the requested assembly
(`"GRCh38"` or `"GRCh37"`).

## API Details

The package queries the Clinical Tables SNP Search API at:

```
https://clinicaltables.nlm.nih.gov/api/snps/v3/search
```

The underlying index is built from the dbSNP JSON data release. Both GRCh37
and GRCh38 assemblies are indexed. Full API documentation is available at
<https://clinicaltables.nlm.nih.gov/apidoc/snps/v3/doc.html>.

## Dependencies

| Package | Role |
|---------|------|
| [`httr2`](https://httr2.r-lib.org/) | HTTP requests to the Clinical Tables API |
| [`GenomicRanges`](https://bioconductor.org/packages/GenomicRanges/) | Represents query results as `GPos` objects |

## License

Artistic-2.0

## Author

Marcel Ramos ([@LiNk-NY](https://github.com/LiNk-NY))
