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

## Load dependencies

This script should be run from the root folder of `EpiAware` and with the active environment.

=#



using TestEnv # Run in Test environment mode
TestEnv.activate()

using EpiAware
using Turing
using Distributions
using StatsPlots
using Random
using DynamicPPL
Random.seed!(0)

#=
## Create an `EpiModel` struct

- Medium length generation interval distribution.
- Median 2 day, std 4.3 day delay distribution.
- 100 days of simulations
=#

truth_GI = Gamma(2, 5)
truth_delay = LogNormal(2.0, 1.0)
neg_bin_cluster_factor = 0.05
time_horizon = 100

model_data = EpiData(
    truth_GI,
    truth_delay,
    neg_bin_cluster_factor,
    time_horizon,
    D_gen = 10.0,
    D_delay = 10.0,
)

#=
## Define the data generating process

In this case we use the `DirectInfections` model.
=#

toy_log_infs = DirectInfections(model_data)

#=
## Generate a `Turing` `Model`
We don't have observed data, so we use `missing` value for `y_t`.
=#

log_infs_model = make_epi_inference_model(
    missing,
    toy_log_infs,
    random_walk,
    latent_process_priors = default_rw_priors(),
    pos_shift = 1e-6,
    neg_bin_cluster_factor = 0.5,
    neg_bin_cluster_factor_prior = Gamma(3, 0.05 / 3),
)



#=
## Sample from the model
I define a fixed version of the model with initial infections set to 10 and variance of the random walk process set to 0.1.
We can sample from the model using the `rand` function, and plot the generated infections against generated cases.
=#
# We can get the generated infections using `generated_quantities` function. Because the observed
# cases are "defined" with a `~` operator they can be accessed directly from the randomly sampled
# process.

cond_toy = fix(log_infs_model, (init_rw_value = log(10.0), σ²_RW = 0.1))
random_epidemic = rand(cond_toy)
gen = generated_quantities(cond_toy, random_epidemic)
plot(
    gen.I_t,
    label = "I_t",
    xlabel = "Time",
    ylabel = "Infections",
    title = "Generated Infections",
)
scatter!(random_epidemic.y_t, lab = "generated cases")
