source("config/api_config.R")
source("config/queries.R")
source("R/pipefy_connector.R")
source("R/validations.R")
source("R/data_processing.R")
source("R/file_processing.R")
source("R/helpers.R")

library(shiny)
library(bslib)
library(DT)
library(tidyverse)
library(ghql)
library(jsonlite)
library(reactable)
library(shinyWidgets)


