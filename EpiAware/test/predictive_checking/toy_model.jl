# Toy model for running analysis

using EpiAware
using Turing
using Distributions

## Define `EpiModel` struct

truth_GI = Gamma(1, 2)
truth_delay = Gamma(1, 1)
