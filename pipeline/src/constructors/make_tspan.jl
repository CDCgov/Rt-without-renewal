"""
Constructs the time span for the given `pipeline` object.

# Arguments
- `pipeline::AbstractEpiAwarePipeline`: The pipeline object for which the time
    span is constructed. This is the default method.

# Returns
- `tspan::Tuple{Float64, Float64}`: The time span as a tuple of start and end times.

"""
function make_tspan(pipeline::AbstractEpiAwarePipeline)
    default_tspan()
end
