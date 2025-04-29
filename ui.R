### ui.R for multiEditR

###########################################################################################
# Copyright (C) 2020-2021 Mitchell Kluesner (klues009@umn.edu)
#  
# This file is part of multiEditR (Multiple Edit Deconvolution by Inference of Traces in R)
# 
# Please only copy and/or distribute this script with proper citation of 
# multiEditR publication
###########################################################################################

# EditR UI
version = "1.1.1"
update = "Feb 28, 2024"

shinyUI(
  navbarPage("multiEditR",
             
 
             tabPanel("Batch Mode",
                      fluidPage(
                        theme = shinythemes::shinytheme("cerulean"),
                        headerPanel(paste0("MultiEditR batch mode, v1.0")),
                        sidebarLayout(
                          sidebarPanel(
                            em(paste0("Please note this application is under development.")),
                            em(paste0("Updated ", "2025-04-28", ".")),
                            p(),
                            tags$a(href="https://www.cell.com/molecular-therapy-family/nucleic-acids/fulltext/S2162-2531(21)00176-1", "Please cite our Nucleic Acids paper!"),
                            p(),
                            fileInput("batch_parameters", NULL, buttonLabel = "Upload Parameters excel sheet",
                                      accept = c(".xlsx", ".xls"),
                                      label = "Upload a Parameters Excel spreadsheet",
                                      multiple = FALSE),
                            fileInput("batch_files", NULL, buttonLabel = "Upload Sequence Files (.fasta or .ab1)...",
                                      accept = c(".fa",".fasta", ".ab1") ,
                                      label = "Upload All Sequence Files at Once",
                                      multiple = TRUE)
                          ),
                          mainPanel(
                            tabsetPanel(type = "tabs",
                                        tabPanel("Instructions",
                                                 fluidPage(
                                                   tags$iframe(src = "batch_instructions.html",
                                                               allowfullscreen = "true",
                                                               seamless = NA,
                                                               width = 800,
                                                               height = 4800,
                                                               scrolling = "no",
                                                               frameborder = 0)
                                                   #htmltools::includeHTML("www/batch_instructions.html")
                                                   )
                                        ),
                                        tabPanel("Analysis",
                                                 h1("Batch Analysis"),
                                                 em("Upload a parameters table to start seeing output. Click the Instructions tab for details."),
                                                 conditionalPanel("input.parameters",
                                                                  HTML("<b>The parameters table you upload will appear here:</b>")
                                                 ),
                                                 h2("Parameters Table"),
                                                 DT::dataTableOutput("parameter_table"),
                                                 h2("Sequence files needed based upon Parameters Table"),
                                                 fluidRow(
                                                   column(width = 4, tableOutput("needed_sequence_files")),
                                                   column(width = 4, tableOutput("missing_files"))
                                                 ),
                                                 h2("Click Run to start analysis:"),
                                                 em("Run button appears when all sequence files are uploaded"),
                                                 uiOutput('run_button'),
                                                 conditionalPanel("input.run_batch_mode",
                                                                  em("results and download buttons will appear once analysis is complete..."),
                                                                  HTML("<br>"),
                                                                  h2("Click below to download HTML report"),
                                                                  uiOutput('render_and_dl_button'),
                                                                  HTML("<br>"),
                                                                  h2("Combined Results Table:"),
                                                                  em("note: failed samples do not appear in this table. Check the downloadable report if samples in the parameters sheet do not appear here."),
                                                                  shinycssloaders::withSpinner(
                                                                    DT::dataTableOutput("combined_results_table")
                                                                  ),
                                                 )
                                        ),
                                        tabPanel("FAQ",
                                                 fluidPage(
                                                   htmltools::includeMarkdown(path = "www/FAQ.md")
                                                 )
                                        )
                            )
                          )
                        )
                      )
             )
             
  )
)