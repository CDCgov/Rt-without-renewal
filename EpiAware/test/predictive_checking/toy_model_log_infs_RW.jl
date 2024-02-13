using Pkg: generate
#=
# Toy model for running analysis:

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
an `EpiModel` object `epimodel`, and a `latent_process` model. In this case the latent process is a random walk model.

It also accepts optional arguments for the `latent_process_priors`, `transform_function`, `pos_shift`, `neg_bin_cluster_factor`, and `neg_bin_cluster_factor_prior`.

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

## Load dependencies in `TestEnv`

=#

split(pwd(), "/")[end] != "EpiAware" && begin
    cd("./EpiAware")
    using Pkg
    Pkg.activate(".")

    using TestEnv
    TestEnv.activate()
end

using EpiAware
using Turing
using Distributions
using StatsPlots
using Random
using DynamicPPL
Random.seed!(0)

#=
## Create an `EpiModel` struct
Somewhat randomly chosen parameters for the `EpiModel` struct.

=#

truth_GI = Gamma(1, 2)
truth_delay = Uniform(0.0, 5.0)
neg_bin_cluster_factor = 0.05
time_horizon = 100

epimodel = EpiModel(
    truth_GI,
    truth_delay,
    neg_bin_cluster_factor,
    time_horizon,
    D_gen = 10.0,
    D_delay = 10.0,
)

#=
## Define a log-infections model
The log-infections model is defined by a Turing model `log_infections`.

In this case we don't have observed data, so we use `missing` value for `y_t`.
=#
toy_log_infs = log_infections(
    missing,
    epimodel,
    random_walk;
    latent_process_priors = EpiAware.STANDARD_RW_PRIORS,
)

#=
## Sample from the model
I define a fixed version of the model with initial infections set to 10 and variance of the random walk process set to 0.1.
We can sample from the model using the `rand` function, and plot the generated infections against generated cases.
=#
cond_toy = fix(toy_log_infs, (init_rw_value = log(10.0), σ²_RW = 0.1))
random_epidemic = rand(cond_toy)

# We can get the generated infections using `generated_quantities` function. Because the observed
# cases are "defined" with a `~` operator they can be accessed directly from the randomly sampled
# process.
gen = generated_quantities(cond_toy, random_epidemic)
plot(
    gen.I_t,
    label = "I_t",
    xlabel = "Time",
    ylabel = "Infections",
    title = "Generated Infections",
)
scatter!(X.y_t, lab = "generated cases")
