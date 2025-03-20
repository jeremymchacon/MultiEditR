### server.R for multiEditR

###########################################################################################
# Copyright (C) 2020-2021 Mitchell Kluesner (klues009@umn.edu)
#  
# This file is part of multiEditR (Multiple Edit Deconvolution by Inference of Traces in R)
# 
# Please only copy and/or distribute this script with proper citation of 
# multiEditR publication
###########################################################################################



##### Server function -------------------------------------------------------------
shinyServer(
  function(input, output, session) {
    
 
    
    
    #######
    # BATCH MODE - added by J Chacón
    ######
    # reads the uploaded parameters excel sheet into a reactive
    # with just basenames for seq files
    multiEditR_params <- reactive({
      req(input$batch_parameters)
      dat = readxl::read_excel(input$batch_parameters$datapath)
      dat
    })
    
    # shows the parameters table you uploaded
    output$parameter_table <- renderDT({
      req(input$batch_parameters)
      DT::datatable(multiEditR_params())
    })
    
    # makes the sequence file names have the full path (on the server)
    # so that multiedtiR can find them
    params = reactive({
      req(c(input$batch_parameters, input$batch_files))
      if (nrow(missing_files()) == 0){      
        params = add_paths(multiEditR_params(), input$batch_files)
        params$sample_file = params$sample_path
        params$ctrl_file = params$ctrl_path
        params
      }else{
        NULL
      }
    })
    
    # the function that actually adds the paths to the sample names
    add_paths = function(params, batch_files){
      params$sample_path = NULL
      params$ctrl_path = NULL
      for (i in 1:nrow(params)){
        params$sample_path[i] = batch_files$datapath[batch_files$name == params$sample_file[i]]
        params$ctrl_path[i] = batch_files$datapath[batch_files$name == params$ctrl_file[i]]
      }
      params
    }
    
    # determines from the parameters sheet what sequence files are needed
    sequence_files_required <- reactive({
      req(c(multiEditR_params()))
      #print(input$batch_files$name)
      sample_files = multiEditR_params()$sample_file
      control_files = multiEditR_params()$ctrl_file
      needed_files = unique(c(sample_files, control_files))
      needed_files = data.frame(`Sequence Files Needed:` = needed_files)
      needed_files
    })
    
    # shows which sequence files are needed
    output$needed_sequence_files <- renderTable({
      sequence_files_required()
    })
    
    # after you upload sequence files, determines what you missed (if any)
    missing_files = reactive({
      req(c(sequence_files_required(), input$batch_files))
      uploaded_files = input$batch_files$name
      missing_files = setdiff(sequence_files_required()[,1], uploaded_files)
      data.frame(`Sequence Files Missing:` = missing_files)
    })
    
    # shows the missing files
    output$missing_files = renderTable({
      req(c(sequence_files_required(), input$batch_files))
      missing_files()
    })
    
    # shows button to run multiEditR, but only if there aren't missing seq files
    output$run_button <- renderUI({
      if (!is.null(missing_files()) && nrow(missing_files()) == 0){
        actionButton("run_batch_mode", "Run multiEditR")
      }
    })
    
    # runs the analysis and stores the result in the reactive output_data
    output_data <- reactive({
      req(c(input$batch_parameters, input$batch_files))
      if (nrow(missing_files()) == 0){
        analysis()
      }
    })
    
    # the actual calling of multiedtiR
    analysis <- reactive({
      req(c(input$batch_parameters, input$batch_files))
      if (nrow(missing_files()) == 0){
        my_params = params()
        all_results = multiEditR::detect_edits_batch(my_params)
        all_results
      }
    })    
    
    # futzes with the results table and shows it
    output$combined_results_table <- DT::renderDataTable({
      req(c(input$batch_parameters, input$batch_files))
      if (nrow(missing_files()) == 0){
        all_results = analysis()
        # next line is to remove failed samples from table
        all_results = all_results[sapply(all_results, FUN = function(x){x$completed})]
        main_table = lapply(all_results, FUN = function(x){x[[1]]}) %>% do.call(rbind, .)
        main_table$A_perc = signif(main_table$A_perc,3)
        main_table$C_perc = signif(main_table$C_perc,3)
        main_table$T_perc = signif(main_table$T_perc,3)
        main_table$G_perc = signif(main_table$G_perc,3)
        #main_table = cbind(main_table[,ncol(main_table)], main_table[, 1:(ncol(main_table)-1)])
        print(main_table)
      }else{
        print("Output Will Appear Here")
      }
    },
    server = FALSE,
    extensions = c('Buttons'), 
    options = list(
      dom = 'Bfrtip',
      buttons = c('copy', 'csv', 'excel')
    ))
    
    # shows a render-and-download button, after the analysis finishes
    output$render_and_dl_button <- renderUI({
      if (!is.null(analysis())){
        downloadButton("render_and_dl", "Render and Download HTML report\n(this will take a minute)")
      }
    })
    
    # compiles the HTML report and saves it to your downloads
    output$render_and_dl <- downloadHandler(
      filename = "batch_report.html",
      content = function(file) {
        # to show loading message
        showModal(modalDialog("Preparing Report...(please expect 1-3 minutes depending on the number of samples)", footer=NULL))
        on.exit(removeModal())
        # Copy the report file to a temporary directory before processing it, in
        # case we don't have write permissions to the current working dir (which
        # can happen when deployed)
        rmd_loc = paste0(system.file(package = "multiEditR"),
                         "/batch_report_template.Rmd")
        temp_dir <- tempdir()
        temp_rmd_loc <- file.path(temp_dir, "batch_report_template.Rmd")
        file.copy(rmd_loc, temp_rmd_loc)
        
        
        my_params = params()
        my_data = output_data()
        rmarkdown::render(temp_rmd_loc, 
                          #runtime = "shiny",
                          output_file = file,
                          params = list(params.tbl = my_params, 
                                        results.list = my_data),
                          envir = new.env(parent = globalenv()))
      }
    )

  }
)
