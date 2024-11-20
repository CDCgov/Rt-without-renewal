"""
Internal function to expand a vector of distributions into a product distribution.

## Implementation note
If all distributions in the input vector `dist` are the same, it returns a filled distribution using `filldist`.
Otherwise, it returns an array distribution using `arraydist`.
"""
function _expand_dist(dist::Vector{D} where {D <: Distribution})
    d = length(dist)
    product_dist = all(first(dist) .== dist) ?
                   filldist(first(dist), d) : arraydist(dist)
    return product_dist
end
