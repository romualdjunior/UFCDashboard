setwd("C:/Romuald/Travail personnel React/Data Analyst/Tidy-Tuesday/Season 1/Apps/TidyTuesdayDashboardLevels")

update.packages(checkBuilt = TRUE, ask = FALSE)


install.packages("shiny")
install.packages("tidyverse")
install.packages("elo")
install.packages("plotly")
install.packages("shinydashboard")
install.packages("stringr")
install.packages("tidyr")
install.packages('dplyr')
install.packages('callr')
install.packages('gargle')
install.packages('googlesheets4')
install.packages('modelr')
install.packages('reprex')
install.packages('tidyverse')
install.packages('Rcpp', repos='http://cran.r-project.org/')
install.packages('vctrs')
install.packages('devtools')
install.packages('fs')




library("shiny")
library("elo")
library("plotly")
library("shinydashboard")
library("stringr")
library("tidyr")
library("dplyr")
library('callr')
library('gargle')
library('googlesheets')
library('Rcpp')
require("devtools")



source("dashboard_helper.R")
source("server.r")
source("ui.r")




shinyApp(ui = ui, server = server)
