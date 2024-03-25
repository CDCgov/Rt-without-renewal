"""
Sample directly from a `Turing` model.
"""
@kwdef struct DirectSample <: AbstractEpiSamplingMethod
    "Number of samples from a model. If an integer is provided, the model is sampled
    `n_samples` times using `Turing.Prior()` returning an `MCMChains.Chain` object. If
    `nothing`, the model is sampled once returning a `NamedTuple` object of the sampled
    random variables."
    n_samples::Union{Int, Nothing} = nothing
end

"""
Implements direct sampling from a `Turing` model.
"""
function _apply_method(
        method::DirectSample, mdl::DynamicPPL.Model, prev_result = nothing; kwargs...)
    if method.n_samples === nothing
        return rand(mdl)
    else
        chn = sample(mdl, Turing.Prior(), method.n_samples)
        return chn
    end
end
