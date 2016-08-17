#---- src_barcodes ---------------------------------------------------------
#' Connect to the barcodes database
#'
#' Connect to the barcodes SQLite database.
#'
#' @importFrom RSQLite SQLite
#' @importFrom easydb db_config db_build
#' @export
#'
#' @examples
#'
#' # Connect to the database
#' db <- src_barcodes()
#' db
#'

src_barcodes <- function() {
  # Read configuration file
  cnf <- system.file('db/_barcodes.yaml', package = 'YeastBarcodes') %>% db_config()

  # Build the database if it does not exist
  if (!file.exists(cnf$db)) suppressWarnings(db_build(cnf))

  # Connect to the database
  src <- src_sqlite(cnf$db) %>% add_class('src_barcodes')
  src$cnf <- cnf
  return(src)
}


#---- src_rothscreen methods --------------------------------------------------
#' @export
src_desc.src_barcodes <- function(x) {
  paste0(
    'sqlite ', x$info$serverVersion,
    ' [YeastBarcodes - ', packageVersion('YeastBarcodes'), ']'
  )
}

#' @export
tbl.src_barcodes <- function(src, from, ...) {
  tbl_sql('sqlite', src = src, from = from, ...) %>% add_class('tbl_barcodes')
}

#' @export
collect.tbl_barcodes <- function(x, ...) {

  result <- drop_class(x) %>% collect(...)
  coltypes <- x$src$cnf$column_types
  present <- intersect(names(coltypes), names(result))

  if (length(present)) {
    coerce <- coltypes[present]
    for (i in 1:length(coerce)) {
      type   <- coerce[[i]]
      column <- names(coerce[i])
      result[[column]] <-
        switch(
          type,
          logical   = as.logical(result[[column]]),
          integer   = as.integer(result[[column]]),
          character = as.character(result[[column]]),
          numeric   = as.numeric(result[[column]]),
          double    = as.numeric(result[[column]]),
          factor    = as.factor(result[[column]])
        )
    }
  }
  # Coerce to desired column type
  return(result)
}


#---- OO Utilities ------------------------------------------------------------
# Add an S3 subclass in pipeline
# @param x an S3 object
# @param ... Character; S3 subclasses to add to object
add_class <- function(x, ...) { class(x) <- c(..., class(x)); return(x) }

# Drop an S3 subclass in pipeline
# @param x an S3 object
drop_class <- function(x) { class(x) <- class(x)[-1]; return(x)}
