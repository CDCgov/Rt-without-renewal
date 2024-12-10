### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# ╔═╡ e34cec5a-a173-4e92-a860-340c7a9e9c72
let
    docs_dir = dirname(dirname(dirname(dirname(@__DIR__))))
    using Pkg: Pkg
    Pkg.activate(docs_dir)
    Pkg.instantiate()
end;

# ╔═╡ b1468db3-7ab0-468c-8e27-70013a8f512f
using EpiAware

# ╔═╡ a4710701-6315-459d-b677-f24b77ff3e80
using Turing

# ╔═╡ 7263d714-2ce4-4d57-8881-6b60db018dd5
using OrdinaryDiffEq, SciMLSensitivity #ODE solvers and adjoint methods

# ╔═╡ 261420cd-4650-402b-b126-7a431f93f37e
using Distributions, Statistics, LogExpFunctions #Statistics and special func packages

# ╔═╡ 9c19a98b-a08b-4560-966d-61ff0ece2ad5
using CSV, DataFramesMeta #Data wrangling

# ╔═╡ 3897e773-ed07-4860-bb62-35605d0dacb0
using CairoMakie, PairPlots

# ╔═╡ 14641441-dbea-4fdf-88e0-64a57da60ef7
using ADTypes, Mooncake #Automatic differentiation backend

# ╔═╡ a0d91258-8ab5-4adc-98f2-8f17b4bd685c
begin #Date utility and set Random seed
    using Dates
    using Random
    Random.seed!(1234)
end

