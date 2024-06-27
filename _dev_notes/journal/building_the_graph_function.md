---
Problem: Building the Graph Constructor Module
Date: 20230728
---

# First Attempt
----

# Conceptualising

Okay so I want to create a function which is actually going to make the graph object.

To start with, I want the graph to be super realistic: Very skew distribution for popularity - most people know a handful of other people but the super popular have their phones absolutely buzzing all the time. It's very important to me to generate a realistic social graph.

I'm gonna overlay the social graph with the population dataframe such that true trustworthiness scores are randomly assigned to nodes - trustworthiness doesn't correlate with popularity.

Of course, ultimately the goal is to *generalise*: - I should be able to provide the graph algo with a population dataframe with various characteristics, and build a graph that aligns with that - I should be able to choose various strategies for building up a graph, enums...

I also want a few extra functions for investigating the graph which has been created. Like I should be able to see if the graph constructed matches the population and parameters I supplied.

Also, it would be cool to generate multiple graphs, not just one.

All of that is down the road right?

### Strategy

So basically what I'm gonna is broken down into 3 steps:

-   Create a social graph of who knows whom - undirected and very realistic in terms of how real societies work (clusters, very assymetrical dist. for popularity)
-   Associate the nodes of this graph with the population dataframe incl. scores for trustworthiness
-   From this graph, extract a directed trust graph

Step three is the trick. If a person in a node knows like 10 people, how do they 'vote' for the person they trust? It is a simple procedure that works like this:

-   I know 10 people
-   For each of them, I perceive them to have trustworthiness score *t* (which will be an estimator of the true trustworthiness scores, obfuscated because individuals are not always good judges of character).
-   Then we just choose the top person

### Graph Construction with igraph

So igraph includes quite a few functions for graph construction based on a strategy. See [this link](https://r.igraph.org/reference/index.html#construction).





# Ideating & Prototyping

Check out `sna`, `igraph` and `tidygraph` documentation for ideas about building realistic graphs. For graph plotting and descriptive analytics: <https://www.r-bloggers.com/2010/04/social-network-analysis-using-r-and-gephis/>

## Research Notes

### The Small World Model
I'm choosing this as my starting model.

From [wikipedia](https://en.wikipedia.org/wiki/Small-world_network):

> A small-world network is a mathematical graph in which most nodes are not neighbors of one another, but the neighbors of any given node are likely to be neighbors of each other.

Seems to have the nice properties of what I want in a social graph. Also see [this](https://en.wikipedia.org/wiki/Watts–Strogatz_model).

## Further Research To Do / Questions

### The Graph Model

Some questions:
* What do the parameters of the Watts-Strogatz model in `igraph` actually mean?


# Scaffolding and TDD

## General Tests

### Basic Functionality

* make_graph returns a simple graph
* the graph has names and information associated with it
* the graph has realistic features of a social graph and the graph validation includes the following features, with realistic ranges:
  * degree distribution
  * connectedness & community structure

## Functions: Requirements, Design and Tests

### `make_graph`

#### Rough Example

Just call `igraph::smallworld` with parameters matched to the population df and return that.

#### Requirements
This function will house the actual graph generation.

#### Design
**Inputs**

* `population` - a dataframe as from make_population, we need this to actually make the nodes meaningful
* (selected graph params) - depending on the model chosen, we need to create graph params; perhaps some even automatically from the population model

**Outputs**

* `graph` - a random graph with everything built into it for study and ranking

**Internal Design**

**Interface Design**


#### Unit Tests

* The function can take a population dataframe
* The function fails nicely when no dataframe is provided
* The function handles a zero length dataframe correctly
* The function handles a <20 length dataframe correctly
* The function never produces two or more disconnected subgraphs
* The function produces random graphs but has a seed which will produce the same graph each time












# Building Further

There's so much more that could be done

We could have parameters that affect all of the following:

-   Strength of interpersonal knowledge - how well do two people know each other actually?
-   Character judgements - given some true parameter T for trustworthiness, how good is a particular person at estimating T with *t*. What does the distribution of the quality of judgements look like?
-   Are people more inclined to trust people they know well or strangers?
-   In practise, people might forget who the most trustworthy person is (and choose the wrong person). It would be nice to sample from the top 3 equally.

# Second Attempt
-----

Okay, there is just too much to do and it's overwhelming.
Let's start with a simple graph and get the scaffolding in-place first.