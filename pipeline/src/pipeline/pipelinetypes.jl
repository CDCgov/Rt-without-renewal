"""
The abstract root type for all pipeline types using `EpiAware`.
"""
abstract type AbstractEpiAwarePipeline end

"""
An abstract type for different scenarios in the Rt without Renewal pipeline.
"""
abstract type AbstractRtwithoutRenewalPipeline <: AbstractEpiAwarePipeline end

"""
The pipeline type for the Rt pipeline without renewal with only prior predictive
    modelling.
"""
struct RtwithoutRenewalPriorPipeline <: AbstractEpiAwarePipeline
end

"""
The pipeline type for the Rt pipeline without renewal in test mode.
"""
struct EpiAwareExamplePipeline <: AbstractEpiAwarePipeline
end

"""
The pipeline type for the Rt pipeline for an outbreak scenario where Rt decreases
    smoothly over time to Rt < 1.

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
struct SmoothOutbreakPipeline <: AbstractRtwithoutRenewalPipeline
end

"""
The pipeline type for the Rt pipeline for an outbreak scenario where Rt has
    discontinuous changes over time due to implementation of measures.
"""
struct MeasuresOutbreakPipeline <: AbstractRtwithoutRenewalPipeline
end

"""
The pipeline type for the Rt pipeline for an endemic scenario where Rt changes in
    a smooth sinusoidal manner over time.
"""
struct SmoothEndemicPipeline <: AbstractRtwithoutRenewalPipeline
end

"""
The pipeline type for the Rt pipeline for an endemic scenario where Rt changes in
    a weekly-varying discontinuous manner over time.
"""
struct RoughEndemicPipeline <: AbstractRtwithoutRenewalPipeline
end
