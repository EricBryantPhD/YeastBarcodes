#' Given a vector of sequences, check barcodes by aligning
#'
#'
#' @param sequences Vector of barcode sequence results (i.e. vector of strings of 20 nucleotides).
#' @param set One or more of \code{c('a', 'alpha', 'het', 'hom')}. Which collection of barcodes to check.
#'
#' @importFrom tidyr gather_
#' @importFrom Biostrings pairwiseAlignment
#' @export

check_barcodes <- function(sequences, set = c('a', 'alpha', 'het', 'hom')) {

  barcodes <- src_barcodes() %>% tbl('barcodes') %>% filter_(~type %in% c('_', set)) %>% collect

  tags <-
    barcodes %>%
    select_(~strain_id, ~uptag, ~dntag) %>%
    gather_('tag_type', 'tag', c('uptag', 'dntag')) %>%
    filter_(~complete.cases(.))

  result <-
    lapply(1:length(sequences), function(i) {
      tags %>%
        mutate_(
          score       = ~pairwiseAlignment(tag, sequences[i], scoreOnly = T),
          seq_numb    = ~i,
          sequence    = ~sequences[i]
        ) %>%
        filter_(~row_number() == which.max(score))
    }) %>%
    bind_rows %>%
    select_(~seq_numb, ~strain_id, ~sequence, ~tag, ~score)

  return(result)
}




#' Check Barcodes Shiny App
#'
#' Lookup a single sequenced barcode
#'
#' @importFrom miniUI miniPage miniContentPanel gadgetTitleBar
#' @importFrom shiny renderTable radioButtons textInput h4 tableOutput runGadget dialogViewer
#' @export


check_barcodes_app <- function() {

  # ---- Server ----
  server <- function(input, output, session) {

    output$result <- renderTable({
      check_barcodes(sequences = input$sequence, set = input$set) %>%
        select_(Strain = ~strain_id, Match = ~tag, Score = ~score)
    })
  }

  # ---- User Interface ----
  ui <- miniPage(
    gadgetTitleBar('Check Strain Barcodes', left = NULL, right = NULL),
    miniContentPanel(
      radioButtons('set', 'Strain Collection', choices = c('MATa' = 'a', 'MATalpha' = 'alpha', 'Heterozygous' = 'het', 'Homozygous' = 'hom'), selected = 'a', inline = T),
      textInput('sequence', 'Sequence', value = 'GCGACTATCGAACCATATAC'),
      h4('Closest Match'),
      tableOutput('result')
    )
  )

  # ---- Run ----
  runGadget(ui, server, viewer = dialogViewer('', width = 850, height = 1000))
}
