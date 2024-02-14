abstract type AbstractEpiModel end

struct EpiData{T<:Real,F<:Function}
    gen_int::Vector{T}
    delay_int::Vector{T}
    delay_kernel::SparseMatrixCSC{T,Integer}
    cluster_coeff::T
    len_gen_int::Integer
    len_delay_int::Integer
    time_horizon::Integer
    transformation::F

    #Inner constructors for EpiData object
    function EpiData(
        gen_int,
        delay_int,
        cluster_coeff,
        time_horizon::Integer,
        transformation::Function,
    )
        @assert all(gen_int .>= 0) "Generation interval must be non-negative"
        @assert all(delay_int .>= 0) "Delay interval must be non-negative"
        @assert sum(gen_int) ≈ 1 "Generation interval must sum to 1"
        @assert sum(delay_int) ≈ 1 "Delay interval must sum to 1"

        K = generate_observation_kernel(delay_int, time_horizon)

        new{eltype(gen_int),typeof(transformation)}(
            gen_int,
            delay_int,
            K,
            cluster_coeff,
            length(gen_int),
            length(delay_int),
            time_horizon,
            transformation,
        )
    end

    function EpiData(
        gen_distribution::ContinuousDistribution,
        delay_distribution::ContinuousDistribution,
        cluster_coeff,
        time_horizon::Integer;
        D_gen,
        D_delay,
        Δd = 1.0,
        transformation::Function = exp,
    )
        gen_int =
            create_discrete_pmf(gen_distribution, Δd = Δd, D = D_gen) |>
            p -> p[2:end] ./ sum(p[2:end])
        delay_int = create_discrete_pmf(delay_distribution, Δd = Δd, D = D_delay)

        return EpiData(gen_int, delay_int, cluster_coeff, time_horizon, transformation)
    end
end

struct DirectInfections <: AbstractEpiModel
    data::EpiData
end

function (epi_model::DirectInfections)(recent_incidence, unc_I_t)
    nothing, epi_model.data.transformation(unc_I_t)
end

struct ExpGrowthRate <: AbstractEpiModel
    data::EpiData
end

function (epi_model::ExpGrowthRate)(unc_recent_incidence, rt)
    new_unc_recent_incidence = unc_recent_incidence + rt
    new_unc_recent_incidence, epi_model.data.transformation(new_unc_recent_incidence)
end

struct Renewal <: AbstractEpiModel
    data::EpiData
end

function (epi_model::Renewal)(recent_incidence, Rt)
    new_incidence = Rt * dot(recent_incidence, epi_model.data.gen_int)
    [new_incidence; recent_incidence[1:(epi_model.data.len_gen_int-1)]], new_incidence
end
