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

## Load dependencies

This script should be run from Test environment mode. If not, run the following command:

```julia
using TestEnv # Run in Test environment mode
TestEnv.activate()
```

=#

# using TestEnv # Run in Test environment mode
# TestEnv.activate()

using EpiAware
using Turing
using Distributions
using StatsPlots
using Random
using DynamicPPL
using Statistics
using DataFramesMeta
using CSV # For outputting the MCMC chain

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
    D_delay = 10.0
)

#=
## Define the data generating process

In this case we use the `DirectInfections` model.
=#

toy_log_infs = DirectInfections(model_data)
rwp = random_walk_process()
obs_mdl = delay_observations_model()

#=
## Generate a `Turing` `Model`
We don't have observed data, so we use `missing` value for `y_t`.
=#

log_infs_model = make_epi_inference_model(
    missing, toy_log_infs, rwp, obs_mdl; pos_shift = 1e-6)

#=
## Sample from the model
I define a fixed version of the model with initial infections set to 1 and variance of the random walk process set to 0.1.
We can sample from the model using the `rand` function, and plot the generated infections against generated cases.

We can get the generated infections using `generated_quantities` function. Because the observed
cases are "defined" with a `~` operator they can be accessed directly from the randomly sampled
process.
=#

cond_toy = fix(log_infs_model, (init = log(1.0), σ²_RW = 0.1))
random_epidemic = rand(cond_toy)
gen = generated_quantities(cond_toy, random_epidemic)

plot(
    gen.I_t,
    label = "I_t",
    xlabel = "Time",
    ylabel = "Infections",
    title = "Generated Infections"
)
scatter!(random_epidemic.y_t, lab = "generated cases")

#=
## Inference

We treat the generated data as observed data and attempt to infer underlying infections.
=#

truth_data = random_epidemic.y_t

model = make_epi_inference_model(truth_data, toy_log_infs, rwp, obs_mdl; pos_shift = 1e-6)

@time chn = sample(
    model,
    NUTS(; adtype = AutoReverseDiff(true)),
    MCMCThreads(),
    250,
    4;
    drop_warmup = true
)

#=
## Postior predictive checking

We check the posterior predictive checking by plotting the predicted cases against the observed cases.
=#

predicted_y_t = mapreduce(hcat, generated_quantities(log_infs_model, chn)) do gen
    gen.generated_y_t
end

plot(predicted_y_t, c = :grey, alpha = 0.05, lab = "")
scatter!(
    truth_data,
    lab = "Observed cases",
    xlabel = "Time",
    ylabel = "Cases",
    title = "Posterior Predictive Checking",
    ylims = (-0.5, maximum(truth_data) * 2.5)
)

#=
## Underlying inferred infections
=#

predicted_I_t = mapreduce(hcat, generated_quantities(log_infs_model, chn)) do gen
    gen.I_t
end

plot(predicted_I_t, c = :grey, alpha = 0.05, lab = "")
scatter!(
    gen.I_t,
    lab = "Actual infections",
    xlabel = "Time",
    ylabel = "Unobserved Infections",
    title = "Posterior Predictive Checking",
    ylims = (-0.5, maximum(gen.I_t) * 1.5)
)

#=
## Outputing the MCMC chain
We can use `spread_draws` to convert the MCMC chain into a tidybayes format.
=#

df_chn = spread_draws(chn)
save_path = joinpath(@__DIR__, "assets/toy_model_log_infs_RW_draws.csv")
CSV.write(save_path, df_chn)
