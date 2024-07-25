"""
Compute the empirical Continuous Ranked Probability Score (CRPS) for a predictive
distribution defined by the samples `forecasts` with respect to an observed value
`observation`.

The CRPS is defined as the sum of the Mean Absolute Error (MAE) and a pseudo-entropy
term that measures the spread of the forecast distribution.

```math
CRPS = E[|Y - X|] - 0.5 E[|X - X'|]
```
Where `Y` is the observed value, and `X` and `X'` are two random variables drawn from the
forecast distribution.

# Arguments
- `forecasts`: A vector of forecasted values.
- `observation`: The observed value.

# Returns
- `crps`: The computed CRPS.

# Example
```julia
using EpiAwarePipeline
forecasts = randn(100)
observation = randn()
crps = simple_crps(forecasts, observation)
```
"""
function simple_crps(forecasts, observation)
    @assert !isempty(forecasts) "Forecasts cannot be empty"
    mae = mean(abs, forecasts .- observation)
    pseudo_entropy = -0.5 * mean(abs, [x - y for x in forecasts, y in forecasts])
    return mae + pseudo_entropy
end
