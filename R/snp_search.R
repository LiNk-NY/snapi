.CLINTAB_BASE_URL <-  "https://clinicaltables.nlm.nih.gov/api/snps/v3/search"

#' Query the Clinical Tables SNP API for a given rsID
#'
#' This function uses the `httr2` package to send a `GET` request to the
#' Clinical Tables API using a specified rsID (e.g., "rs7927381") and returns
#' a GPos object containing the genomic positions of the SNPs.
#'
#' @param terms (required) The search string (e.g., just a part of a word) for
#'   which to find matches in the list. More than one partial word can be
#'   present in "terms", in which case there is an implicit AND between them.
#'
#' @param count (default 7) The number of results to retrieve (page size). The
#'   maximum count allowed is 500, see "offset" below on pagination support.
#'
#' @param offset (default 0) The starting result number (0-based) to retrieve.
#'   Use offset and count together for pagination. Note that the current limit
#'   on the total number of results that can be retrieved (offset + count) is
#'   7,500. We reserve the right to decrease or increase this limit based on
#'   system capacity and/or other factors. Please see the FAQ page on how to
#'   sign up to our email list to be notified of any changes or new features.
#'
#' @param assembly (default "GRCh38") The genome assembly to use for genomic
#'   coordinates. Supported values are "GRCh38" (default) and "GRCh37".
#'
#' @return A GPos object with genomic ranges for each SNP, or NULL if the input
#'   is invalid.
#'
#' @importFrom GenomicRanges makeGPosFromDataFrame
#' @importFrom httr2 request req_url_query req_perform resp_body_json
#' @importFrom Seqinfo genome<-
#'
#' @details The Clinical Tables SNP API provides information about single
#'   nucleotide polymorphisms (SNPs) from the dbSNP database. The API returns
#'   data in JSON format, which includes various fields related to the SNPs. The
#'   fields available in the API response include:
#'
#' \describe{
#' * `rsNum` - The reference SNP accession number
#' * `38.alleles` - The alleles found at the SNP's position in assembly GRCh38
#' * `38.chr` - The number of the chromosome containing the SNP for assembly
#'   GRCh38
#' * `38.pos` - The position of the SNP on the chromosome for assembly GRCh38
#' * `38.gene` - The symbols for the genes of the SNP for assembly GRCh38
#' * `38.assembly` - The assembly name for the SNP for assembly GRCh38, which
#'   always has the value "GRCh38"
#' * `38.seqID` - The sequence ID for the SNP for assembly GRCh38
#' * `37.alleles` - The alleles found at the SNP's position in assembly GRCh37
#' * `37.chr` - The number of the chromosome containing the SNP for assembly
#'   GRCh37
#' * `37.pos` - The position of the SNP on the chromosome for assembly GRCh37
#' * `37.gene` - The symbols for the genes of the SNP for assembly GRCh37
#' * `37.assembly` - The assembly name for the SNP for assembly GRCh37, which
#'   always has the value "GRCh37"
#' * `37.seqID` - The sequence ID for the SNP for assembly GRCh37
#' }
#'
#' @seealso <https://clinicaltables.nlm.nih.gov/apidoc/snps/v3/doc.html>
#'
#' @examples
#' snp_search("rs7927381")
#' snp_search("TP53")
#'
#' @export
snp_search <- function(
    terms,
    count = 7L,
    offset = 0L,
    assembly = c("GRCh38", "GRCh37")
) {
    assembly <- match.arg(assembly)
    if (identical(assembly, "GRCh38"))
        df <- "rsNum,38.chr,38.pos,38.alleles,38.gene"
    else if (identical(assembly, "GRCh37"))
        df <- "rsNum,37.chr,37.pos,37.alleles,37.gene"
    sf <- df

    response <- request(.CLINTAB_BASE_URL) |>
        req_url_query(
            terms = terms, count = count, offset = offset,
            df = df, sf = sf, cf = "rsNum",
        ) |>
        req_perform() |>
        resp_body_json()

    if (is.null(response) || length(response) < 4L)
        stop("Invalid API data.")

    display_data <- response[[4L]]

    gmcols <- do.call(rbind.data.frame, display_data)
    names(gmcols) <- c("rsids", "seqnames", "pos", "alleles", "genes")

    res <- makeGPosFromDataFrame(gmcols, keep.extra.columns = TRUE)
    genome(res) <- assembly
    res
}
