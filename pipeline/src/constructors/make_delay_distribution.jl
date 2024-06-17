"""
Constructs and returns a delay distribution for the given `pipeline`. This is the default method
returning a `Gamma` distribution with shape parameter `α = 4.` and rate parameter `θ = 5. / 4.`.

# Arguments
- `pipeline::AbstractEpiAwarePipeline`: The pipeline for which the delay distribution is constructed.

# Returns
- `delay_distribution::Distribution`: The constructed delay distribution.

"""
function make_delay_distribution(pipeline::AbstractEpiAwarePipeline)
    default_params = make_default_params(pipeline)
    Gamma(default_params["α_delay"], default_params["θ_delay"])
end
