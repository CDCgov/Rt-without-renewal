"""
Compute the default time span for the Rt calculation.

# Arguments
- `backhorizon::Int`: The number of days to look back for the time span calculation. Default is 21.

# Returns
- A tuple `(start, stop)` representing the default time span for the Rt calculation.

"""
function default_tspan(; backhorizon = 21)
    N = length(default_Rt())
    @assert backhorizon<N "Backhorizon must be less than the length of the default Rt."
    return (1, N - backhorizon)
end
