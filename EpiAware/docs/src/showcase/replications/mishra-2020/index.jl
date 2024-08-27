### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# ╔═╡ e46a2fc8-f31e-4e11-9bcc-17836a41b08d
using Pkg; Pkg.activate(temp=true)

# ╔═╡ dae655f7-9f4e-47b0-847d-6f885ef5c2a1
Pkg.add(url="https://github.com/CDCgov/Rt-without-renewal", subdir="EpiAware")

# ╔═╡ 93e1c8a9-05ce-42ef-b758-cdd8cd8e9086
Pkg.add(["Turing", "DynamicPPL", "Distributions", "Statistics", "CSV", "DataFramesMeta", "StatsPlots", "ReverseDiff"])

# ╔═╡ d63b37f0-9642-4c38-ac01-9ffe48d50441
using EpiAware

# ╔═╡ 74642759-35a5-4957-9f2b-544712866410
using Turing, DynamicPPL #Underlying Turing ecosystem packages to interact with models

# ╔═╡ 0c5f413e-d043-448d-8665-f0f6f705d70f
using Distributions, Statistics #Statistics packages

# ╔═╡ b1e2a759-a52b-4ee5-8db4-cfe848878c92
using CSV, DataFramesMeta #Data wrangling

# ╔═╡ 9eb03a0b-c6ca-4e23-8109-fb68f87d7fdf
begin #Plotting backend
    using StatsPlots
    using StatsPlots.PlotMeasures
end

# ╔═╡ 97b5374e-7653-4b3b-98eb-d8f73aa30580
using ReverseDiff #Automatic differentiation backend

# ╔═╡ 1642dbda-4915-4e29-beff-bca592f3ec8d
begin #Date utility and set Random seed
    using Dates
    using Random
    Random.seed!(1)
end

# ╔═╡ 9161ab72-5c39-4a67-9762-e19f1c54c7fd
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
As well as the `EpiAware` package we also want to import extra dependencies for interacting with `EpiAware` models, data wrangling and visualisation. 

To make this notebook as clean as possible, we create a _temporary_ environment for this notebook using `Pkg.activate(temp=true)`. We then use the `Pkg.add` function to install our desired dependencies available; because the notebook environment is temporary the installed dependencies do not persist once the notebook runtime is ended.
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

# ╔═╡ d201c82b-8efd-41e2-96d7-4f5e0c67088c
md"
In `EpiAware` we determine the behaviour of a latent process by choosing a concrete subtype (i.e. a struct) of `AbstractLatentModel` which has fields that set the priors of the various parameters required for the latent process.

The AR process has the struct `AR <: AbstractLatentModel`. The user can supply the priors for $\rho_1,\rho_2$ in the field `damp_priors`, for $\sigma^*$ in the field `std_prior`, and the initial values $Z_1, Z_2$ in the field `init_priors`.
"

# ╔═╡ eb1ea027-684e-46a9-88fa-b4b8239ed906
md"
We choose priors based on _Mishra et al_ using the `Distributions.jl` interface to probability distributions. Note that we condition the AR parameters onto $[0,1]$, as in _Mishra et al_, using the `truncated` function.

In _Mishra et al_ the standard deviation of the _stationary distribution_ of $Z_t$ which has a standard normal distribution conditioned to be positive $\sigma \sim \mathcal{N}^+(0,1)$. The value $σ^*$ was determined from a nonlinear function of sampled $\sigma, ~\rho_1, ~\rho_2$ values. Since, _Mishra et al_ give sharply informative priors for $\rho_1,~\rho_2$ (see below) we simplify by calculating $\sigma^*$ at the prior mode of $\rho_1,~\rho_2$. This results in a $\sigma^* \sim \mathcal{N}^+(0, 0.5)$ prior.
"

