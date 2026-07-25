### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# ╔═╡ 34a06b3b-799b-48c5-bd08-1e57151f51ec
let
    docs_dir = dirname(dirname(dirname(dirname(@__DIR__))))
    using Pkg: Pkg
    Pkg.activate(docs_dir)
    Pkg.instantiate()
end;

# ╔═╡ d63b37f0-9642-4c38-ac01-9ffe48d50441
using EpiAware

# ╔═╡ 74642759-35a5-4957-9f2b-544712866410
using Turing, DynamicPPL #Underlying Turing ecosystem packages to interact with models

# ╔═╡ 0c5f413e-d043-448d-8665-f0f6f705d70f
using Distributions, Statistics #Statistics packages

# ╔═╡ b1e2a759-a52b-4ee5-8db4-cfe848878c92
using CSV, DataFramesMeta #Data wrangling

# ╔═╡ 9eb03a0b-c6ca-4e23-8109-fb68f87d7fdf
using CairoMakie, PairPlots, TimeSeries #Plotting backend

# ╔═╡ 97b5374e-7653-4b3b-98eb-d8f73aa30580
using ReverseDiff #Automatic differentiation backend

# ╔═╡ 1642dbda-4915-4e29-beff-bca592f3ec8d
begin #Date utility and set Random seed
    using Dates
    using Random
    Random.seed!(1)
end

# ╔═╡ 8a8d5682-2f89-443b-baf0-d4d3b134d311
md"
# Example: Early COVID-19 case data in South Korea

