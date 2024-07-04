"""
Extract a parameter array from a `Chains` object `chn` that matches the shape of number of sample
and chain pairs in `chn`.

# Arguments
- `chn::Chains`: The `Chains` object containing the MCMC samples.

# Returns
- `param_array`: An array of parameter samples, where each element corresponds to a single
MCMC sample as a `NamedTuple`.

# Example

Sampling from a simple model which has both scalar and vector quantity random variables across
4 chains.

```jldoctest; filter = r\"\b\d+(\.\d+)?\b\" => \"*\"
using Random, StableRNGs, Turing, MCMCChains, EpiAware
Random.seed!(StableRNG(1234), 1234)

@model function testmodel()
    y ~ Normal()
end
mdl = testmodel()
chn = sample(mdl, Prior(), MCMCSerial(), 2, 1, progress=false)

A = get_param_array(chn)
# output
2×1 Matrix{@NamedTuple{iteration::Int64, chain::Int64, y::Float64, lp::Float64}}:
 (iteration = 1, chain = 1, y = 1.2817564703577078, lp = -1.7403883578565975)
 (iteration = 2, chain = 1, y = 0.7259423762267098, lp = -1.1824347000055138)
```
"""
function get_param_array(chn::Chains)
    rowtable(chn) |> x -> reshape(x, size(chn, 1), size(chn, 3))
end
