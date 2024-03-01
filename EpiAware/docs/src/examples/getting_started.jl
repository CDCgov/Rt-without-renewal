### A Pluto.jl notebook ###
# v0.19.40

using Markdown
using InteractiveUtils

# ╔═╡ c593a2a0-d7f5-11ee-0931-d9f65ae84a72
# hideall
let
    docs_dir = dirname(dirname(@__DIR__))
    pkg_dir = dirname(docs_dir)

    using Pkg: Pkg
    Pkg.activate(docs_dir)
    Pkg.develop(; path = pkg_dir)
    Pkg.instantiate()
end;

# ╔═╡ 3ebc8384-f73d-4597-83a7-07a3744fed61
md"
# Getting stated with `EpiAware`

This is a toy model for demonstrating current functionality of EpiAware package.

## Generative Model without data

### Latent Process

The latent process is a random walk defined by a Turing model `random_walk` of specified length `n`.

_Unfixed parameters_:
- `σ²_RW`: The variance of the random walk process. Current defauly prior is
- `init_rw_value`: The initial value of the random walk process.
- `ϵ_t`: The random noise vector.

```math
\begin{align}
X(t) &= X(0) + \sigma_{RW} \sum_{t= 1}^n \epsilon_t \\
X(0) &\sim \mathcal{N}(0, 1) \\
\epsilon_t &\sim \mathcal{N}(0, 1) \\
\sigma_{RW} &\sim \text{HalfNormal}(0.05).
\end{align}
```

### Log-Infections Model

The log-infections model is defined by a Turing model `log_infections` that takes the observed data `y_t` (or `missing` value),
an `EpiModel` object `epi_model`, and a `latent_model` model. In this case the latent process is a random walk model.

It also accepts optional arguments for the `process_priors`, `transform_function`, `pos_shift`, `neg_bin_cluster_factor`, and `neg_bin_cluster_factor_prior`.

```math
\log I_t = \exp(X(t)).
```

### Observation model

The observation model is a negative binomial distribution with mean `μ` and cluster factor `r`. Delays are implemented
as the action of a sparse kernel on the infections $I(t)$. The delay kernel is contained in an `EpiModel` struct.

```math
\begin{align}
y_t &\sim \text{NegBinomial}(\mu = \sum_s\geq 0 K[t, t-s] I(s), r),
r &\sim \text{Gamma}(3, 0.05/3).
\end{align}
```

"

# ╔═╡ Cell order:
# ╟─c593a2a0-d7f5-11ee-0931-d9f65ae84a72
# ╠═3ebc8384-f73d-4597-83a7-07a3744fed61
