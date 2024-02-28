"""
    $(TYPEDEF)

Abstract type for models that define the latent infection process.
"""
abstract type AbstractEpiModel end

"""
    $(TYPEDEF)

Immutable struct for storing fixed parameters of the latent infection process.

$(TYPEDFIELDS)
"""
struct EpiData{T <: AbstractFloat, F <: Function}
    """
    Discrete time generation interval. First element is probability of infectee on time
        step after infection time step.
    """
    gen_int::Vector{T}
    "length of generation interval vector."
    len_gen_int::Integer
    "Bijector/link/transformation function for unconstrained latent infections."
    transformation::F

    @doc """
        function EpiData(gen_int, transformation::Function)

    Constructor function for an immutable struct for storing fixed parameters of the latent
        infection process.

    # Arguments
    - `gen_int`: Discrete time generation interval. First element is probability of infectee on
        time step after infection time step.
    - `transformation`: Bijector/link/transformation function for unconstrained latent
        infections.

    """
    function EpiData(gen_int,
            transformation::Function)
        @assert all(gen_int .>= 0) "Generation interval must be non-negative"
        @assert sum(gen_int)≈1 "Generation interval must sum to 1"

        new{eltype(gen_int), typeof(transformation)}(gen_int,
            length(gen_int),
            transformation)
    end

    @doc """
        function EpiData(gen_distribution::ContinuousDistribution;
            D_gen,
            Δd = 1.0,
            transformation::Function = exp)

    Constructor function for an immutable struct for storing fixed parameters of the latent
        infection process.

    # Arguments
    - `gen_distribution::ContinuousDistribution`: Continuous generation interval distribution.
        This is converted to a discrete distribution using `create_discrete_pmf`, and then left
        truncated to condition on zero infectees on the same time step as the infector.
    - `D_gen`: Right truncation of the generation interval distribution.
    - `Δd`: Time step size for discretisation of the generation interval distribution.
    - `transformation`: Bijector/link/transformation function for unconstrained latent
        infections.

    """
    function EpiData(gen_distribution::ContinuousDistribution;
            D_gen,
            Δd = 1.0,
            transformation::Function = exp)
        gen_int = create_discrete_pmf(gen_distribution, Δd = Δd, D = D_gen) |>
                  p -> p[2:end] ./ sum(p[2:end])

        return EpiData(gen_int, transformation)
    end
end

"""
    $(TYPEDEF)

A struct representing a direct infections model for latent infections.

# Fields
$(TYPEDFIELDS)
"""
struct DirectInfections{S <: Sampleable} <: AbstractEpiModel
    "Latent infection process data as an `EpiData` object."
    data::EpiData
    "The prior distribution for initial infections"
    initialisation_prior::S
end

"""
    $(TYPEDEF)

A struct representing an exponetial growth rate model for latent infections.

# Fields
$(TYPEDFIELDS)
"""
struct ExpGrowthRate{S <: Sampleable} <: AbstractEpiModel
    "Latent infection process data as an `EpiData` object."
    data::EpiData
    "The prior distribution for initial infections"
    initialisation_prior::S
end

"""
    $(TYPEDEF)

A struct representing a renewal model for latent infections.

# Fields
$(TYPEDFIELDS)
"""
struct Renewal{S <: Sampleable} <: AbstractEpiModel
    data::EpiData
    initialisation_prior::S
end

renewal_eqn::String = raw"""
    ```math
    I_t = R_t \sum_{i=1}^{n-1} I_{t-i} g_i
    ```
    """

function (epimodel::Renewal)(recent_incidence, Rt)
    new_incidence = Rt * dot(recent_incidence, epimodel.data.gen_int)
    return ([new_incidence; recent_incidence[1:(epimodel.data.len_gen_int - 1)]],
        new_incidence)
end

function generate_latent_infs(epimodel::AbstractEpiModel, latent_process)
    @info "No concrete implementation for `generate_latent_infs` is defined."
    return nothing
end

@model function generate_latent_infs(epimodel::DirectInfections, _It)
    init_incidence ~ epimodel.initialisation_prior
    return epimodel.data.transformation.(init_incidence .+ _It)
end

@model function generate_latent_infs(epimodel::ExpGrowthRate, rt)
    init_incidence ~ epimodel.initialisation_prior
    return exp.(init_incidence .+ cumsum(rt))
end

"""
    generate_latent_infs(epimodel::Renewal, _Rt)

`Turing` model constructor for latent infections using the `Renewal` object `epimodel` and time-varying unconstrained reproduction number `_Rt`.

`generate_latent_infs` creates a `Turing` model for sampling latent infections with given unconstrainted
reproduction number `_Rt` but random initial incidence scale. The initial incidence pre-time one is given as
a scale on top of an exponential growing process with exponential growth rate given by `R_to_r`applied to the
first value of `Rt`.

# Arguments
- `epimodel::Renewal`: The epidemiological model.
- `_Rt`: Time-varying unconstrained (e.g. log-) reproduction number.

# Returns
- `I_t`: Array of latent infections over time.

"""
@model function generate_latent_infs(epimodel::Renewal, _Rt)
    init_incidence ~ epimodel.initialisation_prior
    I₀ = epimodel.data.transformation(init_incidence)
    Rt = epimodel.data.transformation.(_Rt)

    r_approx = R_to_r(Rt[1], epimodel)
    init = I₀ * [exp(-r_approx * t) for t in 0:(epimodel.data.len_gen_int - 1)]

    I_t, _ = scan(epimodel, init, Rt)
    return I_t
end
