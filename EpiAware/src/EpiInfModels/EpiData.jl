@doc raw"
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
"
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
        gen_int = censored_pmf(gen_distribution, Δd = Δd, D = D_gen) |>
                  p -> p[2:end] ./ sum(p[2:end])

        return EpiData(gen_int, transformation)
    end
end

@doc raw"
Calculate the expected Rt values based on the given `EpiData` object and infections.

```math
R_t = \frac{I_t}{\sum_{i=1}^{n} I_{t-i} g_i}
```

# Arguments
- `data::EpiData`: An instance of the EpiData type containing generation interval data.
- `infections::Vector{<:Real}`: A vector of infection data.

# Returns
- `exp_Rt::Vector{Float64}`: A vector of expected Rt values.

## Examples

```julia
using EpiAware

data = EpiData([0.2, 0.3, 0.5], exp)
infections = [100, 200, 300, 400, 500]
expected_Rt(data, infections)
```
"
function expected_Rt(data::EpiData, infections::Vector{<:Real})
    n = data.len_gen_int
    @assert n=length(infections) "Infections vector must be longer than the generation time maximum"

    denom_Rt = [dot(reverse(data.gen_int),
                    infections[(t - n):(t - 1)]
                ) for t in (n + 1):length(infections)]
    exp_Rt = infections[(n + 1):end] ./ denom_Rt
    return exp_Rt
end
