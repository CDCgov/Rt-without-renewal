function _expand_dist(dist::Vector{D} where {D <: Distribution})
    d = length(dist)
    product_dist = all(first(dist) .== dist) ?
                   filldist(first(dist), d) : arraydist(dist)
    return product_dist
end

"""
Create a half-normal prior distribution with the specified mean.

# Arguments
- `prior_mean::AbstractFloat`: The mean of the prior distribution.

# Returns
- `Truncated{Normal}`: The half-normal prior distribution.

"""
function _make_halfnormal_prior(prior_mean::AbstractFloat)
    return truncated(Normal(0.0, prior_mean * sqrt(pi) / sqrt(2)), 0.0, Inf)
end
