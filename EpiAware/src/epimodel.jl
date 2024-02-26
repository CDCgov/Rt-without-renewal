abstract type AbstractEpiModel end

struct EpiData{T <: Real, F <: Function}
    gen_int::Vector{T}
    len_gen_int::Integer
    transformation::F

    #Inner constructors for EpiData object
    function EpiData(
            gen_int,
            transformation::Function
    )
        @assert all(gen_int .>= 0) "Generation interval must be non-negative"
        @assert sum(gen_int)≈1 "Generation interval must sum to 1"

        new{eltype(gen_int), typeof(transformation)}(
            gen_int,
            length(gen_int),
            transformation
        )
    end

    function EpiData(
            gen_distribution::ContinuousDistribution;
            D_gen,
            Δd = 1.0,
            transformation::Function = exp
    )
        gen_int = create_discrete_pmf(gen_distribution, Δd = Δd, D = D_gen) |>
                  p -> p[2:end] ./ sum(p[2:end])

        return EpiData(gen_int, transformation)
    end
end

struct DirectInfections <: AbstractEpiModel
    data::EpiData
end

struct ExpGrowthRate <: AbstractEpiModel
    data::EpiData
end

struct Renewal <: AbstractEpiModel
    data::EpiData
end

function generate_latent_infs(epimodel::AbstractEpiModel, latent_process, init_incidence)
    @info "No concrete implementation for generate_latent_infs is defined."
    return nothing
end

function generate_latent_infs(epimodel::DirectInfections, _It, init_incidence)
    epimodel.data.transformation.(init_incidence .+ _It)
end

function generate_latent_infs(epimodel::ExpGrowthRate, rt, init_incidence)
    init_incidence .+ cumsum(rt) .|> exp
end

function generate_latent_infs(epimodel::Renewal, _Rt, init_incidence)
    I₀ = epimodel.data.transformation(init_incidence)
    Rt = epimodel.data.transformation.(_Rt)

    r_approx = R_to_r(Rt[1], epimodel)
    init = I₀ * [exp(-r_approx * t) for t in 0:(epimodel.data.len_gen_int - 1)]

    function generate_infs(recent_incidence, Rt)
        new_incidence = Rt * dot(recent_incidence, epimodel.data.gen_int)
        [new_incidence; recent_incidence[1:(epimodel.data.len_gen_int - 1)]], new_incidence
    end

    I_t, _ = scan(generate_infs, init, Rt)
    return I_t
end
