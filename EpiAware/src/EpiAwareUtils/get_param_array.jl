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
    idxs = CartesianIndices((1:size(chn, 1), 1:size(chn, 3)))
    param_array = map(idxs) do I
        s = MCMCChains.get_sections(chn, :parameters) |>
            chn -> get_params(chn[I[1], :, I[2]])
        map(s) do x
            # Maps repeated names of type x[1] x[2] etc into a vector
            _s = [_x[1] for _x in x] |> Array
            # Scalar variables come back as scalars
            _s = size(_s) == (1, 1) ? _s[1] : _s
        end
    end
    return param_array
end
