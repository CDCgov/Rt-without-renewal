"""
Compute the default Rt values over time for generating truth data. This is the
default method.

## keyword Arguments
- `A`: Amplitude of the sinusoidal variation in Rt. Default is 0.3.
- `P`: Period of the sinusoidal variation in Rt. Default is 30 time steps.

## Returns
- `true_Rt`: Array of default Rt values over time.

"""
function make_Rt(pipeline::AbstractEpiAwarePipeline; A = 0.3, P = 30.0)
    ϕ = asin(-0.1 / 0.3) * P / (2 * π)
    N = 160
    true_Rt = vcat(fill(1.1, 2 * 7), fill(2.0, 2 * 7), fill(0.5, 2 * 7),
        fill(1.5, 2 * 7), fill(0.75, 2 * 7), fill(1.1, 6 * 7)) |>
              Rt -> [Rt;
                     [1.0 + A * sin.(2 * π * (t - ϕ) / P) for t in 1:(N - length(Rt))]]
    return true_Rt
end

"""
Constructs the time-varying reproduction number (Rt) for a given SmoothOutbreakPipeline.

# Arguments
- `pipeline::SmoothOutbreakPipeline`: The SmoothOutbreakPipeline object for which to construct Rt.
- `N::Float64 = 70.0`: The number of time steps to consider.
- `initial_Rt::Float64 = 1.5`: The initial value of Rt.
- `reduction::Float64 = 0.5`: The reduction factor applied to Rt over time.
- `r::Float64 = 1 / 3.5`: The rate of change of Rt over time.
- `shift::Float64 = 35.0`: The time shift applied to Rt.

# Returns
- `Rt::Vector{Float64}`: The time-varying reproduction number (Rt) as a vector.

# Example

```julia
using EpiAwarePipeline, Plots
pipeline = SmoothOutbreakPipeline()
Rt = make_Rt(pipeline) |> Rt -> plot(Rt,
    xlabel = "Time",
    ylabel = "Rt",
    lab = "",
    title = "Smooth outbreak scenario")
```
"""
function make_Rt(pipeline::SmoothOutbreakPipeline; N = 70.0, initial_Rt = 1.5,
        reduction = 0.5, r = 1 / 3.5, shift = 35.0)
    Rt = map(1.0:N) do t
        initial_Rt * (1 - reduction * logistic(r * (t - shift)))
    end
    return Rt
end
