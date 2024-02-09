abstract type AbstractEpiModel end


"""
    struct EpiModel{T}

The `EpiModel` struct represents a basic renewal model.

# Fields
- `gen_int::Vector{T}`: Discrete generation distribution.
- `delay_int::Vector{T}`: Discrete delay distribution.
- `delay_kernel::SparseMatrixCSC{T,Integer}`: Sparse matrix representing the action of convoluting
    a series of infections with observation delay.
- `cluster_coeff::T`: Cluster coefficient for negative binomial distribution of observations.
- `len_gen_int::Integer`: Length of `gen_int` vector.
- `len_delay_int::Integer`: Length of `delay_int` vector.

# Constructors
- `EpiModel(gen_int, delay_int, truth_cluster_coeff, time_horizon)`: Constructs an `EpiModel` object.

The `EpiModel` struct represents an epidemiological model with generation intervals, delay intervals, delay kernel, truth cluster coefficient, and length of generation and delay intervals.

"""
struct EpiModel{T<:Real} <: AbstractEpiModel
    gen_int::Vector{T}
    delay_int::Vector{T}
    delay_kernel::SparseMatrixCSC{T,Integer}
    cluster_coeff::T
    len_gen_int::Integer #length(gen_int) just to save recalc
    len_delay_int::Integer #length(delay_int) just to save recalc

    #Inner constructor for EpiModel object
    function EpiModel(gen_int, delay_int, cluster_coeff, time_horizon)
        @assert all(gen_int .>= 0) "Generation interval must be non-negative"
        @assert all(delay_int .>= 0) "Delay interval must be non-negative"
        @assert sum(gen_int) ≈ 1 "Generation interval must sum to 1"
        @assert sum(delay_int) ≈ 1 "Delay interval must sum to 1"
        #construct observation delay kernel
        K = zeros(time_horizon, time_horizon) |> SparseMatrixCSC
        for i = 1:time_horizon, j = 1:time_horizon
            m = (i - 1) - (j - 1)
            if m >= 1 && m <= length(delay_int)
                K[i, j] = delay_int[m]
            end
        end

        new{eltype(gen_int)}(
            gen_int,
            delay_int,
            K,
            cluster_coeff,
            length(gen_int),
            length(delay_int),
        )
    end
end

"""
    (epi_model::EpiModel)(recent_incidence, Rt)

Apply the EpiModel to calculate new incidence based on recent incidence and Rt.

# Arguments
- `recent_incidence`: Array of recent incidence values.
- `Rt`: Reproduction number.

# Returns
- `new_incidence`: Array of new incidence values.
"""
function (epi_model::EpiModel)(recent_incidence, Rt)
    new_incidence = Rt * dot(recent_incidence, epi_model.gen_int)
    [new_incidence; recent_incidence[1:(epi_model.len_gen_int-1)]], new_incidence
end
