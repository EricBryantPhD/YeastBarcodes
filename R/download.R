#' Download barcodes
#'
#' Download barcodes from the \href{http://www-sequence.stanford.edu/group/yeast_deletion_project/deletions3.html}{yeast gene deletion consortium}
#'
#' @param to directory path. Where to download barcodes.
#' @param set One or more of \code{c('a', 'alpha', 'het', 'hom')}. Which collection of barcodes to download.
#'
#' @return Returns a dataframe with five columns.
#'
#' \itemize{
#'   \item{strain_id}{An ID for this strain. Begins with the characters "rec" followed by the record number.}
#'   \item{orf}{The original systematic ORF designation for this strain. Note that a few ORF IDs have been removed or changed.}
#'   \item{uptag}{The 20 NT uptag sequence for the corresponding strain.}
#'   \item{dntag}{The 20 NT dntag sequence for the corresponding strain.}
#'   \item{type}{Type of strain. One of "a", "alpha", "het", or "hom" for MATa, MATalpha, Heterozygous diploid and Homozygous diploid.}
#' }
#'
#' @importFrom readr write_csv read_tsv
#' @importFrom Biostrings reverse chartr
#' @importFrom assertthat is.dir assert_that
#' @import dplyr
#' @export

download_barcodes <- function(to = '.', set = c('a', 'alpha', 'het', 'hom')) {

  assert_that(is.dir(to), all(set %in% c('a', 'alpha', 'het', 'hom')))

  lapply(set, function(this_set) {
    switch(
      this_set,
      # MATa barcodes
      a = download(
        name = 'a',
        file = file.path(to, 'MATa-barcodes.csv', fsep = '/'),
        from = 'http://www-sequence.stanford.edu/group/yeast_deletion_project/strain_a_mating_type.txt',
        cols = 'cc____________________cc____'
      ),
      # MATalpha barcodes
      alpha = download(
        name = 'alpha',
        file = file.path(to, 'MATalpha-barcodes.csv', fsep = '/'),
        from = 'http://www-sequence.stanford.edu/group/yeast_deletion_project/strain_alpha_mating_type.txt',
        cols = 'cc___________________cc____'
      ),
      # Heterozygous diploid barcodes
      het = download(
        name = 'het',
        file = file.path(to, 'Heterozygous-barcodes.csv', fsep = '/'),
        from = 'http://www-sequence.stanford.edu/group/yeast_deletion_project/strain_heterozygous_diploid.txt',
        cols = 'cc____________________cc'
      ),
      # Homozygous diploid barcodes
      hom = download(
        name = 'hom',
        file = file.path(to, 'Homozygous-barcodes.csv', fsep = '/'),
        from = 'http://www-sequence.stanford.edu/group/yeast_deletion_project/strain_homozygous_diploid.txt',
        cols = 'cc____________________cc__'
      )
    )
  })

}

download <- function(name, file, from, cols) {
  from %>%
    read_tsv(
      col_types = cols,
      col_names = c('strain_id', 'orf', 'uptag', 'dntag'),
      skip = 2
    ) %>%
    mutate_(
      type      = ~name,
      strain_id = ~paste0('rec', strain_id),
      dntag     = ~reverse(chartr('ATGC', 'TACG', dntag)), # reverse complement the downtags?
      dntag     = ~ifelse(dntag == 'NA', NA, dntag)
    ) %>%
    write_csv(file)
}
