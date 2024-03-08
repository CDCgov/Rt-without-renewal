struct EpiData{T <: Real, F <: Function}
    gen_int::Vector{T}
    len_gen_int::Integer
    transformation::F

    #Inner constructors for EpiData object
    function EpiData(gen_int,
            transformation::Function)
        @assert all(gen_int .>= 0) "Generation interval must be non-negative"
        @assert sum(gen_int)≈1 "Generation interval must sum to 1"

        new{eltype(gen_int), typeof(transformation)}(gen_int,
            length(gen_int),
            transformation)
    end

    function EpiData(gen_distribution::ContinuousDistribution;
            D_gen,
            Δd = 1.0,
            transformation::Function = exp)
        gen_int = create_discrete_pmf(gen_distribution, Δd = Δd, D = D_gen) |>
                  p -> p[2:end] ./ sum(p[2:end])

        return EpiData(gen_int, transformation)
    end
end
