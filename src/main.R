# Modules
project_path <- here::here()
source(here(project_path, "src/globals.R"))
source(here(project_path, "src/model/model.R"))

# Libraries

# main :: paths to data -> voterank scores
main <- function(voting_dataset = "voteset", globals = get_globals()){
  #' This function takes in a set of votes and runs the entire program
  #' It returns the votes as well as the vote rank scores and a log of side-effect artefacts
  votes <- readr::read_file(globals$paths$vote_files[[voting_dataset]])
  
  # pre-checks / assumptions
  assertions <- get_main_assertions_fns()
  assertions$test_input_votes(votes)
  
  # 1 - core logic
  result <- vote_rank(votes)
  
  # guarantees
  assertions$test_results(result)
  
  return(result)
}

# QA Functions ----
get_main_assertions_fns <- function(){
    # 1 - Setup
    # ______________________
  
    # 1.1 - the return object
  list_main_assertions <- list()
    # 1.2 Params
  cols_for_results <- c("people", 
                        "voterank_score", 
                        "votes_received")
  
    # 2 - Functions
    # ______________________
  list_main_assertions <- within(list_main_assertions, {
    
    test_input_votes <- function(votes){
      checkmate::checkDataFrame(
        votes,
        types = "character",
        ncols = 2,
        col.names = c("voter", "voted_for")
      )
    }
    
    # 2.1
    test_results <- function(result){
      #' Checks the voterank output in the main() program
      checkmate::assertDataFrame(result)
      assertthat::assert_that(all(colnames(result) %in% cols_for_results))
    }
    
  })
  
  return(list_main_assertions)
}

if(interactive()) main()


# NOTES
# - need to validate the files being read in at the top of main: 
# - - do the files exist, check for when we do and do not use the extension...
# I've set up the basic TDD structure for level 1; I need to beef that up then I can start devving.