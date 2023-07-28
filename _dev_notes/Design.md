The basic design of the core program is like this:
- you give it a vote dataframe
- it gives you back the voterank and traditional scores

The calculation works like this:
- convert the voter dataframe into a matrix
- feed the matrix to igraph and get the scores
- create a result dataframe that contains the scores

Ideally we want this all to wrap really nicely with an API

### Modules

Here are the modules I need to write

1. Graph Generator - Makes the vote rank data frame
2. 