# ╔═╡ c88bbbd6-0101-4c04-97c9-c5887ef23999
ar = AR(
    damp_priors = [truncated(Normal(0.8, 0.05), 0, 1),
        truncated(Normal(0.1, 0.05), 0, 1)],
    std_prior = HalfNormal(0.5),
    init_priors = [Normal(-1.0, 0.1), Normal(-1.0, 0.5)]
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
       ar_mdl() #Sample Z_t trajectories for the model
    end

    plot(ar_mdl_samples .|> exp, #R_t = exp(Z_t)
        lab = "",
        c = :grey,
        alpha = 0.25,
        title = "$(n_samples) draws from the prior Rₜ model",
        ylabel = "Time varying Rₜ",
		yticks = [10.0^n for n = -4:4],
	yscale = :log10)
end

# ╔═╡ 9f84dec1-70f1-442e-8bef-a9494921549e
md"
This suggests that _a priori_ we believe that there is a few percent chance of achieving very high $R_t$ values, i.e. $R_t \sim 10-1000$ is not excluded by our priors.

To demonstrate alternatives we can sample from this model with some parameters conditioned, for example with $Z_1 = Z_2 = 0$ and $\sigma^* = 0.1$.
"

# ╔═╡ 51a82a62-2c59-43c9-8562-69d15a7edfdd
cond_ar_mdl = ar_mdl | (ar_init = [0., 0.], σ_AR = 0.1)

# ╔═╡ d3938381-01b7-40c6-b369-a456ff6dba72
let
    n_samples = 100
    ar_mdl_samples = mapreduce(hcat, 1:n_samples) do _
        cond_ar_mdl()
    end

    plot(ar_mdl_samples .|> exp, #R_t = exp(Z_t)
        lab = "",
        c = :grey,
        alpha = 0.25,
        title = "$(n_samples) draws from the prior Rₜ model",
        ylabel = "Time varying Rₜ",)
end

# ╔═╡ 141543f8-681c-4804-b4c9-e094b3c04fda
md"
With these fixed parameters, we see that the _a priori_ model for $R_t$ assigns much higher probability to values around $1$. Whether that is appropriate or not depends on the applied modelling question.
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

# ╔═╡ 7fdac621-4605-4ea8-88c7-7c3c4df5734f
md"
However, this is a continuous distribution whereas we are using a discrete-time model.

To construct an `EpiModel` we need to supply some fixed data for the model contained in an `EpiData` object. The `EpiData` constructor performs double interval censoring to convert our _continuous_ estimate of the generation interval into a discretized version $g_t$. We also implement right truncation, the default is rounding the 99th percentile of the generation interval distribution, but this can be controlled using the keyword `D_gen`.
"

# ╔═╡ 99c9ba2c-20a5-4c7f-94d2-272d6c9d5904
model_data = EpiData(gen_distribution = truth_GI)

# ╔═╡ 71d08f7e-c409-4fbe-b154-b21d09010683
let
    bar(model_data.gen_int,
        fillalpha = 0.5,
        lw = 0,
        lab = "Discretized next gen pmf",
        xticks = 0:14,
        xlabel = "Days",
        title = "Continuous and discrete generation intervals")
    plot!(truth_GI, lab = "Continuous serial interval")
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
epi = Renewal(model_data, log_I0_prior)

# ╔═╡ 2119319f-a2ef-4c96-82c4-3c7eaf40d2e0
md"
_NB: We don't implement a background infection rate in this model._
"

# ╔═╡ 51b5d5b6-3ad3-4967-ad1d-b1caee201fcb
md"
##### `Turing` model interface

As mentioned above, we can use this instance of the `Renewal` latent infection model to construct a `Turing` `Model` which implements the probabilistic behaviour determined by `epi`.

We do this with the constructor function `generate_latent_infs` which combines `epi` with a provided $\log R_t$ time series.

Here we choose an example where $R_t$ decreases from $R_t = 3$ to $R_t = 0.5$ over the course of 30 days.
"

# ╔═╡ 9e564a6e-f521-41e8-8604-6a9d73af9ba7
R_t_fixed = [0.5 + 2.5 / (1 + exp(t - 15)) for t in 1:30]

# ╔═╡ 72bdb47d-4967-4f20-9ae5-01f82e7b32c5
latent_inf_mdl = generate_latent_infs(epi, log.(R_t_fixed))

# ╔═╡ 7a6d4b14-58d3-40c1-81f2-713c830f875f
plt_epi = let
    n_samples = 100
    epi_mdl_samples = mapreduce(hcat, 1:n_samples) do _
        θ = rand(latent_inf_mdl) #Sample unconditionally the underlying parameters of the model
        gen = generated_quantities(latent_inf_mdl, θ)
    end

    p1 = plot(epi_mdl_samples,
        lab = "",
        c = :grey,
        alpha = 0.25,
        title = "$(n_samples) draws from renewal model with chosen Rt",
        ylabel = "Latent infections"
    )
    p2 = plot(R_t_fixed,
        lab = "",
        lw = 2,
        ylabel = "Rt"
    )

    plot(p1, p2, layout = (2, 1))
end

# ╔═╡ c8ef8a60-d087-4ae9-ae92-abeea5afc7ae
md"
### Negative Binomial Observations as an `ObservationModel` type

In _Mishra et al_ latent infections were assumed to occur on their observation day with negative binomial errors, this motivates using the serial interval (the time between onset of symptoms of a primary and secondary case) rather than generation interval distribution (the time between infection time of a primary and secondary case).

Observation models are set in `EpiAware` as concrete subtypes of an `ObservationModel`. The Negative binomial error model without observation delays is set with a `NegativeBinomialError` struct. In _Mishra et al_ the overdispersion parameter $\phi$ sets the relationship between the mean and variance of the negative binomial errors,
```math
\text{var} = \text{mean} + {\text{mean}^2 \over \phi}.
```
In `EpiAware`, we default to a prior on $\sqrt{1/\phi}$ because this quantity has the dimensions of a standard deviation and, therefore, is easier to reason on _a priori_ beliefs.
"

# ╔═╡ 714908a1-dc85-476f-a99f-ec5c95a78b60
obs = NegativeBinomialError(cluster_factor_prior = HalfNormal(0.5))

# ╔═╡ dacb8094-89a4-404a-8243-525c0dbfa482
md"
##### `Turing` model interface

We can construct a `NegativeBinomialError` model implementation as a `Turing` `Model` using `generate_observations`

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
        θ = rand(obs_mdl) #Sample unconditionally the underlying parameters of the model
        gen = generated_quantities(obs_mdl, θ)
    end
    scatter(obs_mdl_samples,
        lab = "",
        c = :grey,
        alpha = 0.25,
        title = "$(n_samples) draws from neg. bin. obs model",
        ylabel = "Observed cases"
    )
    plot!(expected_cases,
        c = :red,
        lw = 3,
        lab = "Expected cases")
end

# ╔═╡ de5d96f0-4df6-4cc3-9f1d-156176b2b676
md"A _reverse_ observation model, which samples the underlying latent infections conditional on observations would require a prior on the latent infections. This is the purpose of composing multiple models; as we'll see below the latent infection and latent $R_t$ models are informative priors on the latent infection time series underlying the observations."

# ╔═╡ a06065e1-0e20-4cf8-8d5a-2d588da20bee
md"
## Composing models into an `EpiProblem`

As mentioned above, each module of the overall epidemiological model we are interested in is a `Turing` `Model` in its own right. In this section, we compose the individual models into the full epidemiological model using the `EpiProblem` struct.

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
		adtype = AutoReverseDiff(),
        ndraws = 2000,
        nchains = num_threads,
        mcmc_parallel = MCMCThreads(),
	)
)

