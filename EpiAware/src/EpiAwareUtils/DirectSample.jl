@doc raw"
Sample directly from a `Turing` model.
"
@kwdef struct DirectSample <: AbstractEpiSamplingMethod
    "Number of samples from a model. If an integer is provided, the model is
     sampled `n_samples` times using `Turing.Prior()` returning an `MCMChains.
     Chain` object. If `nothing`, the model is sampled once returning a
     `NamedTuple` object of the sampled random variables along with generated
     quantities"
    n_samples::Union{Int, Nothing} = nothing
end

@doc raw"
Implements direct sampling from a `Turing` model.
"
function EpiAwareBase.apply_method(
        model::DynamicPPL.Model, method::DirectSample, prev_result = nothing; kwargs...)
        _apply_direct_sample(model, method, method.n_samples)
end

@doc raw "
Sample the model directly using `Turing.Prior()` and a `NamedTuple` of the
sampled random variables along with generated quantities.
"
function _apply_direct_sample(model, method, n_samples::Vector{<:Real})
    solution = sample(model, Turing.Prior(), n_samples)
    return generate_observables(model, solution)
end

@doc raw "
Sample the model directly using rand and return a single set of sampled random variables.
"
function _apply_direct_sample(model, method, n_samples::Nothing)
    solution = rand(model)
    return generate_observables(model, solution)
end
