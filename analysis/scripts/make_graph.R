library(igraph)
library(tidyverse)
library(assertthat)

conflicts_prefer(purrr::compose, .quiet = TRUE)
conflicts_prefer(igraph::degree, .quiet = TRUE)

library(testthat)
#' This script contains functions to help build up graphs to study the voting problem
#' make_population - creates a dataframe of n people with true trustworthiness scores

# 0. main()
# For extraction into a higher level of the program
main_make_graph_ <- function(seed = NULL){
  pop_size   = 500
  avg_degree = 10
  
  population <- make_population(pop_size, seed = seed)
  graph      <- make_graph(population, avg_degree)
  
  result <- list(
    population = population,
    graph = graph
  )
  
  return(result)
}

# _____________________________________________________________


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
make_graph <- function(population_df, avg_degree = 10){
  #' This function gives us a simple random graph
  
  # Get the number of rows from the population_df
  num_vertices = nrow(population_df)
  assert_that(num_vertices <= 500,
              msg = "make_graph only works for less than 500 people.")
  p_degree = avg_degree / num_vertices
  assert_that(avg_degree < num_vertices, 
              msg = "avg_degree must be less than number of people in the population")
  
  #' I don't know what these parameters mean but they work
  g <- sample_gnp(num_vertices, p_degree)
  
  #TODO: Associate the actual entries from population_df here
  
  return(g)
}

#' social_graph -> voting_graph
get_trust_graph <- function(social_graph){
  #' The social graph should have the trustworthiness of each person
  #' 
  #' Basic procedure:
  #' From the edgelist, for each person in the edgelist, let them evaluate the trustworthiness of the members and then vote for a person
  #' Yields an edgelist which in turn yields a simple directed graph.
}

# _____________________________________________________________


# 2. Graph Analysis & Verification ----



# _____________________________________________________________

# X. Tests ----

testthat::test_that("make_graph constructs a graph given population", {
  # Given: A Population
  pop_df <- make_population(seed = 12)
  
  # When: We Construct the Graph with `make_graph`
  g <- make_graph(pop_df,avg_degree = 10)
  
  # Then: The result is indeed a graph object
  expect_s3_class(g, "igraph")
})


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