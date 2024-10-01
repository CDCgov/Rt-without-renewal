### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# ╔═╡ e34cec5a-a173-4e92-a860-340c7a9e9c72
let
    docs_dir = dirname(dirname(dirname(dirname(@__DIR__))))
    pkg_dir = dirname(docs_dir)

    using Pkg: Pkg
    Pkg.activate(docs_dir)
    Pkg.develop(; path = pkg_dir)
    Pkg.instantiate()
end;

# ╔═╡ b1468db3-7ab0-468c-8e27-70013a8f512f
using EpiAware

# ╔═╡ a4710701-6315-459d-b677-f24b77ff3e80
using Turing

# ╔═╡ 7263d714-2ce4-4d57-8881-6b60db018dd5
using OrdinaryDiffEq, SciMLSensitivity #ODE solvers and adjoint methods

# ╔═╡ 261420cd-4650-402b-b126-7a431f93f37e
using Distributions, Statistics #Statistics packages

# ╔═╡ 9c19a98b-a08b-4560-966d-61ff0ece2ad5
using CSV, DataFramesMeta #Data wrangling

# ╔═╡ 3897e773-ed07-4860-bb62-35605d0dacb0
using CairoMakie, PairPlots

# ╔═╡ 14641441-dbea-4fdf-88e0-64a57da60ef7
using ReverseDiff #Automatic differentiation backend

# ╔═╡ a0d91258-8ab5-4adc-98f2-8f17b4bd685c
begin #Date utility and set Random seed
    using Dates
    using Random
    Random.seed!(1234)
end

# ╔═╡ 33384fc6-7cca-11ef-3567-ab7df9200cde
md"
# Example: Contemporary statistical inference for infectious disease models
# Introduction
## What are we going to do in this Vignette
In this vignette, we'll demonstrate how to use `EpiAware` in conjunction with [SciML ecosystem](https://sciml.ai/) for Bayesian inference of infectious disease dynamics. The model and data is heavily based on [Contemporary statistical inference for infectious disease models using Stan _Chatzilena et al. 2019_](https://www.sciencedirect.com/science/article/pii/S1755436519300325).

We'll cover the following key points:

1. Defining the deterministic ODE model from Chatzilena et al section 2.2.2 using SciML ODE functionality and an `EpiAware` observation model.
2. Build on this to define the stochastic ODE model from Chatzilena et al section 2.2.3 using an `EpiAware` observation model.
3. Fitting the deterministic ODE model to data from an Influenza outbreak in an English boarding school.
4. Fitting the stochastic ODE model to data from an Influenza outbreak in an English boarding school.

## What might I need to know before starting

This vignette builds on concepts from `EpiAware` observation models and a familarity with the `SciML` and `Turing` ecosystems would be useful but not essential.

## Packages used in this vignette

Alongside the `EpiAware` package we will use the `OrdinaryDiffEq` package for interfacing with `SciML` ecosystem; this is a lower dependency usage of `DifferentialEquations.jl` that only exposes ODE solvers. Bayesian inference will be done with `NUTS` from the `Turing` ecosystem. We will also use the `CairoMakie` package for plotting and `DataFramesMeta` for data manipulation.
"

# ╔═╡ 943b82ec-b4dc-4537-8183-d6c73cd74a37
md"
# SIR models from _Chatzilena et al_

As mentioned in _Chatzilena et al_ disease spread is frequently modelled in terms
of ODE-based models. The study population is divided into compartments representing a specific stage of the epidemic status. In this case, susceptible, infected, and recovered individuals.

```math
\begin{aligned}
{dS \over dt} &= - \beta \frac{I(t)}{N} S(t) \\
{dI \over dt} &= \beta \frac{I(t)}{N} S(t) - \gamma I(t) \\
{dR \over dt} &= \gamma I(t). \\
\end{aligned}
```
where S(t) represents the number of susceptible, I(t) the number of
infected and R(t) the number of recovered individuals at time t. The
total population size is denoted by N (with N = S(t) + I(t) + R(t)), β
denotes the transmission rate and γ denotes the recovery rate.
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