# ╔═╡ 92333a96-5c9b-46e1-9a8f-f1890831066b
md"
## Inference and analysis

In the background of this note (see hidden top cell and short R script in this directory), we load daily reported cases from South Korea from Jan-July 2020 which were gathered using `covidregionaldata` from ECDC data archives.

We supply the data as a `NamedTuple` with the `y_t` field containing the observed data, shortened to fit the chosen `tspan` of `epi_prob`.
"

# ╔═╡ c7140b20-e030-4dc4-97bc-0efc0ff59631
south_korea_data = (y_t = data.cases_new[epi_prob.tspan[1]:epi_prob.tspan[2]],
    dates = data.date[epi_prob.tspan[1]:epi_prob.tspan[2]])

# ╔═╡ 9970adfd-ee88-4598-87a3-ffde5297031c
md"
### Sampling with `apply_method`

The `apply_method` function combines the elements above:
- An `EpiProblem` object.
- An `EpiMethod` object.
- Data to condition the model upon.

And returns a collection of results:
- The epidemiological model as a `Turing` `Model`.
- Samples from MCMC.
- Generated quantities of the model.
"

# ╔═╡ 660a8511-4dd1-4788-9c14-fdd604bf83ad
inference_results = apply_method(epi_prob,
    inference_method,
    south_korea_data
)

