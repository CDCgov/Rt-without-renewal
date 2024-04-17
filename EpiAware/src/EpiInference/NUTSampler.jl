@doc raw"
A NUTS method for sampling from a `DynamicPPL.Model` object.

The `NUTSampler` struct represents using the No-U-Turn Sampler (NUTS) to sample from the distribution defined by a `DynamicPPL.Model`.
"
@kwdef struct NUTSampler{
    A <: ADTypes.AbstractADType, E <: AbstractMCMC.AbstractMCMCEnsemble, M} <:
              AbstractEpiSamplingMethod
    "The target acceptance rate for the sampler."
    target_acceptance::Float64 = 0.8
    "The automatic differentiation type used for computing gradients."
    adtype::A = AutoForwardDiff()
    "The parallelization strategy for the MCMC sampler."
    mcmc_parallel::E = MCMCSerial()
    "The number of MCMC chains to run."
    nchains::Int = 1
    "Tree depth limit for the NUTS sampler."
    max_depth::Int = 10
    "Divergence threshold for the NUTS sampler."
    Δ_max::Float64 = 1000.0
    "The initial step size for the NUTS sampler."
    init_ϵ::Float64 = 0.0
    "The number of samples to draw from each chain."
    ndraws::Int
    "The metric type to use for the HMC sampler."
    metricT::M = DiagEuclideanMetric
end

@doc raw"
Apply NUTS sampling to a `DynamicPPL.Model` object with `prev_result` representing any
initial results to use for sampler initialisation.
"
function EpiAwareBase._apply_method(
        model::DynamicPPL.Model, method::NUTSampler, prev_result = nothing; kwargs...)
    _apply_nuts(model, method, prev_result; kwargs...)
end

@doc raw"
No initialisation NUTS.
"
function _apply_nuts(model, method, prev_result; kwargs...)
    sample(model,
        Turing.NUTS(
            method.target_acceptance;
            adtype = method.adtype,
            max_depth = method.max_depth,
            Δ_max = method.Δ_max,
            init_ϵ = method.init_ϵ,
            metricT = method.metricT
        ),
        method.mcmc_parallel,
        method.ndraws ÷ method.nchains,
        method.nchains;
        kwargs...)
end

"""
Initialise NUTS with initial parameters from a Pathfinder result.
"""
function _apply_nuts(model, method, prev_result::PathfinderResult; kwargs...)
    init_params = collect.(eachrow(prev_result.draws_transformed.value[
        1:(method.nchains), :, 1]))

    sample(model,
        Turing.NUTS(method.target_acceptance;
            adtype = method.adtype,
            metricT = method.metricT),
        method.mcmc_parallel,
        method.ndraws ÷ method.nchains,
        method.nchains;
        init_params = init_params,
        kwargs...)
end
