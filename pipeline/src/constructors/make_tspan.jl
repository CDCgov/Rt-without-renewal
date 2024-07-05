"""
Constructs a time span for performing inference on a case data time series. This
    is the default method.

# Arguments
- `pipeline::AbstractEpiAwarePipeline`: The pipeline object used for analysis.
- `T::Union{Integer,Nothing} = nothing`: The `stop` point at which to construct
    the time span. If `nothing`, the time span will be constructed using the
    length of the Rt vector for `pipeline`.
- `lookback = 35`: The number of days to look back from the specified time point.

# Returns
A tuple `(start, stop)` representing the start and stop indices of the time span.

# Examples

"""
function make_tspan(pipeline::AbstractEpiAwarePipeline;
        T::Union{Integer, Nothing} = nothing, lookback = 35)
    N = size(make_Rt(pipeline), 1)
    _T = isnothing(T) ? N : T
    @assert backhorizon<N "Backhorizon must be less than the length of the default Rt."
    return (max(1, _T - lookback), min(N, _T))
end
