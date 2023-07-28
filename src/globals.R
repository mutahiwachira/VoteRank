# Global Libraries ----
library(here)

# for graphs
library(igraph)

# for quality control
library(validate)
library(testthat)
library(assertthat)
library(checkmate)

# for general data wrangling
library(tidyverse)
library(ggplot2)

# __________________________________

# Global Vars & Params -----
get_globals <- function(){
  lst_globals <- list()
  
  lst_globals$paths <- list()
  lst_globals$paths <- within(lst_globals$paths, {
    project_path <- here::here()
    data_path    <- here(project_path, "data")
    votes_path   <- here(data_path, "votes")
    vote_files   <- here(votes_path, dir(votes_path, pattern = "[voteset]*\\.csv")) %>% 
      set_names(dir(votes_path, pattern = "[voteset]*\\.csv") |> str_remove(".csv"))
  })
  
  return(lst_globals)
}

#' NOTES
#' maybe the vote_files don't need to be a named vector; or maybe the name of the 
#' dataset doesn't need to have csv?



