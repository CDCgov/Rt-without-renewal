"""
The `EpiData` struct represents epidemiological data used in infectious disease modeling.

## Constructors

- `EpiData(gen_int, transformation::Function)`. Constructs an `EpiData` object with discrete
generation interval `gen_int` and transformation function `transformation`.
- `EpiData(;gen_distribution::ContinuousDistribution, D_gen, Δd = 1.0, transformation::Function = exp)`.
Constructs an `EpiData` object with double interval censoring discretisation of the
continuous next generation interval distribution `gen_distribution` with additional right
truncation at `D_gen`. `Δd` sets the interval width (default = 1.0). `transformation` sets
the transformation function

## Examples
Construction direct from discrete generation interval and transformation function:

```julia
using EpiAware
gen_int = [0.2, 0.3, 0.5]
g = exp
data = EpiData(gen_int, g)
```

Construction from continuous distribution for generation interval.

```julia
using Distributions

gen_distribution = Uniform(0.0, 10.0)

data = EpiData(;gen_distribution
    D_gen = 10.0)
```

"""
struct EpiData{T <: Real, F <: Function}
    "Discrete generation interval."
    gen_int::Vector{T}
    "Length of the discrete generation interval."
    len_gen_int::Integer
    "Transformation function defining constrained and unconstrained domain bijections."
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

    function EpiData(; gen_distribution::ContinuousDistribution,
            D_gen,
            Δd = 1.0,
            transformation::Function = exp)
        gen_int = create_discrete_pmf(gen_distribution, Δd = Δd, D = D_gen) |>
                  p -> p[2:end] ./ sum(p[2:end])

        return EpiData(gen_int, transformation)
    end
end
