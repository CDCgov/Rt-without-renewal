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
@kwdef struct SmoothOutbreakPipeline <: AbstractRtwithoutRenewalPipeline
    ndraws::Integer = 2000
    mcmc_ensemble::AbstractMCMC.AbstractMCMCEnsemble = MCMCSerial()
    nruns_pthf::Integer = 4
    maxiters_pthf::Integer = 100
    nchains::Integer = 4
end

"""
The pipeline type for the Rt pipeline for an outbreak scenario where Rt has
    discontinuous changes over time due to implementation of measures.
"""
@kwdef struct MeasuresOutbreakPipeline <: AbstractRtwithoutRenewalPipeline
    ndraws::Integer = 2000
    mcmc_ensemble::AbstractMCMC.AbstractMCMCEnsemble = MCMCSerial()
    nruns_pthf::Integer = 4
    maxiters_pthf::Integer = 100
    nchains::Integer = 4
end

"""
The pipeline type for the Rt pipeline for an endemic scenario where Rt changes in
    a smooth sinusoidal manner over time.
"""
@kwdef struct SmoothEndemicPipeline <: AbstractRtwithoutRenewalPipeline
    ndraws::Integer = 2000
    mcmc_ensemble::AbstractMCMC.AbstractMCMCEnsemble = MCMCSerial()
    nruns_pthf::Integer = 4
    maxiters_pthf::Integer = 100
    nchains::Integer = 4
end

"""
The pipeline type for the Rt pipeline for an endemic scenario where Rt changes in
    a weekly-varying discontinuous manner over time.
"""
@kwdef struct RoughEndemicPipeline <: AbstractRtwithoutRenewalPipeline
    ndraws::Integer = 2000
    mcmc_ensemble::AbstractMCMC.AbstractMCMCEnsemble = MCMCSerial()
    nruns_pthf::Integer = 4
    maxiters_pthf::Integer = 100
    nchains::Integer = 4
end
