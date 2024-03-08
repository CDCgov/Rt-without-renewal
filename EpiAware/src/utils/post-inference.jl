"""
    spread_draws(chn::Chains)

Converts a `Chains` object into a DataFrame in `tidybayes` format.

# Arguments
- `chn::Chains`: The `Chains` object to be converted.

# Returns
- `df::DataFrame`: The converted DataFrame.
"""
function spread_draws(chn::Chains)
    df = DataFrame(chn)
    df = hcat(DataFrame(draw = 1:size(df, 1)), df)
    @rename!(df, $(".draw")=:draw)
    @rename!(df, $(".chain")=:chain)
    @rename!(df, $(".iteration")=:iteration)

    return df
end
