"""
Internal function for calculating the log of the infections with an informative
    error message if the infections are not positive definite.
"""
function _calc_log_infections(I_t)
    @assert all(I_t .> 0) "Infections must be positive definite."
    log.(I_t)
end

"""
Internal function for calculating the exponential growth rate with an informative
    error message if the infections are not positive definite.
"""
function _calc_rt(I_t, I0)
    @assert all(I_t .> 0) "Infections must be positive definite."
    @assert I0>0 "Initial infections must be positive definite."
    log.([I0; I_t]) .- log(I0) |> diff
end

"""
Internal function for calculating the _instantaneous_ reproduction number `Rt`
using the method of [Fraser (2007)](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0000758).
Left truncation in `I_t` is handled by extending the series with backwards exponential
growth from the initial infections `I0` and the exponential growth rate `init_rt`.

# Arguments
- `I_t`: Incident infections.
- `I0`: Initial infections at time zero.
- `init_rt`: Initial exponential growth rate.
- `data::EpiData`: An instance of the `EpiData` type containing generation interval data.
"""
function _calc_Rt(I_t, I0, init_rt, data::EpiData)
    @assert all(I_t .> 0) "Log infections must be positive definite."
    @assert I0>0 "Initial infections must be positive definite."
    n = length(data.gen_int)
    rev_pmf = reverse(data.gen_int)
    aug_I_t = [I0 * exp(-init_rt * (n - i)) for i in 1:n] |>
              v -> vcat(v, I_t)

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
function calculate_processes(I_t, I0, pmf)
    log_I_t = _calc_log_infections(I_t)
    rt = _calc_rt(I_t, I0)
    init_rt = rt[1]
    Rt = _calc_Rt(I_t, I0, init_rt, pmf)
    return (; log_I_t, rt, Rt)
end
