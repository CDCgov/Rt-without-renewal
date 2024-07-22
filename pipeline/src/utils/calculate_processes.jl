"""
Internal function for calculating the log of the infections with an informative
    error message if the infections are not positive definite.
"""
function _calc_log_infections(I_t; jitter = 1e-6)
    log.(I_t .+ jitter)
end

"""
Internal function for calculating the exponential growth rate with an informative
    error message if the infections are not positive definite.
"""
function _calc_rt(I_t, I0; jitter = 1e-6)
    @assert I0 + jitter>0 "Initial infections must be positive definite."
    log.([I0 + jitter; I_t .+ jitter]) .- log(I0 + jitter) |> diff
end

"""
Internal function for seeding the infections. Method dispatches on the pipeline
type to determine the seeding method. This is the default seeding method which
assumes backward exponential growth with initial infections `I0` from initial
estimate of `rt`.

"""
function _infection_seeding(
        I_t, I0, data::EpiData, pipeline::AbstractEpiAwarePipeline; jitter = 1e-6)
    n = length(data.gen_int)
    init_rt = _calc_rt(I_t[1:2] .+ jitter, I0 + jitter) |> x -> x[1]
    [(I0 + jitter) * exp(-init_rt * (n - i)) for i in 1:n]
end

"""
Internal function for calculating the _instantaneous_ reproduction number `Rt`
using the method of [Fraser (2007)](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0000758).
Left truncation handling method is determined by the pipeline type. The default
left truncation in `I_t` is handled by extending the series with backwards exponential
growth from the initial infections `I0` and the exponential growth rate `init_rt`.

# Arguments
- `I_t`: Incident infections.
- `I0`: Initial infections at time zero.
- `init_rt`: Initial exponential growth rate.
- `data::EpiData`: An instance of the `EpiData` type containing generation interval data.
- `pipeline::AbstractEpiAwarePipeline`: An instance of the `AbstractEpiAwarePipeline` type.
"""
function _calc_Rt(I_t, I0, data::EpiData, pipeline::AbstractEpiAwarePipeline; jitter = 1e-6)
    @assert I0 + jitter>0 "Initial infections must be positive definite."

    aug_I_t = vcat(_infection_seeding(I_t .+ jitter, I0 + jitter, data, pipeline), I_t)

    Rt = expected_Rt(data, aug_I_t)

    return Rt
end

"""
Calculate the log of infections `log_I_t`, exponential growth values `rt`, and
instaneous reproductive number `Rt` for a given time series of infections. The
reproductive number calculation deals with left truncation in `I_t` by extending
`I_t` with backwards exponential growth using the mean exponential growth rate
from the first 7 time steps of `rt`.

# Arguments
- `I_t`: An array representing the time series of infections.
- `I0`: The initial number of infections.
- `pmf`: The probability mass function used to calculate Rt.

# Returns
A named tuple containing the calculated values for `log_I_t`, `rt`, and `Rt`.

"""
function calculate_processes(I_t, I0, data::EpiData, pipeline::AbstractEpiAwarePipeline)
    log_I_t = _calc_log_infections(I_t)
    rt = _calc_rt(I_t, I0)
    Rt = _calc_Rt(I_t, I0, data, pipeline)
    return (; log_I_t, rt, Rt)
end