# ╔═╡ bb07a580-6d86-48b3-a79f-d2ed9306e87c
sir_prob = ODEProblem(
    sir!,
    [0.99, 0.01, 0.0],
    (0.0, (Date(1978, 2, 4) - Date(1978, 1, 22)).value + 1),
    [3.0, 2.0]
)

# ╔═╡ aba3f1db-c290-409c-9b9e-6065935ede54
N = 763

# ╔═╡ 7c9cbbc1-71ef-4d81-b93a-c2b3a8683d53
url = "https://raw.githubusercontent.com/CDCgov/Rt-without-renewal/refs/heads/446-add-chatzilena-et-al-as-a-replication-example/EpiAware/docs/src/showcase/replications/chatzilena-2019/influenza_england_1978_school.csv2"

# ╔═╡ eb247c93-1512-4927-9f39-ae408be0dc89
data = CSV.read(download(url), DataFrame)

# ╔═╡ 3f54bb44-76c4-4744-885a-46dedfaffeca
md"
## Deterministic SIR model

"

# ╔═╡ 87509792-e28d-4618-9bf5-e06b2e5dbe8b
obs = PoissonError()

# ╔═╡ 1d287c8e-7000-4b23-ae7e-f7008c3e53bd
@model function deterministic_ode_mdl(Yt, obs, prob, N)
    nobs = length(Yt)

    β ~ LogNormal(0.0, 1.0)
    γ ~ Gamma(0.004, 1 / 0.002)
    S₀ ~ Beta(0.5, 0.5)

    # try
        _prob = remake(prob;
            u0 = [S₀, 1 - S₀, 0.0],
            p = [β, γ]
        )

        sol = solve(_prob, AutoTsit5(Rosenbrock23()); saveat = 1.0:nobs, verbose = false, sensealg = ForwardDiffSensitivity())
        λt = N * sol[2, :] .+ 1e-3

        @submodel obsYt = generate_observations(obs, Yt, λt)

        return (; sol, obsYt, R0 = β / γ)
    # catch
    #     Turing.@addlogprob! -Inf
    #     return
    # end
end

# ╔═╡ dbc1b453-1c29-4f82-bec9-098d67f9e63f
mdl = deterministic_ode_mdl(data.in_bed, obs, sir_prob, N)

# ╔═╡ e795c2bf-0861-4e96-9921-db47f41af206
uncond_mdl = deterministic_ode_mdl(fill(missing,length(data.in_bed)), obs, sir_prob, N)

# ╔═╡ ba35cebd-0d29-43c5-8db7-f550d7f821bc
map_fit = map(1:10) do _
	fit = maximum_a_posteriori(mdl;
		initial_params=[1, 0.1, 0.99],
	)
end |>
fits -> (findmax(fit -> fit.lp, fits)[2], fits) |>
min_and_fits -> min_and_fits[2][min_and_fits[1]]

# ╔═╡ 0be912c1-22dc-4978-b86a-84273062f5da
map_fit.optim_result.retcode

# ╔═╡ 2cf64ba3-ff8d-40b0-9bd8-9e80393156f5
chn = sample(mdl, NUTS(), MCMCThreads(), 1000, 4; initial_params=fill(map_fit.values.array,4))

# ╔═╡ 6d8a1903-ffcf-47a9-a02a-4ef77525f133
map_fit.values

# ╔═╡ b2429b68-dd75-499f-a4e1-1b7d72e209c7
describe(chn)

# ╔═╡ 1e7f37c5-4cb4-4d06-8f68-55d80f7a00ad
pairplot(chn)

# ╔═╡ 03d1ecf8-543d-444d-b1a3-7a19acd88499
let
ts = 1:size(data, 1)
gens = generated_quantities(uncond_mdl, chn)
fig = Figure()
ax = Axis(fig[1,1];
	title = "Fitted deterministic model",
	xticks = (ts[1:3:end], data.date[1:3:end] .|> string),
	ylabel = "Number of Infected students"
	)
