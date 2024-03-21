"""
Create a half-normal prior distribution with the specified mean.

# Arguments
- `prior_mean::AbstractFloat`: The mean of the prior distribution.

# Returns
- `Truncated{Normal}`: The half-normal prior distribution.

"""
function HalfNormal(prior_mean::AbstractFloat)
    return truncated(Normal(0.0, prior_mean * sqrt(pi) / sqrt(2)), 0.0, Inf)
end
