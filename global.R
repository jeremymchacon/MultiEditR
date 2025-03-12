### global.R for multiEditR

###########################################################################################
# Copyright (C) 2020-2021 Mitchell Kluesner (klues009@umn.edu)
#  
# This file is part of multiEditR (Multiple Edit Deconvolution by Inference of Traces in R)
# 
# Please only copy and/or distribute this script with proper citation of 
# multiEditR publication
###########################################################################################

### Options
# turn on universal error message:
# "Error: An error has occurred. Check your logs or contact the app author for clarification."
options(shiny.sanitize.errors = TRUE)
### Libraries
library(multiEditR)
library(DT)
library(shiny)
library(shinythemes)
library(shinycssloaders)
library(markdown)