pred_Yt = mapreduce(hcat, gens) do gen
	gen.obsYt
end |> X -> mapreduce(vcat, eachrow(X)) do row
	quantile(row, [0.5, 0.025, 0.975])'
end

lines!(ax,ts, pred_Yt[:,1]; linewidth = 3, label = "Fitted deterministic model", color = :green)
band!(ax, ts, pred_Yt[:,2], pred_Yt[:,3], color = (:green, 0.5))
scatter!(ax, data.in_bed)

fig
end

# ╔═╡ 506855ac-57f1-40cf-9ee1-c3097b9b554a


# ╔═╡ e023770d-25f7-4b7a-b509-8a4372f42b76
md"
## Stochastic model
"

# ╔═╡ 71a26408-1c26-46cf-bc72-c6ba528dfadd
ar = AR(HalfNormal(0.01),
    HalfNormal(0.3),
    Normal(0, 0.001)
)

# ╔═╡ 178e0048-069a-4953-bb24-5116eb81cc41
ϕs = rand(truncated(Normal(0,100), lower = 0.), 1000) 

# ╔═╡ e6bcf0c0-3cc4-41f3-ad20-fa11bf2ca37b
σs = rand(InverseGamma(0.1,0.1), 1000) .|> x -> 1/x

# ╔═╡ f9c1bcd4-bfb4-45d4-ae06-f114a0923bd7
mean(InverseGamma(0.1,0.1))

# ╔═╡ 4f07e8ba-30d0-411f-8c3e-b6d5bc1bb5fa
AR_damps = ϕs .|> ϕ -> exp(-ϕ)

# ╔═╡ 7235289e-28f0-43c2-986b-81b96c42d9fe
mean(AR_damps)

# ╔═╡ 48032d21-53fa-4c0a-85cb-c22327b55073
AR_stds = zip(ϕs, σs) .|> ϕ_σ -> (1 - exp(-2*ϕ_σ[1])) * ϕ_σ[2] / (2 * ϕ_σ[1])

# ╔═╡ 4089aea2-3946-48b0-bf7c-dcdc73fe87fa
mean(AR_stds)

# ╔═╡ ec63fd4b-4323-4a9e-9aa7-46ba4115ec4f


# ╔═╡ 2dcb4034-b138-4c3e-b65f-ba13f230439c
hist(AR_stds)

# ╔═╡ 7271886d-2f87-4dc1-833b-182f4b726738
# xs = rand(truncated(Normal(0,100), lower = 0.), 1000) .|> x -> exp(-x)
xs = rand(InverseGamma(1/0.1,1/0.1), 1000)

# ╔═╡ 68b75d5b-2b45-44bd-a973-12cba31d0e53


# ╔═╡ f0f02012-e0fe-4d11-a60a-dc27b6dd510c
density(xs)

# ╔═╡ e15d0532-0c8a-4cd2-a576-567fc0c625c5
gmdl = generate_latent(ar, 10)

# ╔═╡ 0be4b20e-5f16-43dc-90f6-84a6f29ae8cc
gmdl()

# ╔═╡ 9309f7f8-0896-4686-8bfc-b9f82d91bc0f
@model function stochastic_ode_mdl(Yt, logobsprob, obs, prob, N)
    nobs = length(Yt)

    β ~ LogNormal(0.0, 1.0)
    γ ~ Gamma(0.004, 1 / 0.002)
    S₀ ~ Beta(0.5, 0.5)


    # try
    _prob = remake(prob;
        u0 = [S₀, 1 - S₀, 0.0],
        p = [β, γ]
    )

    sol = solve(_prob, AutoTsit5(Rosenbrock23());
					sensealg = ForwardDiffSensitivity(),
					saveat = 1.0:nobs, verbose = false)
    # μ = log.(N * sol[2, :])
    @submodel κ = generate_latent(logobsprob, nobs)
    λt = @. N * sol[2, :] * exp(κ) + 0.1

    @submodel obsYt = generate_observations(obs, Yt, λt)

    return (; sol, obsYt, R0 = β / γ)
    # catch
    # 	Turing.@addlogprob! -Inf
    # 	return
    # end