# ╔═╡ 33384fc6-7cca-11ef-3567-ab7df9200cde
md"
# Example: Statistical inference for ODE-based infectious disease models
# Introduction
## What are we going to do in this Vignette
In this vignette, we'll demonstrate how to use `EpiAware` in conjunction with [SciML ecosystem](https://sciml.ai/) for Bayesian inference of infectious disease dynamics.
The model and data is heavily based on [Contemporary statistical inference for infectious disease models using Stan _Chatzilena et al. 2019_](https://www.sciencedirect.com/science/article/pii/S1755436519300325).

We'll cover the following key points:

1. Defining the deterministic ODE model from Chatzilena et al section 2.2.2 using SciML ODE functionality and an `EpiAware` observation model.
2. Build on this to define the stochastic ODE model from Chatzilena et al section 2.2.3 using an `EpiAware` observation model.
3. Fitting the deterministic ODE model to data from an Influenza outbreak in an English boarding school.
4. Fitting the stochastic ODE model to data from an Influenza outbreak in an English boarding school.

## What might I need to know before starting

This vignette builds on concepts from `EpiAware` observation models and a familarity with the `SciML` and `Turing` ecosystems would be useful but not essential.

## Packages used in this vignette

Alongside the `EpiAware` package we will use the `OrdinaryDiffEq` and `SciMLSensitivity` packages for interfacing with `SciML` ecosystem; this is a lower dependency usage of `DifferentialEquations.jl` that, respectively, exposes ODE solvers and adjoint methods for ODE solvees; that is the method of propagating parameter derivatives through functions containing ODE solutions.
Bayesian inference will be done with `NUTS` from the `Turing` ecosystem. We will also use the `CairoMakie` package for plotting and `DataFramesMeta` for data manipulation.
"

# ╔═╡ 943b82ec-b4dc-4537-8183-d6c73cd74a37
md"
# Single population SIR model

As mentioned in _Chatzilena et al_ disease spread is frequently modelled in terms of ODE-based models.
The study population is divided into compartments representing a specific stage of the epidemic status.
In this case, susceptible, infected, and recovered individuals.

```math
\begin{aligned}
{dS \over dt} &= - \beta \frac{I(t)}{N} S(t) \\
{dI \over dt} &= \beta \frac{I(t)}{N} S(t) - \gamma I(t) \\
{dR \over dt} &= \gamma I(t). \\
\end{aligned}
```
where S(t) represents the number of susceptible, I(t) the number of
infected and R(t) the number of recovered individuals at time t.
The total population size is denoted by N (with N = S(t) + I(t) + R(t)), β denotes the transmission rate and γ denotes the recovery rate.

"

# ╔═╡ 0e78285c-d2e8-4c3c-848a-14dae6ead0a4
md"
We can interface to the `SciML` ecosystem by writing a function with the signature:

> `(du, u, p, t) -> nothing`

Where:
- `du` is the _vector field_ of the ODE problem, e.g. ${dS \over dt}$, ${dI \over dt}$ etc. This is calculated _in-place_ (commonly denoted using ! in function names in Julia).
- `u` is the _state_ of the ODE problem, e.g. $S$, $I$, etc.
- `p` is an object that represents the parameters of the ODE problem, e.g. $\beta$, $\gamma$.
- `t` is the time of the ODE problem.

We do this for the SIR model described above in a function called `sir!`:
"

# ╔═╡ ab4269b1-e292-466f-8bfb-713d917c18f9
function sir!(du, u, p, t)
    S, I, R = u
    β, γ = p
    du[1] = -β * I * S
    du[2] = β * I * S - γ * I
    du[3] = γ * I

    return nothing
end

# ╔═╡ f16eb00b-2d77-45df-b767-757fe2f5674c
md"
We combine vector field function `sir!` with a initial condition `u0` and the integration period `tspan` to make an `ODEProblem`.
We do not define the parameters, these will be defined within an inference approach.
"

# ╔═╡ b5ff95d1-8a6f-4d48-adf2-60d91b3ebebe
md"
Note that this is analogous to the `EpiProblem` approach we expose from `EpiAware`, as used in the [Mishra et al replication](https://cdcgov.github.io/Rt-without-renewal/dev/showcase/replications/mishra-2020/).
The difference is that here we are going to use ODE solvers from the `SciML` ecosystem to generate the dynamics of the underlying infections.
In the linked example, we use latent process generation exposed by `EpiAware` as the underlying generative process for underlying dynamics.
"

# ╔═╡ d64388f9-6edd-414d-a191-316f75b35b2c
md"

## Data for inference

There was a brief, but intense, outbreak of Influenza within the (semi-) closed community of a boarding school reported to the British medical journal in 1978.
The outbreak lasted from 22nd January to 4th February and it is reported that one infected child started the epidemic and then it spread rapidly.
Of the 763 children at the boarding scholl, 512 became ill.

We downloaded the data of this outbreak using the R package `outbreaks` which is maintained as part of the [R Epidemics Consortium(RECON)](http://www. repidemicsconsortium.org).

"

# ╔═╡ 7c9cbbc1-71ef-4d81-b93a-c2b3a8683d53
data = "https://raw.githubusercontent.com/CDCgov/Rt-without-renewal/refs/heads/main/EpiAware/docs/src/showcase/replications/chatzilena-2019/influenza_england_1978_school.csv2" |>
       url -> CSV.read(download(url), DataFrame) |>
              df -> @transform(df,
    :ts=(:date .- minimum(:date)) .|> d -> d.value + 1.0,)

# ╔═╡ aba3f1db-c290-409c-9b9e-6065935ede54
N = 763;

# ╔═╡ bb07a580-6d86-48b3-a79f-d2ed9306e87c
sir_prob = ODEProblem(
    sir!,
    N .* [0.99, 0.01, 0.0],
    (0.0, (Date(1978, 2, 4) - Date(1978, 1, 22)).value + 1)
)

# ╔═╡ 3f54bb44-76c4-4744-885a-46dedfaffeca
md"
## Inference for the deterministic SIR model

The boarding school data gives the number of children \"in bed\" and \"convalescent\" on each of 14 days from 22nd Jan to 4th Feb 1978.
We follow _Chatzilena et al_ and treat the number \"in bed\" as a proxy for the number of children in the infectious (I) compartment in the ODE model.

The full observation model is:

```math
\begin{aligned}
Y_t &\sim \text{Poisson}(\lambda_t)\\
\lambda_t &= I(t)\\
\beta &\sim \text{LogNormal}(\text{logmean}=0,\text{logstd}=1) \\
\gamma & \sim \text{Gamma}(\text{shape} = 0.004, \text{scale} = 50)\\
S(0) /N &\sim \text{Beta}(0.5, 0.5).
\end{aligned}
```

**NB: Chatzilena et al give $\lambda_t = \int_0^t  \beta \frac{I(s)}{N} S(s) - \gamma I(s)ds = I(t) - I(0).$
However, this doesn't match their underlying stan code.**
"

# ╔═╡ ea1be94b-d722-47ee-8465-982c83dc6838
md"
From `EpiAware`, we have the `PoissonError` struct which defines the probabilistic structure of this observation error model.
"

# ╔═╡ 87509792-e28d-4618-9bf5-e06b2e5dbe8b
obs = PoissonError()

# ╔═╡ 81501c84-5e1f-4829-a26d-52fe00503958
md"
Now we can write the probabilistic model using the `Turing` PPL.
Note that instead of using $I(t)$ directly we do the [softplus](https://en.wikipedia.org/wiki/Softplus) transform on $I(t)$ implemented by `LogExpFunctions.log1pexp`.
The reason is that the solver can return small negative numbers, the soft plus transform smoothly maintains positivity which being very close to $I(t)$ when $I(t) > 2$.
"

# ╔═╡ 1d287c8e-7000-4b23-ae7e-f7008c3e53bd
@model function deterministic_ode_mdl(y_t, ts, obs, prob, N;
        solver = AutoTsit5(Rosenbrock23())
)
    ##Priors##
    β ~ LogNormal(0.0, 1.0)
    γ ~ Gamma(0.004, 1 / 0.002)
    S₀ ~ Beta(0.5, 0.5)

    ##remake ODE model##
    _prob = remake(prob;
        u0 = [S₀, 1 - S₀, 0.0],
        p = [β, γ]
    )

    ##Solve remade ODE model##

    sol = solve(_prob, solver;
        saveat = ts,
        verbose = false)

    ##log-like accumulation using obs##
    λt = log1pexp.(N * sol[2, :]) # #expected It
    @submodel generated_y_t = generate_observations(obs, y_t, λt)

    ##Generated quantities##
    return (; sol, generated_y_t, R0 = β / γ)
end

# ╔═╡ e7383885-fa6a-4240-a252-44ae82cae713
md"
We instantiate the model in two ways:

1. `deterministic_mdl`: This conditions the generative model on the data observation. We can sample from this model to find the posterior distribution of the parameters.
2. `deterministic_uncond_mdl`: This _doesn't_ condition on the data. This is useful for prior and posterior predictive modelling.

Here we construct the `Turing` model directly, in the [Mishra et al replication](https://cdcgov.github.io/Rt-without-renewal/dev/showcase/replications/mishra-2020/) we using the `EpiProblem` functionality to build a `Turing` model under the hood.
Because in this note we are using a mix of functionality from `SciML` and `EpiAware`, we construct the model to sample from directly.
"

# ╔═╡ dbc1b453-1c29-4f82-bec9-098d67f9e63f
deterministic_mdl = deterministic_ode_mdl(data.in_bed, data.ts, obs, sir_prob, N);

# ╔═╡ e795c2bf-0861-4e96-9921-db47f41af206
deterministic_uncond_mdl = deterministic_ode_mdl(
    fill(missing, length(data.in_bed)), data.ts, obs, sir_prob, N);

# ╔═╡ e848434c-2543-43d1-ae22-5c4241f138bb
md"
We add a useful plotting utility.
"

# ╔═╡ ab8c98d1-d357-4c49-9f5a-f069e05c45f5
function plot_predYt(data, gens; title::String, ylabel::String)
    fig = Figure()
    ga = fig[1, 1:2] = GridLayout()

    ax = Axis(ga[1, 1];
        title = title,
        xticks = (data.ts[1:3:end], data.date[1:3:end] .|> string),
        ylabel = ylabel
    )
    pred_Yt = mapreduce(hcat, gens) do gen
        gen.generated_y_t
    end |> X -> mapreduce(vcat, eachrow(X)) do row
        quantile(row, [0.5, 0.025, 0.975, 0.1, 0.9, 0.25, 0.75])'
    end

    lines!(ax, data.ts, pred_Yt[:, 1]; linewidth = 3, color = :green, label = "Median")
    band!(
        ax, data.ts, pred_Yt[:, 2], pred_Yt[:, 3], color = (:green, 0.2), label = "95% CI")
    band!(
        ax, data.ts, pred_Yt[:, 4], pred_Yt[:, 5], color = (:green, 0.4), label = "80% CI")
    band!(
        ax, data.ts, pred_Yt[:, 6], pred_Yt[:, 7], color = (:green, 0.6), label = "50% CI")
    scatter!(ax, data.in_bed, label = "data")
    leg = Legend(ga[1, 2], ax; framevisible = false)
    hidespines!(ax)

    fig
end

# ╔═╡ 2c6ac235-e331-4189-8c8c-74de5f98b2c4
md"
**Prior predictive sampling**
"

# ╔═╡ a729f1cd-404c-4a33-a8f9-b2ea6f0adb62
let
    prior_chn = sample(deterministic_uncond_mdl, Prior(), 2000)
    gens = generated_quantities(deterministic_uncond_mdl, prior_chn)
    plot_predYt(data, gens;
        title = "Prior predictive: deterministic model",
        ylabel = "Number of Infected students"
    )
end

# ╔═╡ 4c0759fb-76e9-4de5-9206-89e8bfb6c3bb
md"
The prior predictive checking suggests that _a priori_ our parameter beliefs are very far from the data.
Approaching the inference naively can lead to poor fits.

We do three things to mitigate this:

1. We choose a switching ODE solver which switches between explicit (`Tsit5`) and implicit (`Rosenbrock23`) solvers. This helps avoid the ODE solver failing when the sampler tries extreme parameter values. This is the default `solver = AutoTsit5(Rosenbrock23())` above.
2. We locate the maximum likelihood point, that is we ignore the influence of the priors, as a useful starting point for `NUTS`.
"

# ╔═╡ 8d96db67-de3b-4704-9f54-f4ed50a4ecff
nmle_tries = 100

# ╔═╡ ba35cebd-0d29-43c5-8db7-f550d7f821bc
mle_fit = map(1:nmle_tries) do _
    fit = try
        maximum_likelihood(deterministic_mdl)
    catch
        (lp = -Inf,)
    end
end |>
          fits -> (findmax(fit -> fit.lp, fits)[2], fits) |>
                  max_and_fits -> max_and_fits[2][max_and_fits[1]]

# ╔═╡ 0be912c1-22dc-4978-b86a-84273062f5da
mle_fit.optim_result.retcode

# ╔═╡ a1a34b67-ff4e-4fee-aa30-4c2add3ea8a0
md"
Note that we choose the best out of $nmle_tries tries for the MLE estimators.

Now, we sample aiming at 1000 samples for each of 4 chains.
"

# ╔═╡ 2cf64ba3-ff8d-40b0-9bd8-9e80393156f5
chn = sample(
    deterministic_mdl, NUTS(), MCMCThreads(), 1000, 4;
    initial_params = fill(mle_fit.values.array, 4)
)

# ╔═╡ b2429b68-dd75-499f-a4e1-1b7d72e209c7
describe(chn)

# ╔═╡ 1e7f37c5-4cb4-4d06-8f68-55d80f7a00ad
pairplot(chn)

# ╔═╡ c16b81a0-2d36-4012-aed4-a035af31b4c3
md"
**Posterior predictive plotting**
"

# ╔═╡ 03d1ecf8-543d-444d-b1a3-7a19acd88499
let
    gens = generated_quantities(deterministic_uncond_mdl, chn)
    plot_predYt(data, gens;
        title = "Fitted deterministic model",
        ylabel = "Number of Infected students"
    )
end

# ╔═╡ e023770d-25f7-4b7a-b509-8a4372f42b76
md"
## Inference for the Stochastic SIR model

In _Chatzilena et al_, they present an auto-regressive model for connecting the outcome of the ODE model to illness observations.
The argument is that the stochastic component of the model can absorb the noise generated by a possible mis-specification of the model.

In their approach they consider $\kappa_t = \log \lambda_t$ where $\kappa_t$ evolves according to an Ornstein-Uhlenbeck process:

```math
d\kappa_t = \phi(\mu_t - \kappa_t) dt + \sigma dB_t.
```
Which has transition density:
```math
\kappa_{t+1} | \kappa_t \sim N\Big(\mu_t + \left(\kappa_t - \mu_t\right)e^{-\phi}, {\sigma^2 \over 2 \phi} \left(1 - e^{-2\phi} \right)\Big).
```
Where $\mu_t = \log(I(t))$.

We modify this approach since it implies that the $\mu_t$ is treated as constant between observation times.

Instead we redefine $\kappa_t$ as the log-residual:

$\kappa_t = \log(\lambda_t / I(t)).$

With the transition density:

```math
\kappa_{t+1} | \kappa_t \sim N\Big(\kappa_te^{-\phi}, {\sigma^2 \over 2 \phi} \left(1 - e^{-2\phi} \right)\Big).
```

This is an AR(1) process.

The stochastic model is completed:

```math
\begin{aligned}
Y_t &\sim \text{Poisson}(\lambda_t)\\
\lambda_t &= I(t)\exp(\kappa_t)\\
\beta &\sim \text{LogNormal}(\text{logmean}=0,\text{logstd}=1) \\
\gamma & \sim \text{Gamma}(\text{shape} = 0.004, \text{scale} = 50)\\
S(0) /N &\sim \text{Beta}(0.5, 0.5)\\
\phi & \sim \text{HalfNormal}(0, 100) \\
1 / \sigma^2 & \sim \text{InvGamma}(0.1,0.1).
\end{aligned}
```

"

# ╔═╡ 69ba59d1-2221-463f-8853-ae172739e512
md"
We will using the `AR` struct from `EpiAware` to define the auto-regressive process in this model which has a direct parameterisation of the `AR` model.

To convert from the formulation above we sample from the priors, and define `HalfNormal` priors based on the sampled prior means of $e^{-\phi}$ and ${\sigma^2 \over 2 \phi} \left(1 - e^{-2\phi} \right)$.
We also add a strong prior that $\kappa_1 \approx 0$.
"

# ╔═╡ 178e0048-069a-4953-bb24-5116eb81cc41
ϕs = rand(truncated(Normal(0, 100), lower = 0.0), 1000)

# ╔═╡ e6bcf0c0-3cc4-41f3-ad20-fa11bf2ca37b
σ²s = rand(InverseGamma(0.1, 0.1), 1000) .|> x -> 1 / x

# ╔═╡ 4f07e8ba-30d0-411f-8c3e-b6d5bc1bb5fa
sampled_AR_damps = ϕs .|> ϕ -> exp(-ϕ)

# ╔═╡ 48032d21-53fa-4c0a-85cb-c22327b55073
sampled_AR_stds = map(ϕs, σ²s) do ϕ, σ²
    (1 - exp(-2 * ϕ)) * σ² / (2 * ϕ)
end

# ╔═╡ 89c767b8-97a0-45bb-9e9f-821879ddd38b
md"
We define the AR(1) process by matching means of `HalfNormal` prior distributions for the damp parameters and std deviation parameter to the calculated the prior means from the _Chatzilena et al_ definition.
"

# ╔═╡ 71a26408-1c26-46cf-bc72-c6ba528dfadd
ar = AR(
    damp_priors = [HalfNormal(mean(sampled_AR_damps))],
    init_priors = [Normal(0, 0.001)],
    ϵ_t = HierarchicalNormal(std_prior = HalfNormal(mean(sampled_AR_stds)))
)

# ╔═╡ e1ffdaf6-ca2e-405d-8355-0d8848d005b0
md"
We can sample directly from the behaviour specified by the `ar` struct to do prior predictive checking on the `AR(1)` process.
"

# ╔═╡ de1498fa-8502-40ba-9708-2add74368e73
let
    nobs = size(data, 1)
    ar_mdl = generate_latent(ar, nobs)
    fig = Figure()
    ax = Axis(fig[1, 1],
        xticks = (data.ts[1:3:end], data.date[1:3:end] .|> string),
        ylabel = "exp(kt)",
        title = "Prior predictive sampling for relative residual in mean pred."
    )
    for i in 1:500
        lines!(ax, ar_mdl() .|> exp, color = (:grey, 0.15))
    end
    fig
end

# ╔═╡ 9a82c75a-6ea4-48bb-af06-fabaca4c45ee
md"
We see that the choice of priors implies an _a priori_ belief that the extra observation noise on the mean prediction of the ODE model is fairly small, approximately 10% relative to the mean prediction.
"

# ╔═╡ b693a942-c6c7-40f8-997c-0dc8e5548132
md"
We can now define the probabilistic model.
The stochastic model assumes a (random) time-varying ascertainment, which we implement using the `Ascertainment` struct from `EpiAware`.
Note that instead of implementing an ascertainment factor `exp.(κₜ)` directly, which can be unstable for large primal values, by default `Ascertainment` uses the `LogExpFunctions.xexpy` function which implements $x\exp(y)$ stabily for a wide range of values.
"

# ╔═╡ 8588c45d-c225-4779-b7d0-8a9fd059f30e
md"
To distinguish random variables sampled by various sub-processes `EpiAware` process types create prefixes.
The default for `Ascertainment` is just the string `\"Ascertainment\"`, but in this case we use the less verbose `\"va\"` for \"varying ascertainment\".
"

# ╔═╡ f116bb64-0426-4cd5-a01d-d8916d61af6d
mdl_prefix = "va"

# ╔═╡ 8956b070-3b9a-4a0f-a5a0-ff0b2770d9de
md"
Now we can construct our time varying ascertianment model.
The main keyword arguments here are `model` and `latent_model`.
`model` sets the connection between the expected observation and the actual observation.
In this case, we reuse our `PoissonError` model from above.
`latent_model` sets the modification model on the expected values.
In this case, we use the `AR` process we defined above.
"

# ╔═╡ c7b5d1dd-3e21-4841-b096-917328432c3c
varying_ascertainment = Ascertainment(
    model = obs,
    latent_model = ar,
    latent_prefix = mdl_prefix
)

# ╔═╡ 0e2e281c-ef19-4027-a1fa-16ce17b7bdd7
md"
Now we can declare the full model in the `Turing` PPL.
"

# ╔═╡ 9309f7f8-0896-4686-8bfc-b9f82d91bc0f
@model function stochastic_ode_mdl(y_t, ts, obs, prob, N;
        solver = AutoTsit5(Rosenbrock23())
)

    ##Priors##
    β ~ LogNormal(0.0, 1.0)
    γ ~ Gamma(0.004, 1 / 0.002)
    S₀ ~ Beta(0.5, 0.5)

    ##Remake ODE model##
    _prob = remake(prob;
        u0 = [S₀, 1 - S₀, 0.0],
        p = [β, γ]
    )

    ##Solve ODE model##
    sol = solve(_prob, solver;
        saveat = ts,
        verbose = false
    )
    λt = log1pexp.(N * sol[2, :])

    ##Observation##
    @submodel generated_y_t = generate_observations(obs, y_t, λt)

    ##Generated quantities##
    return (; sol, generated_y_t, R0 = β / γ)
end

# ╔═╡ 4330c83f-de39-44c7-bdab-87e5f5830145
stochastic_mdl = stochastic_ode_mdl(
    data.in_bed,
    data.ts,
    varying_ascertainment,
    sir_prob,
    N
)

# ╔═╡ 8071c92f-9fe8-48cf-b1a0-79d1e34ec7e7
stochastic_uncond_mdl = stochastic_ode_mdl(
    fill(missing, length(data.in_bed)),
    data.ts,
    varying_ascertainment,
    sir_prob,
    N
)

# ╔═╡ adb9d0ac-d412-4dbc-a601-59fcc33adf43
md"
**Prior predictive checking**
"

# ╔═╡ b44286f9-ba88-4e2b-9a34-f14c0a78824d
let
    prior_chn = sample(stochastic_uncond_mdl, Prior(), 2000)
    gens = generated_quantities(stochastic_uncond_mdl, prior_chn)
    plot_predYt(data, gens;
        title = "Prior predictive: stochastic model",
        ylabel = "Number of Infected students"
    )
end

# ╔═╡ f690114f-4dca-4451-8a93-57c9d8d7c20c
md"
The prior predictive checking again shows misaligned prior beliefs; for example _a priori_ without data we would not expect the median prediction of number of ill children as about 600 out of $N after 1 day.

The latent process for the log-residuals $\kappa_t$ doesn't make much sense without priors, so we look for a reasonable MAP point to start NUTS from.
We do this by first making an initial guess which is a mixture of:

1. The posterior averages from the deterministic model.
2. The prior averages of the structure parameters of the AR(1) process.
3. Zero for the time-varying noise underlying the AR(1) process.
"

# ╔═╡ 3491e7e5-6c82-4c50-8feb-d730d1fbe457
rand(stochastic_mdl)

# ╔═╡ e1d54935-4305-42cf-98c6-ccee9b0813ea
initial_guess = [[mean(chn[:β]),
                     mean(chn[:γ]),
                     mean(chn[:S₀]),
                     mean(ar.init_prior)[1],
                     mean(ar.damp_prior)[1],
                     mean(ar.ϵ_t.std_prior)
                 ]
                 zeros(13)]

# ╔═╡ 685221ea-f268-4ddc-937f-e7620d065c28
md"
Starting from the initial guess, the MAP point is calculated rapidly in one pass.
"

# ╔═╡ 6796ae76-bc2d-4895-ba0a-5e2c23c50dfb
map_fit_stoch_mdl = maximum_a_posteriori(stochastic_mdl;
    adtype = ADTypes.AutoMooncake(; config = nothing),
    initial_params = initial_guess
)

# ╔═╡ 62080cc2-3cab-4a22-9b2e-2bff640a17a4
md"
Now we can run NUTS, sampling 1000 posterior draws per chain for 4 chains.
"

# ╔═╡ 156272d7-56c4-4ac4-bf3e-7882f4edc144
chn2 = sample(
    stochastic_mdl,
    NUTS(; adtype = ADTypes.AutoMooncake(; config = nothing)),
    MCMCThreads(), 1000, 4;
    initial_params = fill(map_fit_stoch_mdl.values.array, 4)
)

# ╔═╡ 00b90e6d-732f-41c9-a603-cabe9740e329
describe(chn2)

# ╔═╡ 37a016d8-8384-41c9-abdd-23e88b1f988d
pairplot(chn2[[:β, :γ, :S₀, Symbol(mdl_prefix * ".std"),
    Symbol(mdl_prefix * ".ar_init[1]"), Symbol(mdl_prefix * ".damp_AR[1]")]])

# ╔═╡ 7df5d669-d3a2-4a66-83c3-f8618e39bec6
let
    vars = mapreduce(vcat, 1:13) do i
        Symbol(mdl_prefix * ".ϵ_t[$i]")
    end
    pairplot(chn2[vars])
end

# ╔═╡ 0e7bbf13-9187-41ea-8b46-294b93be4c6d
let
    gens = generated_quantities(stochastic_uncond_mdl, chn2)
    plot_predYt(data, gens;
        title = "Fitted stochastic model",
        ylabel = "Number of Infected students"
    )
end

# ╔═╡ Cell order:
# ╟─e34cec5a-a173-4e92-a860-340c7a9e9c72
# ╟─33384fc6-7cca-11ef-3567-ab7df9200cde
# ╠═b1468db3-7ab0-468c-8e27-70013a8f512f
# ╠═a4710701-6315-459d-b677-f24b77ff3e80
# ╠═7263d714-2ce4-4d57-8881-6b60db018dd5
# ╠═261420cd-4650-402b-b126-7a431f93f37e
# ╠═9c19a98b-a08b-4560-966d-61ff0ece2ad5
# ╠═3897e773-ed07-4860-bb62-35605d0dacb0
# ╠═14641441-dbea-4fdf-88e0-64a57da60ef7
# ╠═a0d91258-8ab5-4adc-98f2-8f17b4bd685c
# ╟─943b82ec-b4dc-4537-8183-d6c73cd74a37
# ╟─0e78285c-d2e8-4c3c-848a-14dae6ead0a4
# ╠═ab4269b1-e292-466f-8bfb-713d917c18f9
# ╟─f16eb00b-2d77-45df-b767-757fe2f5674c
# ╠═bb07a580-6d86-48b3-a79f-d2ed9306e87c
# ╟─b5ff95d1-8a6f-4d48-adf2-60d91b3ebebe
# ╟─d64388f9-6edd-414d-a191-316f75b35b2c
# ╠═7c9cbbc1-71ef-4d81-b93a-c2b3a8683d53
# ╠═aba3f1db-c290-409c-9b9e-6065935ede54
# ╟─3f54bb44-76c4-4744-885a-46dedfaffeca
# ╟─ea1be94b-d722-47ee-8465-982c83dc6838
# ╠═87509792-e28d-4618-9bf5-e06b2e5dbe8b
# ╟─81501c84-5e1f-4829-a26d-52fe00503958
# ╠═1d287c8e-7000-4b23-ae7e-f7008c3e53bd
# ╟─e7383885-fa6a-4240-a252-44ae82cae713
# ╠═dbc1b453-1c29-4f82-bec9-098d67f9e63f
# ╠═e795c2bf-0861-4e96-9921-db47f41af206
# ╟─e848434c-2543-43d1-ae22-5c4241f138bb
# ╠═ab8c98d1-d357-4c49-9f5a-f069e05c45f5
# ╟─2c6ac235-e331-4189-8c8c-74de5f98b2c4
# ╠═a729f1cd-404c-4a33-a8f9-b2ea6f0adb62
# ╟─4c0759fb-76e9-4de5-9206-89e8bfb6c3bb
# ╠═8d96db67-de3b-4704-9f54-f4ed50a4ecff
# ╠═ba35cebd-0d29-43c5-8db7-f550d7f821bc
# ╠═0be912c1-22dc-4978-b86a-84273062f5da
# ╟─a1a34b67-ff4e-4fee-aa30-4c2add3ea8a0
# ╠═2cf64ba3-ff8d-40b0-9bd8-9e80393156f5
# ╠═b2429b68-dd75-499f-a4e1-1b7d72e209c7
# ╠═1e7f37c5-4cb4-4d06-8f68-55d80f7a00ad
# ╟─c16b81a0-2d36-4012-aed4-a035af31b4c3
# ╠═03d1ecf8-543d-444d-b1a3-7a19acd88499
# ╟─e023770d-25f7-4b7a-b509-8a4372f42b76
# ╟─69ba59d1-2221-463f-8853-ae172739e512
# ╠═178e0048-069a-4953-bb24-5116eb81cc41
# ╠═e6bcf0c0-3cc4-41f3-ad20-fa11bf2ca37b
# ╠═4f07e8ba-30d0-411f-8c3e-b6d5bc1bb5fa
# ╠═48032d21-53fa-4c0a-85cb-c22327b55073
# ╟─89c767b8-97a0-45bb-9e9f-821879ddd38b
# ╠═71a26408-1c26-46cf-bc72-c6ba528dfadd
# ╟─e1ffdaf6-ca2e-405d-8355-0d8848d005b0
# ╠═de1498fa-8502-40ba-9708-2add74368e73
# ╟─9a82c75a-6ea4-48bb-af06-fabaca4c45ee
# ╟─b693a942-c6c7-40f8-997c-0dc8e5548132
# ╟─8588c45d-c225-4779-b7d0-8a9fd059f30e
# ╠═f116bb64-0426-4cd5-a01d-d8916d61af6d
# ╟─8956b070-3b9a-4a0f-a5a0-ff0b2770d9de
# ╠═c7b5d1dd-3e21-4841-b096-917328432c3c
# ╟─0e2e281c-ef19-4027-a1fa-16ce17b7bdd7
# ╠═9309f7f8-0896-4686-8bfc-b9f82d91bc0f
# ╠═4330c83f-de39-44c7-bdab-87e5f5830145
# ╠═8071c92f-9fe8-48cf-b1a0-79d1e34ec7e7
# ╟─adb9d0ac-d412-4dbc-a601-59fcc33adf43
# ╠═b44286f9-ba88-4e2b-9a34-f14c0a78824d
# ╟─f690114f-4dca-4451-8a93-57c9d8d7c20c
# ╠═3491e7e5-6c82-4c50-8feb-d730d1fbe457
# ╠═e1d54935-4305-42cf-98c6-ccee9b0813ea
# ╟─685221ea-f268-4ddc-937f-e7620d065c28
# ╠═6796ae76-bc2d-4895-ba0a-5e2c23c50dfb
# ╟─62080cc2-3cab-4a22-9b2e-2bff640a17a4
# ╠═156272d7-56c4-4ac4-bf3e-7882f4edc144
# ╠═00b90e6d-732f-41c9-a603-cabe9740e329
# ╠═37a016d8-8384-41c9-abdd-23e88b1f988d
# ╠═7df5d669-d3a2-4a66-83c3-f8618e39bec6
# ╠═0e7bbf13-9187-41ea-8b46-294b93be4c6d
