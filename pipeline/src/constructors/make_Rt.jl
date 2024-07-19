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
Constructs an Rt object based on the given `pipeline`.

# Arguments
- `pipeline`: An instance of `EpiAwareExamplePipeline`.

# Returns
- An Rt object.

"""
function make_Rt(pipeline::EpiAwareExamplePipeline)
    return make_Rt(pipeline.pipetype())
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

"""
Constructs the time-varying reproduction number (Rt) for a given outbreak with measures scenario.

# Arguments
- `pipeline::MeasuresOutbreakPipeline`: The outbreak pipeline object.
- `N::Float64`: The total number of time steps.
- `initial_Rt::Float64`: The initial reproduction number before any measures are implemented.
- `measures_Rt::Float64`: The reproduction number during the period when measures are implemented.
- `post_measures_Rt::Float64`: The reproduction number after the measures are lifted.
- `reduction::Float64`: The eventual reduction factor applied to the reproduction number after measures are lifted over time.
- `r::Float64`: The rate of decay towards the reduction factor.
- `shift::Float64`: The time shift applied to the decay function after end of measures.
- `t₁::Float64`: The time step at which measures are implemented.
- `t₂::Float64`: The time step at which measures are lifted.

# Returns
- `Rt::Vector{Float64}`: The time-varying reproduction number.

# Example

```julia
using EpiAwarePipeline, Plots
pipeline = MeasuresOutbreakPipeline()
Rt = make_Rt(pipeline) |> Rt -> plot(Rt,
    xlabel = "Time",
    ylabel = "Rt",
    lab = "",
    title = "Outbreak scenario with measures")
```
"""
function make_Rt(
        pipeline::MeasuresOutbreakPipeline; N = 70.0, initial_Rt = 1.5, measures_Rt = 0.8,
        post_measures_Rt = 1.2, reduction = 0.6, r = 1 / 3.5, shift = 21.0, t₁ = 21.0, t₂ = 42.0)
    Rt = vcat(map(t -> initial_Rt, 1.0:t₁),
        map(t -> measures_Rt, (t₁ + 1.0):t₂),
        map((t₂ + 1):N) do t
            post_measures_Rt * (1 - reduction * logistic(r * (t - t₂ - shift)))
        end)

    return Rt
end

"""
Constructs the time-varying reproduction number (Rt) for a smoothly varying endemic scenario.

In this context "endemic" means a scenario where the geometric average of the
reproduction number is 1.0, that is the following holds:

```math
(\\prod_{t = 1}^n[R_t])^{1/n} = 1.
```

This implies that the long-term muliplicative growth of the infected community is 1.0.

# Arguments
- `pipeline::SmoothEndemicPipeline`: The pipeline for which Rt is constructed.
- `N::Float64 = 70.0`: The number of time points to generate Rt for.
- `A::Float64 = 0.1`: The amplitude of the sinusoidal variation in Rt.
- `P::Float64 = 28.0`: The period of the sinusoidal variation in Rt.

# Returns
- `Rt::Vector{Float64}`: The time-varying reproduction number.

# Examples

```julia
using EpiAwarePipeline, Plots
pipeline = SmoothEndemicPipeline()
Rt = make_Rt(pipeline) |> Rt -> plot(Rt,
    xlabel = "Time",
    ylabel = "Rt",
    lab = "",
    title = "Smoothly varying endemic scenario")
```
"""
function make_Rt(
        pipeline::SmoothEndemicPipeline; N = 70.0, A = 0.1, P = 28.0)
    log_Rt = map(1.0:N) do t
        A * sinpi(2 * t / P)
    end
    Rt = exp.(log_Rt .- mean(log_Rt)) # Normalize to have geometric mean 1.0
    return Rt
end

"""
Constructs the time-varying reproduction number (Rt) for an randomly varying endemic scenario.

In this context "endemic" means a scenario where the geometric average of the
reproduction number is 1.0, that is the following holds:

```math
(\\prod_{t = 1}^n[R_t])^{1/n} = 1.
```

This implies that the long-term muliplicative growth of the infected community is 1.0.

# Arguments
- `pipeline::RoughEndemicPipeline`: The `RoughEndemicPipeline` object for which Rt is being constructed.
- `N_steps::Int = 10`: The number of steps to generate random values for Rt.
- `rng::AbstractRNG = MarsenneTwister(1234)`: The random number generator to use.
- `stride::Int = 7`: The stride length for repeating each random value.
- `σ::Float64 = 0.05`: The standard deviation of the random values.

# Returns
- `Rt::Vector{Float64}`: The time-varying reproduction number Rt.

# Example

```julia
using EpiAwarePipeline, Plots
pipeline = RoughEndemicPipeline()
Rt = make_Rt(pipeline) |> Rt -> plot(Rt,
    xlabel = "Time",
    ylabel = "Rt",
    lab = "",
    title = "Rough Rt path endemic scenario")
```
"""
function make_Rt(
        pipeline::RoughEndemicPipeline; N_steps = 10, rng = MersenneTwister(1234), stride = 7, σ = 0.05)
    X = σ * randn(rng, N_steps)
    log_Rt = mapreduce(vcat, X) do x
        fill(x, stride)
    end
    Rt = exp.(log_Rt .- mean(log_Rt)) # Normalize to have geometric mean 1.0

    return Rt
end
