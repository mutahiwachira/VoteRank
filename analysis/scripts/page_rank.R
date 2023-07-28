library(igraph)

library(tidyverse)

library(validate)
library(tinytest)
library(assertr)
library(assertive)
library(here)

# globals ----
proj_path <- here::here()

# utilities
matrix_convert <- function(matrix, conversion){
  match.fun(conversion)
  matrix(conversion(matrix), nrow = nrow(matrix), ncol = ncol(matrix), dimnames = dimnames(matrix))  
}


# CRUD ----
get_vote <- function(vote_matrix_file){
  # Pre-Conditions
  checkmate::assertString(vote_matrix_file)
  checkmate::assertFile(vote_matrix_file,extension = ".csv")
  
  raw <- readr::read_csv("analysis/scripts/example_vote_matrix.csv", col_types = (cols("c",.default = "l"))) %>% 
    as.data.frame()
  colnames(raw)[1] <- "Voter"
  rownames(raw) <- raw[,"Voter"]
  raw[,"Voter"] <- NULL
  
  voters <- raw$Voter
  raw <- as.matrix(raw)
  
  raw[is.na(raw)] <- FALSE
  res <- matrix_convert(raw, as.numeric)
    votes_per_person <- apply(res, 1, sum)
    assertthat::assert_that(res |> is.matrix(),
                            all(votes_per_person == 1),
                            nrow(res) == ncol(res))
    
  return(res)
}

add_small_links <- function(incidence_matrix){
  # checks
  assertthat::assert_that(
    is.matrix(incidence_matrix),
    all(incidence_matrix %in% c(0,1))
  )
  
  incidence_matrix = 100*incidence_matrix + 0*abs(rnorm(length(incidence_matrix), mean = 10, sd = 3))
  
  return(incidence_matrix)
}

# main() -----
data_path <- here("analysis", "scripts", "example_vote_matrix.csv")
vote_matrix <- get_vote(data_path)
vote_matrix <- add_small_links(vote_matrix)
rownames(vote_matrix) <- replace(rownames(vote_matrix), rownames(vote_matrix) == "Peter", "Phakeng")
colnames(vote_matrix) <- replace(colnames(vote_matrix), colnames(vote_matrix) == "Peter", "Phakeng")
diag(vote_matrix) <- 0
vote_graph <- graph_from_adjacency_matrix(vote_matrix, 
                                          mode = "directed",
                                          weighted = TRUE,
                                          diag = FALSE)

page_rank_results <- page_rank(vote_graph)

results <- page_rank_results$vector[unique(names(page_rank_results$vector))]
candidates <- names(results)

df_vote_rank <- page_rank_results %>% 
  pluck("vector") %>% 
  as_tibble() %>% 
  mutate(candidate = candidates) %>% 
  mutate(voterank_score = value * 1000) %>% 
  arrange(desc(voterank_score)) %>% 
  select(candidate, voterank_score)

df_vote_tally <- vote_matrix %>% 
  apply(2, sum) %>% 
  as_tibble() %>% 
  mutate(candidate = candidates) %>% 
  select(candidate, total_votes = value)
  
df_results <- left_join(df_vote_rank, df_vote_tally, by = "candidate")

df_results %>% 
  mutate(voterank_position    = match(voterank_score, sort(unique(voterank_score), decreasing = TRUE))) %>% 
  mutate(total_votes_position = match(total_votes, sort(unique(total_votes), decreasing = TRUE))) %>% 
  mutate(pct_votes            = total_votes / sum(total_votes),
         pct_pr_score         = voterank_score / sum(voterank_score)) %>% 
  arrange(voterank_position) %>% 
  View("Final Results")

igraph::tkplot(vote_graph)