# ╔═╡ 5e6f505b-49fe-4ff4-ac2e-f6adcd445569
md"
### Results and Predictive plotting

We can spaghetti plot generated case data from the version of the model _which hasn't conditioned on case data_ using posterior parameters inferred from the version conditioned on observed data. This is known as _posterior predictive checking_, and is a useful diagnostic tool for Bayesian inference (see [here](http://www.stat.columbia.edu/~gelman/book/BDA3.pdf)).

Because we are using synthetic data we can also plot the model predictions for the _unobserved_ infections and check that (at least in this example) we were able to capture some unobserved/latent variables in the process accurate.

We find that the `EpiAware` model recovers the main finding in _Mishra et al_; that the $R_t$ in South Korea peaked at a very high value ($R_t \sim 10$ at peak) before rapidly dropping below 1 in early March 2020.

Note that, in reality, the peak $R_t$ found here and in _Mishra et al_ is unrealistically high, this might be due to a combination of:
- A mis-estimated generation interval/serial interval distribution.
- An ascertainment rate that was, in reality, changing over time.

In a future note, we'll demonstrate having a time-varying ascertainment rate.
"

# ╔═╡ e0df0135-c02e-4959-b334-13208ad5c8a6
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

    #Unconditional model for posterior predictive sampling
    mdl_unconditional = generate_epiaware(epi_prob, (y_t = missing,))
	posterior_gens = generated_quantities(mdl_unconditional, inference_results.samples)
	
	#plotting quantiles
	qs = [0.025, 0.25, 0.5, 0.75, 0.975]

	#Prediction quantiles
	predicted_y_t = generated_quantiles(posterior_gens, :generated_y_t, qs)
	predicted_R_t = generated_quantiles(posterior_gens, 
		:Z_t, 
		qs; 
		transformation=x -> exp.(x))

	#Plots
    p1 = plot(D, predicted_y_t[:, 3], lw = 2, lab = "post. median", c = :purple)
	plot!(p1, D, predicted_y_t[:, 2], fillrange = predicted_y_t[:, 4], fillalpha = 0.5, lw = 0, c = :purple, lab = "50%")
	plot!(p1, D, predicted_y_t[:, 1], fillrange = predicted_y_t[:, 5], fillalpha = 0.2, lw = 0, c = :purple, lab = "95%")

    scatter!(p1, D, C,
        lab = "Actual cases",
        ylabel = "Daily Cases",
        title = "Posterior predictive: Cases",
        ylims = (-50, maximum(C) * 2),
        c = :black
    )

	p2 = plot(D, predicted_R_t[:, 3], lw = 2, lab = "post. median", c = :green, yscale = :log10, title = "Prediction: Reproduction number")
	plot!(p2, D, predicted_R_t[:, 2], fillrange = predicted_R_t[:, 4], fillalpha = 0.5, lw = 0, c = :green, lab = "50%")
	plot!(p2, D, predicted_R_t[:, 1], fillrange = predicted_R_t[:, 5], fillalpha = 0.2, lw = 0, c = :green, lab = "95%")
	hline!(p2, [1.0], lab = "Rt = 1", lw = 2, c = :blue)

    plot(p1, p2, layout = (2, 1), size = (500, 700), left_margin = 5mm)
end

# ╔═╡ c05ed977-7a89-4ac8-97be-7078d69fce9f
md"
### Parameter inference

We can interrogate the sampled chains directly from the `samples` field of the `inference_results` object.
"

