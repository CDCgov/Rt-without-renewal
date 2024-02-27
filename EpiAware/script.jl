
struct XYCoords{T}
    x::T
    y::T
end

function dist_from_origin(xy_coords::XYCoords)
    @info "Weird choice of type here!"
    return nothing
end

function dist_from_origin(xy_coords::XYCoords{T}) where {T <: AbstractFloat}
    return sqrt(xy_coords.x^2 + xy_coords.y^2)
end

function dist_from_origin(xy_coords::XYCoords{T}) where {T <: Integer}
    return abs(xy_coords.x) + abs(xy_coords.y)
end

coord_string = XYCoords("A", "B")
coord_double = XYCoords(1.5, 1.5)
coord_float = XYCoords(1.5f0, 1.5f0)
coord_int = XYCoords(2, 1)
coord_wrong = XYCoords(2.5, 1)

dist_from_origin(coord_string)
dist_from_origin(coord_double)
dist_from_origin(coord_float)
dist_from_origin(coord_int)