end

# ╔═╡ 6dbd3935-dada-4cac-903e-2dec1a197304


# ╔═╡ 4330c83f-de39-44c7-bdab-87e5f5830145
mdl2 = stochastic_ode_mdl(data.in_bed, ar, obs, sir_prob, N)

# ╔═╡ 8071c92f-9fe8-48cf-b1a0-79d1e34ec7e7
uncond_mdl2 = stochastic_ode_mdl(fill(missing,length(data.in_bed)), ar, obs, sir_prob, N)

# ╔═╡ bbe9a87a-a212-4d9d-9c75-8a863d6fb0be
rand(mdl2)

# ╔═╡ d4502528-d058-4899-b3dd-576316116c18
map_fit2 = map(1:10) do _
	fit = maximum_a_posteriori(mdl2;
		initial_params=vcat([1, 0.1, 0.99, 0.01, 0., 0.01], zeros(13)),
		adtype=AutoReverseDiff()
	)
end |>
fits -> (findmax(fit -> fit.lp, fits)[2], fits) |>
min_and_fits -> min_and_fits[2][min_and_fits[1]]

# ╔═╡ 6a246854-601b-4d5a-9fb8-52b0e1620e7d
mdl2()

# ╔═╡ 156272d7-56c4-4ac4-bf3e-7882f4edc144
chn2 = sample(mdl2, NUTS(; adtype = AutoReverseDiff(true)), MCMCThreads(), 1000, 4; initial_params = fill(map_fit2.values.array,4))

# ╔═╡ 00b90e6d-732f-41c9-a603-cabe9740e329
describe(chn2)

# ╔═╡ 37a016d8-8384-41c9-abdd-23e88b1f988d
pairplot(chn2[[:β, :γ, :S₀]])

# ╔═╡ 0e7bbf13-9187-41ea-8b46-294b93be4c6d
let
ts = 1:size(data, 1)
gens = generated_quantities(uncond_mdl2, chn2)
fig = Figure()
ax = Axis(fig[1,1];
	title = "Fitted Stochastic model",
	xticks = (ts[1:3:end], data.date[1:3:end] .|> string),
	ylabel = "Number of Infected students"
	)
pred_Yt = mapreduce(hcat, gens) do gen
	gen.obsYt
end |> X -> mapreduce(vcat, eachrow(X)) do row
	quantile(row, [0.5, 0.025, 0.975])'
end

lines!(ax,ts, pred_Yt[:,1]; linewidth = 3, label = "Fitted deterministic model", color = :green)
band!(ax, ts, pred_Yt[:,2], pred_Yt[:,3], color = (:green, 0.5))
scatter!(ax, data.in_bed)

fig
end

# ╔═╡ 36efe6e0-643f-42e6-9d64-de2f5a76b764