In this example we use `EpiAware` functionality to largely recreate an epidemiological model presented in [On the derivation of the renewal equation from an age-dependent branching process: an epidemic modelling perspective, _Mishra et al_ (2020)](https://arxiv.org/abs/2006.16487). _Mishra et al_ consider test-confirmed cases of COVID-19 in South Korea between January to July 2020. The components of the epidemilogical model they consider are:

- The time varying reproductive number modelled as an [AR(2) process](https://en.wikipedia.org/wiki/Autoregressive_model) on the log-scale $\log R_t \sim \text{AR(2)}$.
- The latent infection ($I_t$) generating process is a renewal model (note that we leave out external infections in this note):
```math
I_t = R_t \sum_{s\geq 1} I_{t-s} g_s.
```
- The discrete generation interval $g_t$ is a daily discretisation of the probability mass function of an estimated serial interval distribution for SARS-CoV-2:
```math
G \sim \text{Gamma}(6.5,0.62).
```
- Observed cases $C_t$ are distributed around latent infections with negative binomial errors:
```math
C_t \sim \text{NegBin}(\text{mean} = I_t,~ \text{overdispersion} = \phi).
```

In the examples below we are going to largely recreate the _Mishra et al_ model, whilst emphasing that each component of the overall epidemiological model is, itself, a stand alone model that can be sampled from.
"

# ╔═╡ 27d73202-a93e-4471-ab50-d59345304a0b
md"
## Dependencies for this notebook
Now we want to import these dependencies into scope. If evaluating these code lines/blocks in REPL, then the REPL will offer to install any missing dependencies. Alternatively, you can add them to your active environment using `Pkg.add`.
"

# ╔═╡ 1d3b9541-80ad-41b5-a5ed-a947f5c0731b
md"
## Load early SARS-2 case data for South Korea
First, we make sure that we have the data we want to analysis in scope by downloading it for where we have saved a copy in the `EpiAware` repository.

NB: The case data is curated by the [`covidregionaldata`](https://github.com/epiforecasts/covidregionaldata) package. We accessed the South Korean case data using a short [R script](https://github.com/CDCgov/Rt-without-renewal/blob/main/EpiAware/docs/src/showcase/replications/mishra-2020/get_data.R). It is possible to interface directly from a Julia session using the `RCall.jl` package, but we do not do this in this notebook to reduce the number of underlying dependencies required to run this notebook.
"

# ╔═╡ 4e5e0e24-8c55-4cb4-be3a-d28198f81a69
url = "https://raw.githubusercontent.com/CDCgov/Rt-without-renewal/main/EpiAware/docs/src/showcase/replications/mishra-2020/south_korea_data.csv2"

# ╔═╡ a59d977c-0178-11ef-0063-83e30e0cf9f0
data = CSV.read(download(url), DataFrame)

# ╔═╡ 104f4d16-7433-4a2d-89e7-288a9b223563
md"
## Time-varying reproduction number as an `AbstractLatentModel` type

`EpiAware` exposes a `AbstractLatentModel` abstract type; the purpose of which is to group stochastic processes which can be interpreted as generating time-varying parameters/quantities of interest which we call latent process models.

In the _Mishra et al_ model the log-time varying reproductive number $Z_t$ is assumed to evolve as an auto-regressive process, AR(2):

```math
\begin{align}
R_t &= \exp Z_t, \\
Z_t &= \rho_1 Z_{t-1} + \rho_2 Z_{t-2} + \epsilon_t, \\
\epsilon_t &\sim \text{Normal}(0, \sigma^*).
\end{align}
```
Where $\rho_1,\rho_2$, which are the parameters of AR process, and $\epsilon_t$ is a white noise process with standard deviation $\sigma^*$.
"

# ╔═╡ d753b21f-cf8e-4a25-bab3-46c811c80a78
md"
In `EpiAware` we determine the behaviour of a latent process by choosing a concrete subtype (i.e. a struct) of `AbstractLatentModel` which has fields that set the priors of the various parameters required for the latent process.

The AR process has the struct `AR <: AbstractLatentModel`. The user can supply the priors for $\rho_1,\rho_2$ in the field `damp_priors`, for $\sigma^*$ in the field `std_prior`, and the initial values $Z_1, Z_2$ in the field `init_priors`.
"

# ╔═╡ d201c82b-8efd-41e2-96d7-4f5e0c67088c
md"
We choose priors based on _Mishra et al_ using the `Distributions.jl` interface to probability distributions. Note that we condition the AR parameters onto $[0,1]$, as in _Mishra et al_, using the `truncated` function.

In _Mishra et al_ the standard deviation of the _stationary distribution_ of $Z_t$ which has a standard normal distribution conditioned to be positive $\sigma \sim \mathcal{N}^+(0,1)$. The value $σ^*$ was determined from a nonlinear function of sampled $\sigma, ~\rho_1, ~\rho_2$ values. Since, _Mishra et al_ give sharply informative priors for $\rho_1,~\rho_2$ (see below) we simplify by calculating $\sigma^*$ at the prior mode of $\rho_1,~\rho_2$. This results in a $\sigma^* \sim \mathcal{N}^+(0, 0.5)$ prior.
"

# ╔═╡ c88bbbd6-0101-4c04-97c9-c5887ef23999
ar = AR(
    damp_priors = [truncated(Normal(0.1, 0.05), 0, 1),
        truncated(Normal(0.8, 0.05), 0, 1)],
    init_priors = [Normal(-1.0, 0.1), Normal(-1.0, 0.5)],
    ϵ_t = HierarchicalNormal(std_prior = HalfNormal(0.5))
)

# ╔═╡ 31ee2757-0409-45df-b193-60c552797a3d
md"
### `Turing` model interface to the AR process

As mentioned above, we can use this instance of the `AR` latent model to construct a [`Turing`](https://turinglang.org/) model object which implements the probabilistic behaviour determined by `ar`. We do this with the constructor function exposed by `EpiAware`: `generate_latent` which combines an `AbstractLatentModel` substype struct with the number of time steps for which we want to generate the latent process.

As a refresher, we remind that the `Turing.Model` object has the following properties:

- The model object parameters are sampleable using `rand`; that is we can generate parameters from the specified priors e.g. `θ = rand(mdl)`.
- The model object is generative as a callable; that is we can sample instances of $Z_t$ e.g. `Z_t = mdl()`.
- The model object can construct new model objects by conditioning parameters using the [`DynamicPPL.jl`](https://turinglang.org/DynamicPPL.jl/stable/) syntax, e.g. `conditional_mdl = mdl | (σ_AR = 1.0, )`.

As a concrete example we create a model object for the AR(2) process we specified above for 50 time steps:
"

# ╔═╡ 2bf22866-b785-4ee0-953d-ac990a197561
ar_mdl = generate_latent(ar, 50)

# ╔═╡ 25e25125-8587-4451-8600-9b55a04dbcd9
md"
Ultimately, this will only be one component of the full epidemiological model. However, it is useful to visualise its probabilistic behaviour for model diagnostic and prior predictive checking.

We can spaghetti plot generative samples from the AR(2) process with the priors specified above.
"

# ╔═╡ fbe117b7-a0b8-4604-a5dd-e71a0a1a4fc3
plt_ar_sample = let
    n_samples = 100
    ar_mdl_samples = mapreduce(hcat, 1:n_samples) do _
        ar_mdl() .|> exp #Sample Z_t trajectories for the model
    end

    fig = Figure()
    ax = Axis(fig[1, 1];
        yscale = log10,
        ylabel = "Time varying Rₜ",
        title = "$(n_samples) draws from the prior Rₜ model"
    )
    for col in eachcol(ar_mdl_samples)
        lines!(ax, col, color = (:grey, 0.1))
    end
    fig
end

# ╔═╡ 9f84dec1-70f1-442e-8bef-a9494921549e
md"
This suggests that _a priori_ we believe that there is a few percent chance of achieving very high $R_t$ values, i.e. $R_t \sim 10-1000$ is not excluded by our priors.
"

# ╔═╡ 6a9e871f-a2fa-4e41-af89-8b0b3c3b5b4b
md"
## The Renewal model as an `AbstractEpiModel` type

The abstract type for models that generate infections exposed by `EpiAware` is called `AbstractEpiModel`. As with latent models different concrete subtypes of `AbstractEpiModel` define different classes of infection generating process. In this case we want to implement a renewal model.

The `Renewal <: AbstractEpiModel` type of struct needs two fields:

- Data about the generation interval of the infectious disease so it can construct $g_t$.
- A prior for the initial numbers of infected.

In _Mishra et al_ they use an estimate of the serial interval of SARS-CoV-2 as an estimate of the generation interval.

"

# ╔═╡ c1fc1929-0624-45c0-9a89-86c8479b2675
truth_GI = Gamma(6.5, 0.62)

# ╔═╡ ab0c6bec-1ab7-43d1-aa59-11225dea79eb
md"
This is a representation of the generation interval distribution as continuous whereas the infection process will be formulated in discrete daily time steps. By default, `EpiAware` performs [double interval censoring](https://www.medrxiv.org/content/10.1101/2024.01.12.24301247v1) to convert our continuous estimate of the generation interval into a discretized version $g_t$, whilst also applying left truncation such that $g_0 = 0$ and normalising $\sum_t g_t = 1.$

The constructor for converting a continuous estimate of the generation interval distribution into a usable discrete time estimate is `EpiData`.
"

# ╔═╡ 99c9ba2c-20a5-4c7f-94d2-272d6c9d5904
model_data = EpiData(gen_distribution = truth_GI)

# ╔═╡ 3c9849a8-1361-49e7-8b4e-cc4035b3fc70
md"
We can compare the discretized generation interval with the continuous estimate, which in this example is the serial interval estimate.
"

# ╔═╡ 71d08f7e-c409-4fbe-b154-b21d09010683
let
    fig = Figure()
    ax = Axis(fig[1, 1];
        xticks = 0:14,
        xlabel = "Days",
        title = "Continuous and discrete generation intervals"
    )
    barplot!(ax, model_data.gen_int;
        label = "Discretized next gen pmf"
    )
    lines!(truth_GI;
        label = "Continuous serial interval",
        color = :green
    )
    axislegend(ax)
    fig
end

# ╔═╡ 4a2b5cf1-623c-4fe7-8365-49fb7972af5a
md"
The user also needs to specify a prior for the log incidence at time zero, $\log I_0$. The initial _history_ of latent infections $I_{-1}, I_{-2},\dots$ is constructed as
```math
I_t = e^{rt} I_0,\qquad t = 0, -1, -2,...
```
Where the exponential growth rate $r$ is determined by the initial reproductive number $R_1$ via the solution to the implicit equation,
```math
R_1 = 1 \Big{/} \sum_{t\geq 1} e^{-rt} g_t
```
"

# ╔═╡ 9e49d451-946b-430b-bcdb-1ef4bba55a4b
log_I0_prior = Normal(log(1.0), 1.0)

# ╔═╡ 8487835e-d430-4300-bd7c-e33f5769ee32
epi = Renewal(model_data; initialisation_prior = log_I0_prior)

# ╔═╡ 2119319f-a2ef-4c96-82c4-3c7eaf40d2e0
md"
_NB: We don't implement a background infection rate in this model._
"

# ╔═╡ 51b5d5b6-3ad3-4967-ad1d-b1caee201fcb
md"
### `Turing` model interface to `Renewal` process

As mentioned above, we can use this instance of the `Renewal` latent infection model to construct a `Turing` `Model` which implements the probabilistic behaviour determined by `epi` using the constructor function `generate_latent_infs` which combines `epi` with a provided $\log R_t$ time series.

Here we choose an example where $R_t$ decreases from $R_t = 3$ to $R_t = 0.5$ over the course of 50 days.
"

# ╔═╡ 9e564a6e-f521-41e8-8604-6a9d73af9ba7
R_t_fixed = [0.5 + 2.5 / (1 + exp(t - 15)) for t in 1:50]

# ╔═╡ 72bdb47d-4967-4f20-9ae5-01f82e7b32c5
latent_inf_mdl = generate_latent_infs(epi, log.(R_t_fixed))

# ╔═╡ 7a6d4b14-58d3-40c1-81f2-713c830f875f
plt_epi = let
    n_samples = 100
    #Sample unconditionally the underlying parameters of the model
    epi_mdl_samples = mapreduce(hcat, 1:n_samples) do _
        latent_inf_mdl()
    end
    fig = Figure()
    ax1 = Axis(fig[1, 1];
        title = "$(n_samples) draws from renewal model with chosen Rt",
        ylabel = "Latent infections"
    )
    ax2 = Axis(fig[2, 1];
        ylabel = "Rt"
    )
    for col in eachcol(epi_mdl_samples)
        lines!(ax1, col;
            color = (:grey, 0.1)
        )
    end
    lines!(ax2, R_t_fixed;
        linewidth = 2
    )
    fig
end

# ╔═╡ c8ef8a60-d087-4ae9-ae92-abeea5afc7ae
md"
### Negative Binomial Observations as an `ObservationModel` type

In _Mishra et al_ latent infections were assumed to occur on their observation day with negative binomial errors, this motivates using the serial interval (the time between onset of symptoms of a primary and secondary case) rather than generation interval distribution (the time between infection time of a primary and secondary case).

Observation models are set in `EpiAware` as concrete subtypes of an `ObservationModel`. The Negative binomial error model without observation delays is set with a `NegativeBinomialError` struct. In _Mishra et al_ the overdispersion parameter $\phi$ sets the relationship between the mean and variance of the negative binomial errors,
```math
\text{var} = \text{mean} + {\text{mean}^2 \over \phi}.
```
In `EpiAware`, we default to a prior on $\sqrt{1/\phi}$ because this quantity is approximately the coefficient of variation of the observation noise and, therefore, is easier to reason on _a priori_ beliefs. We call this quantity the cluster factor.

A prior for $\phi$ was not specified in _Mishra et al_, we select one below but we will condition a value in analysis below.
"

# ╔═╡ 714908a1-dc85-476f-a99f-ec5c95a78b60
obs = NegativeBinomialError(cluster_factor_prior = HalfNormal(0.1))

# ╔═╡ dacb8094-89a4-404a-8243-525c0dbfa482
md"
### `Turing` model interface to the `NegativeBinomialError` model

We can construct a `NegativeBinomialError` model implementation as a `Turing` `Model` using the `EpiAware` `generate_observations` functions.

`Turing` uses `missing` arguments to indicate variables that are to be sampled. We use this to observe a forward model that samples observations, conditional on an underlying expected observation time series.
"

# ╔═╡ d45f34e2-64f0-4828-ae0d-7b4cb3a3287d
md"
First, we set an artificial expected cases curve.
"

# ╔═╡ 2e0e8bf3-f34b-44bc-aa2d-046e1db6ee2d
expected_cases = [1000 * exp(-(t - 15)^2 / (2 * 4)) for t in 1:30]

# ╔═╡ 55c639f6-b47b-47cf-a3d6-547e793c72bc
obs_mdl = generate_observations(obs, missing, expected_cases)

# ╔═╡ c3a62dda-e054-4c8c-b1b8-ba1b5c4447b3
plt_obs = let
    n_samples = 100
    obs_mdl_samples = mapreduce(hcat, 1:n_samples) do _
        θ = obs_mdl() #Sample unconditionally the underlying parameters of the model
    end
    fig = Figure()
    ax = Axis(fig[1, 1];
        title = "$(n_samples) draws from neg. bin. obs model",
        ylabel = "Observed cases"
    )
    for col in eachcol(obs_mdl_samples)
        scatter!(ax, col;
            color = (:grey, 0.2)
        )
    end
    lines!(ax, expected_cases;
        color = :red,
        linewidth = 3,
        label = "Expected cases"
    )
    axislegend(ax)
    fig
end

# ╔═╡ a06065e1-0e20-4cf8-8d5a-2d588da20bee
md"
## Composing models into an `EpiProblem`

_Mishra et al_ follows a common pattern of having an infection generation process driven by a latent process with an observation model that links the infection process to a discrete valued time series of incidence data.

In `EpiAware` we provide an `EpiProblem` constructor for this common epidemiological model pattern.

The constructor for an `EpiProblem` requires:
- An `epi_model`.
- A `latent_model`.
- An `observation_model`.
- A `tspan`.

The `tspan` set the range of the time index for the models.
"

# ╔═╡ eaad5f46-e928-47c2-90ec-2cca3871c75d
epi_prob = EpiProblem(epi_model = epi,
    latent_model = ar,
    observation_model = obs,
    tspan = (45, 80))

# ╔═╡ 2678f062-36ec-40a3-bd85-7b57a08fd809
md"
## Inference Methods

We make inferences on the unobserved quantities, such as $R_t$ by sampling from the model conditioned on the observed data. We generate the posterior samples using the No U-Turns (NUTS) sampler.

To make NUTS more robust we provide `manypathfinder`, which is built on pathfinder variational inference from [Pathfinder.jl](https://mlcolab.github.io/Pathfinder.jl/stable/). `manypathfinder` runs `nruns` pathfinder processes on the inference problem and returns the pathfinder run with maximum estimated ELBO.

The composition of doing variational inference as a pre-sampler step which gets passed to NUTS initialisation is defined using the `EpiMethod` struct, where a sequence of pre-sampler steps can be be defined.

`EpiMethod` also allows the specification of NUTS parameters, such as type of automatic differentiation, type of parallelism and number of parallel chains to sample.
"

# ╔═╡ 58f6f0bd-f1e4-459f-84b0-8d89831c8d7b
num_threads = min(10, Threads.nthreads())

# ╔═╡ 88b43e23-1e06-4716-b284-76e8afc6171b
inference_method = EpiMethod(
    pre_sampler_steps = [ManyPathfinder(nruns = 4, maxiters = 100)],
    sampler = NUTSampler(
        adtype = AutoReverseDiff(compile = true),
        ndraws = 2000,
        nchains = num_threads,
        mcmc_parallel = MCMCThreads())
)

# ╔═╡ 92333a96-5c9b-46e1-9a8f-f1890831066b
md"
## Inference and analysis
We supply the data as a `NamedTuple` with the `y_t` field containing the observed data, shortened to fit the chosen `tspan` of `epi_prob`.
"

# ╔═╡ c7140b20-e030-4dc4-97bc-0efc0ff59631
south_korea_data = (y_t = data.cases_new[epi_prob.tspan[1]:epi_prob.tspan[2]],
    dates = data.date[epi_prob.tspan[1]:epi_prob.tspan[2]])

# ╔═╡ f6c168e5-6933-4bd7-bf71-35a37551d040
md"
In the epidemiological model it is hard to identify between the AR parameters such as the standard deviation of the AR process and the cluster factor of the negative binomial observation model. The reason for this identifiability problem is that the model assumes no delay between infection and observation. Therefore, on any day the data could be explained by $R_t$ changing _or_ observation noise and its not easy to disentangle greater volatility in $R_t$ from higher noise in the observations.

In models with latent delays, changes in $R_t$ impact the observed cases over several days which means that it easier to disentangle trend effects from observation-to-observation fluctuations.

To counter act this problem we condition the model on a fixed cluster factor value.
"

# ╔═╡ 9cbacc02-9c76-41eb-9c75-fec667b60829
fixed_cluster_factor = 0.25

# ╔═╡ b2074ff2-562d-44e6-b4b4-7a77c0f85c16
md"
`EpiAware` has the `generate_epiaware` function which joins an `EpiProblem` object with the data to produce as `Turing` model. This `Turing` model composes the three unit `Turing` models defined above: the Renewal infection generating process, the AR latent process for $\log R_t$, and the negative binomial observation model. Therefore, [we can condition on variables as with any other `Turing` model](https://turinglang.org/DynamicPPL.jl/stable/api/#Condition-and-decondition).
"

# ╔═╡ fe47748e-151b-4819-987a-07cf35e6cc80
mdl = generate_epiaware(epi_prob, south_korea_data) |
      (var"obs.cluster_factor" = fixed_cluster_factor,)

# ╔═╡ 9970adfd-ee88-4598-87a3-ffde5297031c
md"
### Sampling with `apply_method`

The `apply_method` function combines the elements above:
- An `EpiProblem` object or `Turing` model.
- An `EpiMethod` object.
- Data to condition the model upon.

And returns a collection of results:
- The epidemiological model as a `Turing` `Model`.
- Samples from MCMC.
- Generated quantities of the model.
"

# ╔═╡ 3d10379a-3bb4-474c-ad20-de767b82d52b
inference_results = apply_method(mdl,
    inference_method,
    south_korea_data
)

# ╔═╡ 5e6f505b-49fe-4ff4-ac2e-f6adcd445569
md"
### Results and Predictive plotting

To assess the quality of the inference visually we can plot predictive quantiles for generated case data from the version of the model _which hasn't conditioned on case data_ using posterior parameters inferred from the version conditioned on observed data. For this purpose, we add a `generated_quantiles` utility function. This kind of visualisation is known as _posterior predictive checking_, and is a useful diagnostic tool for Bayesian inference (see [here](http://www.stat.columbia.edu/~gelman/book/BDA3.pdf)).

We also plot the inferred $R_t$ estimates from the model. We find that the `EpiAware` model recovers the main finding in _Mishra et al_; that the $R_t$ in South Korea peaked at a very high value ($R_t \sim 10$ at peak) before rapidly dropping below 1 in early March 2020.

Note that, in reality, the peak $R_t$ found here and in _Mishra et al_ is unrealistically high, this might be due to a combination of:
- A mis-estimated generation interval/serial interval distribution.
- An ascertainment rate that was, in reality, changing over time.

In a future note, we'll demonstrate having a time-varying ascertainment rate.
"

# ╔═╡ aa1d8b72-a3d2-4844-bb43-406b98b2648f
function generated_quantiles(gens, quantity, qs; transformation = x -> x)
    mapreduce(hcat, gens) do gen #loop over sampled generated quantities
        getfield(gen, quantity) |> transformation
    end |> mat -> mapreduce(hcat, qs) do q #Loop over matrix row to condense into qs
        map(eachrow(mat)) do row
            if any(ismissing, row)
                return missing
            else
                quantile(row, q)
            end
        end
    end
end

# ╔═╡ 8b557bf1-f3dd-4f42-a250-ce965412eb32
let
    C = south_korea_data.y_t
    D = south_korea_data.dates

    #Case unconditional model for posterior predictive sampling
    mdl_unconditional = generate_epiaware(epi_prob,
        (y_t = fill(missing, length(C)),)
    ) | (var"obs.cluster_factor" = fixed_cluster_factor,)
    posterior_gens = generated_quantities(mdl_unconditional, inference_results.samples)

    #plotting quantiles
    qs = [0.025, 0.25, 0.5, 0.75, 0.975]

    #Prediction quantiles
    predicted_y_t = generated_quantiles(posterior_gens, :generated_y_t, qs)
    predicted_R_t = generated_quantiles(
        posterior_gens, :Z_t, qs; transformation = x -> exp.(x))

    ts = D .|> d -> d - minimum(D) .|> d -> d.value + 1
    t_ticks = string.(D)
    fig = Figure()
    ax1 = Axis(fig[1, 1];
        ylabel = "Daily cases",
        xticks = (ts[1:14:end], t_ticks[1:14:end]),
        title = "Posterior predictive: Cases"
    )
    ax2 = Axis(fig[2, 1];
        yscale = log10,
        title = "Prediction: Reproduction number",
        xticks = (ts[1:14:end], t_ticks[1:14:end])
    )
    linkxaxes!(ax1, ax2)

    lines!(ax1, ts, predicted_y_t[:, 3];
        color = :purple,
        linewidth = 2,
        label = "Post. median"
    )
    band!(ax1, 1:size(predicted_y_t, 1), predicted_y_t[:, 2], predicted_y_t[:, 4];
        color = (:purple, 0.4),
        label = "50%"
    )
    band!(ax1, 1:size(predicted_y_t, 1), predicted_y_t[:, 1], predicted_y_t[:, 5];
        color = (:purple, 0.2),
        label = "95%"
    )
    scatter!(ax1, C;
        color = :black,
        label = "Actual cases")
    axislegend(ax1)

    lines!(ax2, ts, predicted_R_t[:, 3];
        color = :green,
        linewidth = 2,
        label = "Post. median"
    )
    band!(ax2, 1:size(predicted_R_t, 1), predicted_R_t[:, 2], predicted_R_t[:, 4];
        color = (:green, 0.4),
        label = "50%"
    )
    band!(ax2, 1:size(predicted_R_t, 1), predicted_R_t[:, 1], predicted_R_t[:, 5];
        color = (:green, 0.2),
        label = "95%"
    )
    axislegend(ax2)

    fig
end

# ╔═╡ c05ed977-7a89-4ac8-97be-7078d69fce9f
md"
### Parameter inference

We can interrogate the sampled chains directly from the `samples` field of the `inference_results` object.
"

# ╔═╡ ff21c9ec-1581-405f-8db1-0f522b5bc296
let
    sub_chn = inference_results.samples[inference_results.samples.name_map.parameters[[1:5;
                                                                                       end]]]
    fig = pairplot(sub_chn)
    lines!(fig[1, 1], ar.init_prior.v[1], label = "Prior")
    lines!(fig[2, 2], ar.init_prior.v[2], label = "Prior")
    lines!(fig[3, 3], ar.damp_prior.v[1], label = "Prior")
    lines!(fig[4, 4], ar.damp_prior.v[2], label = "Prior")
    lines!(fig[5, 5], ar.ϵ_t.std_prior, label = "Prior")
    lines!(fig[6, 6], epi.initialisation_prior, label = "Prior")

    fig
end

# ╔═╡ Cell order:
# ╟─8a8d5682-2f89-443b-baf0-d4d3b134d311
# ╟─34a06b3b-799b-48c5-bd08-1e57151f51ec
# ╟─27d73202-a93e-4471-ab50-d59345304a0b
# ╠═d63b37f0-9642-4c38-ac01-9ffe48d50441
# ╠═74642759-35a5-4957-9f2b-544712866410
# ╠═0c5f413e-d043-448d-8665-f0f6f705d70f
# ╠═b1e2a759-a52b-4ee5-8db4-cfe848878c92
# ╠═9eb03a0b-c6ca-4e23-8109-fb68f87d7fdf
# ╠═97b5374e-7653-4b3b-98eb-d8f73aa30580
# ╠═1642dbda-4915-4e29-beff-bca592f3ec8d
# ╟─1d3b9541-80ad-41b5-a5ed-a947f5c0731b
# ╠═4e5e0e24-8c55-4cb4-be3a-d28198f81a69
# ╠═a59d977c-0178-11ef-0063-83e30e0cf9f0
# ╟─104f4d16-7433-4a2d-89e7-288a9b223563
# ╟─d753b21f-cf8e-4a25-bab3-46c811c80a78
# ╟─d201c82b-8efd-41e2-96d7-4f5e0c67088c
# ╠═c88bbbd6-0101-4c04-97c9-c5887ef23999
# ╟─31ee2757-0409-45df-b193-60c552797a3d
# ╠═2bf22866-b785-4ee0-953d-ac990a197561
# ╟─25e25125-8587-4451-8600-9b55a04dbcd9
# ╠═fbe117b7-a0b8-4604-a5dd-e71a0a1a4fc3
# ╟─9f84dec1-70f1-442e-8bef-a9494921549e
# ╟─6a9e871f-a2fa-4e41-af89-8b0b3c3b5b4b
# ╠═c1fc1929-0624-45c0-9a89-86c8479b2675
# ╟─ab0c6bec-1ab7-43d1-aa59-11225dea79eb
# ╠═99c9ba2c-20a5-4c7f-94d2-272d6c9d5904
# ╟─3c9849a8-1361-49e7-8b4e-cc4035b3fc70
# ╠═71d08f7e-c409-4fbe-b154-b21d09010683
# ╟─4a2b5cf1-623c-4fe7-8365-49fb7972af5a
# ╠═9e49d451-946b-430b-bcdb-1ef4bba55a4b
# ╠═8487835e-d430-4300-bd7c-e33f5769ee32
# ╟─2119319f-a2ef-4c96-82c4-3c7eaf40d2e0
# ╟─51b5d5b6-3ad3-4967-ad1d-b1caee201fcb
# ╠═9e564a6e-f521-41e8-8604-6a9d73af9ba7
# ╠═72bdb47d-4967-4f20-9ae5-01f82e7b32c5
# ╠═7a6d4b14-58d3-40c1-81f2-713c830f875f
# ╟─c8ef8a60-d087-4ae9-ae92-abeea5afc7ae
# ╠═714908a1-dc85-476f-a99f-ec5c95a78b60
# ╟─dacb8094-89a4-404a-8243-525c0dbfa482
# ╟─d45f34e2-64f0-4828-ae0d-7b4cb3a3287d
# ╠═2e0e8bf3-f34b-44bc-aa2d-046e1db6ee2d
# ╠═55c639f6-b47b-47cf-a3d6-547e793c72bc
# ╠═c3a62dda-e054-4c8c-b1b8-ba1b5c4447b3
# ╟─a06065e1-0e20-4cf8-8d5a-2d588da20bee
# ╠═eaad5f46-e928-47c2-90ec-2cca3871c75d
# ╟─2678f062-36ec-40a3-bd85-7b57a08fd809
# ╠═58f6f0bd-f1e4-459f-84b0-8d89831c8d7b
# ╠═88b43e23-1e06-4716-b284-76e8afc6171b
# ╟─92333a96-5c9b-46e1-9a8f-f1890831066b
# ╠═c7140b20-e030-4dc4-97bc-0efc0ff59631
# ╟─f6c168e5-6933-4bd7-bf71-35a37551d040
# ╠═9cbacc02-9c76-41eb-9c75-fec667b60829
# ╟─b2074ff2-562d-44e6-b4b4-7a77c0f85c16
# ╠═fe47748e-151b-4819-987a-07cf35e6cc80
# ╟─9970adfd-ee88-4598-87a3-ffde5297031c
# ╠═3d10379a-3bb4-474c-ad20-de767b82d52b
# ╟─5e6f505b-49fe-4ff4-ac2e-f6adcd445569
# ╠═aa1d8b72-a3d2-4844-bb43-406b98b2648f
# ╠═8b557bf1-f3dd-4f42-a250-ce965412eb32
# ╟─c05ed977-7a89-4ac8-97be-7078d69fce9f
# ╠═ff21c9ec-1581-405f-8db1-0f522b5bc296
