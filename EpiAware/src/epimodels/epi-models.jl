
struct DirectInfections{S <: Sampleable} <: AbstractEpiModel
    data::EpiData
    initialisation_prior::S
end

struct ExpGrowthRate{S <: Sampleable} <: AbstractEpiModel
    data::EpiData
    initialisation_prior::S
end

struct Renewal{S <: Sampleable} <: AbstractEpiModel
    data::EpiData
    initialisation_prior::S
end

"""
    function (epi_model::Renewal)(recent_incidence, Rt)

Compute new incidence based on recent incidence and Rt.

This is a callable function on `Renewal` structs, that encodes new incidence prediction
given recent incidence and Rt according to basic renewal process.

```math
I_t = R_t \\sum_{i=1}^{n-1} I_{t-i} g_i
```

where `I_t` is the new incidence, `R_t` is the reproduction number, `I_{t-i}` is the recent incidence
and `g_i` is the generation interval.


# Arguments
- `recent_incidence`: Array of recent incidence values.
- `Rt`: Reproduction number.

# Returns
- Tuple containing the updated incidence array and the new incidence value.

"""
function (epi_model::Renewal)(recent_incidence, Rt)
    new_incidence = Rt * dot(recent_incidence, epi_model.data.gen_int)
    return ([new_incidence; recent_incidence[1:(epi_model.data.len_gen_int - 1)]],
        new_incidence)
end

function generate_latent_infs(epi_model::AbstractEpiModel, latent_model)
    @info "No concrete implementation for `generate_latent_infs` is defined."
    return nothing
end

@model function generate_latent_infs(epi_model::DirectInfections, _It)
    init_incidence ~ epi_model.initialisation_prior
    return epi_model.data.transformation.(init_incidence .+ _It)
end

@model function generate_latent_infs(epi_model::ExpGrowthRate, rt)
    init_incidence ~ epi_model.initialisation_prior
    return exp.(init_incidence .+ cumsum(rt))
end

"""
    generate_latent_infs(epi_model::Renewal, _Rt)

`Turing` model constructor for latent infections using the `Renewal` object `epi_model` and time-varying unconstrained reproduction number `_Rt`.

`generate_latent_infs` creates a `Turing` model for sampling latent infections with given unconstrainted
reproduction number `_Rt` but random initial incidence scale. The initial incidence pre-time one is given as
a scale on top of an exponential growing process with exponential growth rate given by `R_to_r`applied to the
first value of `Rt`.

# Arguments
- `epi_model::Renewal`: The epidemiological model.
- `_Rt`: Time-varying unconstrained (e.g. log-) reproduction number.

# Returns
- `I_t`: Array of latent infections over time.

"""
@model function generate_latent_infs(epi_model::Renewal, _Rt)
    init_incidence ~ epi_model.initialisation_prior
    I₀ = epi_model.data.transformation(init_incidence)
    Rt = epi_model.data.transformation.(_Rt)

    r_approx = R_to_r(Rt[1], epi_model)
    init = I₀ * [exp(-r_approx * t) for t in 0:(epi_model.data.len_gen_int - 1)]

    I_t, _ = scan(epi_model, init, Rt)
    return I_t
end
