abstract type AbstractInitialisation end

struct SimpleInitialisation{D <: Sampleable, S <: Sampleable} <: AbstractInitialisation
    mean_I0_prior::D
    var_I0_prior::S
end

function default_initialisation_prior()
    (:mean_prior => Normal(), :var_prior => truncated(Normal(0.0, 0.05), 0.0, Inf)) |> Dict
end

function generate_initialisation(initialisation_model::AbstractInitialisation)
    @info "No concrete implementation for generate_initialisation is defined."
    return nothing
end

@model function generate_initialisation(initialisation_model::SimpleInitialisation)
    _I0 ~ Normal()
    μ_I0 ~ initialisation_model.mean_I0_prior
    σ²_I0 ~ initialisation_model.var_I0_prior
    return μ_I0 + _I0 * sqrt(σ²_I0), (; μ_I0, σ²_I0)
end
