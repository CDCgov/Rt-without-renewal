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

```julia
using Turing, MCMCChains, EpiAware

@model function testmodel()
    x ~ MvNormal(2, 1.)
    y ~ Normal()
end
mdl = testmodel()
chn = sample(mdl, Prior(), MCMCSerial(), 250, 4)

A = get_param_array(chn)
```
"""
function get_param_array(chn::Chains)
    rowtable(chn) |> x -> reshape(x, size(chn, 1), size(chn, 3))
end
