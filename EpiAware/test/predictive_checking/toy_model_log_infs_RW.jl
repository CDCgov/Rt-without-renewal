#=
# Toy model for running analysis:

This is a toy model for demonstrating current functionality of EpiAware package.

## Generative Model without data

### Latent Process

The latent process is a random walk defined by a Turing model `random_walk` of specified
    length `n`.

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

The log-infections model is defined by a Turing model `log_infections` that takes the
    observed data `y_t` (or `missing` value), an `EpiModel` object `epi_model`, and a
    `latent_model` model. In this case the latent process is a random walk model.

It also accepts optional arguments for the `process_priors`, `transform_function`,
    `pos_shift`, `neg_bin_cluster_factor`, and `neg_bin_cluster_factor_prior`.

```math
\log I_t = \exp(X(t)).
```

### Observation model

The observation model is a negative binomial distribution with mean `μ` and cluster factor
    `r`. Delays are implemented as the action of a sparse kernel on the infections $I(t)$.
The delay kernel is contained in an `EpiModel` struct.

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
using CSV
using Pathfinder

Random.seed!(0)

#=
## Create an `EpiModel` struct

- Medium length generation interval distribution.
- Median 2 day, std 4.3 day delay distribution.
=#

truth_GI = Gamma(2, 5)
model_data = EpiData(truth_GI,
    D_gen = 10.0)

log_I0_prior = Normal(0.0, 1.0)
epi_model = DirectInfections(model_data, log_I0_prior)

#=
## Define the data generating process

In this case we use the `DirectInfections` model.
=#

rwp = EpiAware.RandomWalk(Normal(),
    truncated(Normal(0.0, 0.01), 0.0, 0.5))

#Define the observation model - no delay model
time_horizon = 100
obs_model = EpiAware.DelayObservations([1.0],
    time_horizon,
    truncated(Gamma(5, 0.05 / 5), 1e-3, 1.0))

#=
## Generate a `Turing` `Model`
We don't have observed data, so we use `missing` value for `y_t`.
=#

log_infs_model = make_epi_aware(missing, time_horizon, ; epi_model = epi_model,
    latent_model_model = rwp, observation_model = obs_model,
    pos_shift = 1e-6)

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

plot(gen.I_t,
    label = "I_t",
    xlabel = "Time",
    ylabel = "Infections",
    title = "Generated Infections")
scatter!(random_epidemic.y_t, lab = "generated cases")

#=
## Model with observed data

We treat the generated data as observed data and attempt to infer underlying infections.
=#

truth_data = random_epidemic.y_t

model = make_epi_aware(truth_data, time_horizon; epi_model = epi_model,
    latent_model_model = rwp, observation_model = obs_model,
    pos_shift = 1e-6)

#=
### Pathfinder inference

We can use pathfinder to get draws from the model. We can later use these draws to
    initialize the MCMC chain. We can also compare a single run of pathfinder with
=#

safe_model = make_epi_aware(truth_data, time_horizon, Val(:safe);
    epi_model = epi_model,
    latent_model_model = rwp,
    observation_model = obs_model,
    pos_shift = 1e-6)

mpf_result = multipathfinder(safe_model, 1000; nruns = 10)

mpf_chn = mpf_result.draws_transformed

@time chn = sample(model,
    NUTS(; adtype = AutoReverseDiff(true)),
    MCMCThreads(),
    250,
    4;
    drop_warmup = true,
    init_params = collect.(eachrow(mpf_chn.value[1:4, :, 1]))
)

#=
## Postior predictive checking

We check the posterior predictive checking by plotting the predicted cases against the observed cases.
=#

predicted_y_t, mpf_predicted_y_t = map((chn, mpf_chn)) do _chn
    mapreduce(hcat, generated_quantities(log_infs_model, _chn)) do gen
        gen.generated_y_t
    end
end

data_pred_plts = map(("NUTS", "multi-pf"),
    (predicted_y_t, mpf_predicted_y_t)) do title_str, pred_y_t
    plt = plot(pred_y_t, c = :grey, alpha = 0.05, lab = "")
    scatter!(plt, truth_data,
        lab = "Observed cases",
        xlabel = "Time",
        ylabel = "Cases",
        title = "Posterior Predictive Checking: " * title_str,
        ylims = (-0.5, maximum(truth_data) * 2.5))
    return plt
end

plot(data_pred_plts...,
    layout = (2, 1),
    size = (500, 700))

#=
## Underlying inferred infections
=#

predicted_I_t, mpf_predicted_I_t = map((chn, mpf_chn)) do _chn
    mapreduce(hcat, generated_quantities(log_infs_model, _chn)) do gen
        gen.I_t
    end
end

plts_infs = map(("NUTS", "multi-pf"),
    (predicted_I_t, mpf_predicted_I_t)) do title_str, pred_I_t
    plt = plot(pred_I_t, c = :grey, alpha = 0.05, lab = "")
    scatter!(plt, gen.I_t,
        lab = "Actual infections",
        xlabel = "Time",
        ylabel = "Infections",
        title = "Posterior Predictive Checking: " * title_str,
        ylims = (-0.5, maximum(gen.I_t) * 1.5))
    return plt
end

plot(plts_infs...,
    layout = (2, 1),
    size = (500, 700))
plot(pf_predicted_I_t, c = :grey, alpha = 0.05, lab = "")
plot(predicted_I_t, c = :blue, alpha = 0.05, lab = "")

scatter!(gen.I_t,
    lab = "Actual infections",
    xlabel = "Time",
    ylabel = "Unobserved Infections",
    title = "Posterior Predictive Checking",
    ylims = (-0.5, maximum(gen.I_t) * 1.5))

#=
## Outputing the MCMC chain
We can use `spread_draws` to convert the MCMC chain into a tidybayes format.
=#

df_chn = spread_draws(chn)
save_path = joinpath(@__DIR__, "assets/toy_model_log_infs_RW_draws.csv")
CSV.write(save_path, df_chn)
