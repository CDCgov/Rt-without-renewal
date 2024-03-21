function _expand_dist(dist::Vector{D} where {D <: Distribution})
    d = length(dist)
    product_dist = all(first(dist) .== dist) ?
                   filldist(first(dist), d) : arraydist(dist)
    return product_dist
end
