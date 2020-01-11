# Check Yer Yeast Barcodes!

This is an R package that includes an application for checking sequenced barcodes from the yeast gene deletion collection.

## Install

```r
if (!require(devtools))      install.packages('devtools')
if (!require(BiocInstaller)) source('https://bioconductor.org/biocLite.R')

# Install two packages available on GitHub
BiocInstaller::biocLite(
  'EricBryantPhD/easydb',
  'EricBryantPhD/YeastBarcodes'
)
```

## Usage

The `check_barcodes` function takes a vector of sequences and returns the closest matching barcode.

```r
library(YeastBarcodes)

# Inputs
seqs <- c('GCGACTATCGAACCATATAC', 'TCCATGATGTAAACATCCGA')
set <- 'a'  # one or more of c('a', 'alpha', 'het', 'hom')

# Run the function
check_barcodes(seqs, set)

# Returns the closest match for each input sequence:
#   seq_numb strain_id             sequence                  tag     score
#      <int>     <chr>                <chr>                <chr>     <dbl>
# 1        1   rec2458 GCGACTATCGAACCATATAC GCGACTATCGAACCATATAC 39.635117
# 2        2    rec775 TCCATGATGTAAACATCCGA CCATGATGTAAACGATCCGA  9.653366
```

There is also an Rstudio AddIn that makes it easy to check a single sequence. To launch this application in Rstudio, simply click on the "Addins" dropdown menu and select "Check Strain Barcodes". Or, run `check_barcodes_app()`.