# ╔═╡ Cell order:
# ╟─e34cec5a-a173-4e92-a860-340c7a9e9c72
# ╠═33384fc6-7cca-11ef-3567-ab7df9200cde
# ╠═b1468db3-7ab0-468c-8e27-70013a8f512f
# ╠═a4710701-6315-459d-b677-f24b77ff3e80
# ╠═7263d714-2ce4-4d57-8881-6b60db018dd5
# ╠═261420cd-4650-402b-b126-7a431f93f37e
# ╠═9c19a98b-a08b-4560-966d-61ff0ece2ad5
# ╠═3897e773-ed07-4860-bb62-35605d0dacb0
# ╠═14641441-dbea-4fdf-88e0-64a57da60ef7
# ╠═a0d91258-8ab5-4adc-98f2-8f17b4bd685c
# ╠═943b82ec-b4dc-4537-8183-d6c73cd74a37
# ╠═ab4269b1-e292-466f-8bfb-713d917c18f9
# ╠═bb07a580-6d86-48b3-a79f-d2ed9306e87c
# ╠═aba3f1db-c290-409c-9b9e-6065935ede54
# ╠═7c9cbbc1-71ef-4d81-b93a-c2b3a8683d53
# ╠═eb247c93-1512-4927-9f39-ae408be0dc89
# ╠═3f54bb44-76c4-4744-885a-46dedfaffeca
# ╠═87509792-e28d-4618-9bf5-e06b2e5dbe8b
# ╠═1d287c8e-7000-4b23-ae7e-f7008c3e53bd
# ╠═dbc1b453-1c29-4f82-bec9-098d67f9e63f
# ╠═e795c2bf-0861-4e96-9921-db47f41af206
# ╠═ba35cebd-0d29-43c5-8db7-f550d7f821bc
# ╠═0be912c1-22dc-4978-b86a-84273062f5da
# ╠═2cf64ba3-ff8d-40b0-9bd8-9e80393156f5
# ╠═6d8a1903-ffcf-47a9-a02a-4ef77525f133
# ╠═b2429b68-dd75-499f-a4e1-1b7d72e209c7
# ╠═1e7f37c5-4cb4-4d06-8f68-55d80f7a00ad
# ╠═03d1ecf8-543d-444d-b1a3-7a19acd88499
# ╠═506855ac-57f1-40cf-9ee1-c3097b9b554a
# ╠═e023770d-25f7-4b7a-b509-8a4372f42b76
# ╠═71a26408-1c26-46cf-bc72-c6ba528dfadd
# ╠═178e0048-069a-4953-bb24-5116eb81cc41
# ╠═e6bcf0c0-3cc4-41f3-ad20-fa11bf2ca37b
# ╠═f9c1bcd4-bfb4-45d4-ae06-f114a0923bd7
# ╠═4f07e8ba-30d0-411f-8c3e-b6d5bc1bb5fa
# ╠═7235289e-28f0-43c2-986b-81b96c42d9fe
# ╠═48032d21-53fa-4c0a-85cb-c22327b55073
# ╠═4089aea2-3946-48b0-bf7c-dcdc73fe87fa
# ╠═ec63fd4b-4323-4a9e-9aa7-46ba4115ec4f
# ╠═2dcb4034-b138-4c3e-b65f-ba13f230439c
# ╠═7271886d-2f87-4dc1-833b-182f4b726738
# ╠═68b75d5b-2b45-44bd-a973-12cba31d0e53
# ╠═f0f02012-e0fe-4d11-a60a-dc27b6dd510c
# ╠═e15d0532-0c8a-4cd2-a576-567fc0c625c5
# ╠═0be4b20e-5f16-43dc-90f6-84a6f29ae8cc
# ╠═9309f7f8-0896-4686-8bfc-b9f82d91bc0f
# ╠═6dbd3935-dada-4cac-903e-2dec1a197304
# ╠═4330c83f-de39-44c7-bdab-87e5f5830145
# ╠═8071c92f-9fe8-48cf-b1a0-79d1e34ec7e7
# ╠═bbe9a87a-a212-4d9d-9c75-8a863d6fb0be
# ╠═d4502528-d058-4899-b3dd-576316116c18
# ╠═6a246854-601b-4d5a-9fb8-52b0e1620e7d
# ╠═156272d7-56c4-4ac4-bf3e-7882f4edc144
# ╠═00b90e6d-732f-41c9-a603-cabe9740e329
# ╠═37a016d8-8384-41c9-abdd-23e88b1f988d
# ╠═0e7bbf13-9187-41ea-8b46-294b93be4c6d
# ╠═36efe6e0-643f-42e6-9d64-de2f5a76b764
