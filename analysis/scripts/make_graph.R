library(igraph)
library(sna)
library(tidyverse)

#' This script contains functions to help build up graphs to study the voting problem
#' make_population - creates a dataframe of n people with true trustworthiness scores

# 1. Graph Construction ----
make_population <- function(pop_size = 100, pareto_shape = log(5,4), seed = NULL){
  #' This function creates a population with scores for popularity and trustworthiness
  #' This population is used subsequently to create the graph

  # 1. Set the seed, for reproducibility; otherwise choose a random seed
  if(is.null(seed)) seed <- sample(1:1000, 1)
  set.seed(seed)
  
  
  # 2. Create the population ID's
  # Use `compose` to make a function, `c` is there because `outer` returns a matrix
  cross_names <- compose(c, partial(outer, X = LETTERS, FUN = paste0))
  ids <- LETTERS  %>% # e.g., "P"
    cross_names() %>% # e.g., "PX"
    cross_names()     # e.g.  "PXH"
    # checks
    assertthat::assert_that(length(ids) == 26^3)
  # 2.1 We only need pop_size many ids
  ids <- sample(ids, pop_size, replace = FALSE)
  
  
  # 3. Create the population trustworthiness scores
  trust_scores <- EnvStats::rpareto(pop_size, location = 1, shape = pareto_shape)
  
  
  # 4. Make the dataframe/tibble
  result <- tibble(id = ids, trust_score = trust_scores)
  
  return(result)
}

#' graph_params -> graph
make_graph <- function(){
  #' This function gives us a simple random graph
  
  #' I don't know what these parameters mean but they work
  dim = 1 # don't know why but it works
  size = 100
  nei = 5 # don't know why
  p = 
  loops = TRUE # loops allowed
  multiple = TRUE # multiple edges allowed
  g <- sample_smallworld(1, 100, 5, 0.05)
  assert()
  
}

# 2. Graph Analysis & Verification ----


# DOCS ------

#' The purpose of this script is to design a set of functions which make it easy to create graphs ad-hoc
#' These graphs should be parameterised and are useful for population base cases
#' A few of them can be saved for future re-use.
#' 
#' main program logic:
#'   input: n - number of people
#'   output: g - a directed graph of votes
#'   procedure: produce a random graph using an R package


## The Model for Graph Formation

#' So we start with multiple overlapping communities; each person can be a member of multiple communities
#' Within each community, we have a random distribution of trustworthiness according to some distribution (say a Pareto)
#' Each person then votes for someone within their community - someone they know, based on trustworthiness
#' And then, from the edge-list, we construct the graph
#' 
#' That means we need the following functions:
#' make_population: generates a list of people with various trustworthiness scores, distributed according to a Pareto distribution
#' make_communities: takes a population and returns a set of realistic communities as undirected graphs, with checks on the graph structure(s) as a whole
#' vote: for each person, let them vote for one of the n most trustworthy people they know, turning the graph into a directed graph but validating the same basic structure
#' poll: take the directed graphs of votes, clean it up and return several summary statistics, tables and charts explaining who voted for whom - for evaluation of the program

# Conclusion
1 + 1