# ╔═╡ ff21c9ec-1581-405f-8db1-0f522b5bc296
let
    p1 = histogram(inference_results.samples["obs.cluster_factor"],
        lab = "chain " .* string.([1 2 3 4]),
        fillalpha = 0.4,
        lw = 0,
        norm = :pdf,
        title = "Posterior dist: Neg. bin. cluster factor")
    plot!(p1, obs.cluster_factor_prior,
        lw = 3,
        c = :black,
        lab = "prior")

    p2 = histogram(inference_results.samples[:init_incidence],
        lab = "chain " .* string.([1 2 3 4]),
        fillalpha = 0.4,
        lw = 0,
        norm = :pdf,
        title = "Posterior dist: log-initial incidence")
    plot!(p2, epi.initialisation_prior,
        lw = 3,
        c = :black,
        lab = "prior")

    p3 = histogram(inference_results.samples["latent.damp_AR[1]"],
        lab = "chain " .* string.([1 2 3 4]),
        fillalpha = 0.4,
        lw = 0,
        norm = :pdf,
        title = "Posterior dist: rho_1")
    plot!(p3, ar.damp_prior.v[1],
        lw = 3,
        c = :black,
        lab = "prior")

    p4 = histogram(inference_results.samples["latent.damp_AR[2]"],
        lab = "chain " .* string.([1 2 3 4]),
        fillalpha = 0.4,
        lw = 0,
        norm = :pdf,
        title = "Posterior dist: rho_2")
    plot!(p4, ar.damp_prior.v[2],
        lw = 3,
        c = :black,
        lab = "prior")

    plot(p1, p2, p3, p4, layout = (2, 2), size = (800, 600))
end

# ╔═╡ Cell order:
# ╟─9161ab72-5c39-4a67-9762-e19f1c54c7fd
# ╟─27d73202-a93e-4471-ab50-d59345304a0b
# ╠═e46a2fc8-f31e-4e11-9bcc-17836a41b08d
# ╠═dae655f7-9f4e-47b0-847d-6f885ef5c2a1
# ╠═93e1c8a9-05ce-42ef-b758-cdd8cd8e9086
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
# ╟─d201c82b-8efd-41e2-96d7-4f5e0c67088c
# ╟─eb1ea027-684e-46a9-88fa-b4b8239ed906
# ╠═c88bbbd6-0101-4c04-97c9-c5887ef23999
# ╟─31ee2757-0409-45df-b193-60c552797a3d
# ╠═2bf22866-b785-4ee0-953d-ac990a197561
# ╟─25e25125-8587-4451-8600-9b55a04dbcd9
# ╠═fbe117b7-a0b8-4604-a5dd-e71a0a1a4fc3
# ╟─9f84dec1-70f1-442e-8bef-a9494921549e
# ╠═51a82a62-2c59-43c9-8562-69d15a7edfdd
# ╠═d3938381-01b7-40c6-b369-a456ff6dba72
# ╟─141543f8-681c-4804-b4c9-e094b3c04fda
# ╟─6a9e871f-a2fa-4e41-af89-8b0b3c3b5b4b
# ╠═c1fc1929-0624-45c0-9a89-86c8479b2675
# ╠═7fdac621-4605-4ea8-88c7-7c3c4df5734f
# ╠═99c9ba2c-20a5-4c7f-94d2-272d6c9d5904
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
# ╠═d45f34e2-64f0-4828-ae0d-7b4cb3a3287d
# ╠═2e0e8bf3-f34b-44bc-aa2d-046e1db6ee2d
# ╠═55c639f6-b47b-47cf-a3d6-547e793c72bc
# ╠═c3a62dda-e054-4c8c-b1b8-ba1b5c4447b3
# ╟─de5d96f0-4df6-4cc3-9f1d-156176b2b676
# ╟─a06065e1-0e20-4cf8-8d5a-2d588da20bee
# ╠═eaad5f46-e928-47c2-90ec-2cca3871c75d
# ╟─2678f062-36ec-40a3-bd85-7b57a08fd809
# ╠═58f6f0bd-f1e4-459f-84b0-8d89831c8d7b
# ╠═88b43e23-1e06-4716-b284-76e8afc6171b
# ╟─92333a96-5c9b-46e1-9a8f-f1890831066b
# ╠═c7140b20-e030-4dc4-97bc-0efc0ff59631
# ╟─9970adfd-ee88-4598-87a3-ffde5297031c
# ╠═660a8511-4dd1-4788-9c14-fdd604bf83ad
# ╟─5e6f505b-49fe-4ff4-ac2e-f6adcd445569
# ╠═e0df0135-c02e-4959-b334-13208ad5c8a6
# ╠═8b557bf1-f3dd-4f42-a250-ce965412eb32
# ╟─c05ed977-7a89-4ac8-97be-7078d69fce9f
# ╠═ff21c9ec-1581-405f-8db1-0f522b5bc296
