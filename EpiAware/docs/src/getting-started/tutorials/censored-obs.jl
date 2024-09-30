### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# ╔═╡ a2624404-48b1-4faa-abbe-6d78b8e04f2b
let
    docs_dir = dirname(dirname(dirname(@__DIR__)))
    pkg_dir = dirname(docs_dir)

    using Pkg: Pkg
    Pkg.activate(docs_dir)
    Pkg.develop(; path = pkg_dir)
    Pkg.instantiate()
end

# ╔═╡ 5baa8d2e-bcf8-4e3b-b007-175ad3e2ca95
begin
    using EpiAware.EpiAwareUtils: censored_pmf, censored_cdf, ∫F
    using Random, Distributions, StatsBase #utilities for random events
    using DataFramesMeta #Data wrangling
    using CairoMakie, PairPlots #plotting
    using Turing #PPL
end

# ╔═╡ 8de5c5e0-6e95-11ef-1693-bfd465c8d919
md"
# Fitting distributions using `EpiAware` and Turing PPL

## Introduction

### What are we going to do in this Vignette

In this vignette, we'll demonstrate how to use the CDF function for censored delay distributions `EpiAwareUtils.∫F`, which underlies `EpiAwareUtils.censored_pmf` in conjunction with the Turing PPL for Bayesian inference of epidemiological delay distributions. We'll cover the following key points:

1. Simulating censored delay distribution data
2. Fitting a naive model using Turing
3. Evaluating the naive model's performance
4. Fitting an improved model using censored delay functionality from `EpiAware`.
5. Comparing the censored delay model's performance to the naive model

### What might I need to know before starting

This note builds on the concepts introduced in the R/stan package [`primarycensoreddist`](https://github.com/epinowcast/primarycensoreddist), especially the [Fitting distributions using primarycensorseddist and cmdstan](https://primarycensoreddist.epinowcast.org/articles/fitting-dists-with-stan.html) vignette and assumes familiarity with using Turing tools as covered in the [Turing documentation](https://turinglang.org/).

This note is generated using the `EpiAware` package locally via `Pkg.develop`, in the `EpiAware/docs` environment. It is also possible to install `EpiAware` using

```julia
Pkg.add(url=\"https://github.com/CDCgov/Rt-without-renewal\", subdir=\"EpiAware\")
```
### Packages used in this vignette
As well as `EpiAware` and `Turing` we will use `Makie` ecosystem packages for plotting and `DataFramesMeta` for data manipulation.
"

# ╔═╡ 30dd9af4-b64f-42b1-8439-a890752f68e3
md"
The other dependencies are as follows:
"

# ╔═╡ c5704f67-208d-4c2e-8513-c07c6b94ca99
md"
## Simulating censored and truncated delay distribution data

We'll start by simulating some censored and truncated delay distribution data. We’ll define a `rpcens` function for generating data.
"

# ╔═╡ aed124c7-b4ba-4c97-a01f-ff553f376c86
Random.seed!(123) # For reproducibility

# ╔═╡ ec5ed3e9-6ea9-4cfe-afd2-82aabbbe8130
md"Define the true distribution parameters"

# ╔═╡ 105b9594-36ce-4ae8-87a8-5c81867b1ce3
n = 2000

# ╔═╡ 8aa9f9c1-d3c4-49f3-be18-a400fc71e8f7
meanlog = 1.5

# ╔═╡ 84bb3999-9f2b-4eaa-9c2d-776a86677eaf
sdlog = 0.75

# ╔═╡ 2bf6677e-ebe9-4aa8-aa91-f631e99669bb
true_dist = LogNormal(meanlog, sdlog)

# ╔═╡ f4083aea-8106-401a-b60f-383d0b94102a
md"Generate varying pwindow, swindow, and obs_time lengths
"

# ╔═╡ aea8b28e-fffe-4aa6-b51e-8199a7c7975c
pwindows = rand(1:2, n)

# ╔═╡ 4d3a853d-0b8d-402a-8309-e9f6da2b7a8c
swindows = rand(1:2, n)

# ╔═╡ 7522f05b-1750-4983-8947-ef70f4298d06
obs_times = rand(8:10, n)

# ╔═╡ 5eac2f60-8cec-4460-9d10-6bade7f0f406
md"
We recreate the primary censored sampling function from `primarycensoreddist`, c.f. documentation [here](https://primarycensoreddist.epinowcast.org/reference/rprimarycensoreddist.html).
"

# ╔═╡ 9443b893-9e22-4267-9a1f-319a3adb8c0d
"""
	function rpcens(dist; pwindow = 1, swindow = 1, D = Inf, max_tries = 1000)

Does a truncated censored sample from `dist` with a uniform primary time on `[0, pwindow]`.
"""
function rpcens(dist; pwindow = 1, swindow = 1, D = Inf, max_tries = 1000)
    T = zero(eltype(dist))
    invalid_sample = true
    attempts = 1
    while (invalid_sample && attempts <= max_tries)
        X = rand(dist)
        U = rand() * pwindow
        T = X + U
        attempts += 1
        if X + U < D
            invalid_sample = false
        end
    end

    @assert !invalid_sample "censored value not found in $max_tries attempts"

    return (T ÷ swindow) * swindow
end

# ╔═╡ a4f5e9b6-ff3a-48fa-aa51-0abccb9c7bed
#Sample secondary time relative to beginning of primary censor window respecting the right-truncation
samples = map(pwindows, swindows, obs_times) do pw, sw, ot
    rpcens(true_dist; pwindow = pw, swindow = sw, D = ot)
end

# ╔═╡ 2a9da9e5-0925-4ae0-8b70-8db90903cb0b
md"
Aggregate to unique combinations and count occurrences
"

# ╔═╡ 0b5e96eb-9312-472e-8a88-d4509a4f25d0
delay_counts = mapreduce(vcat, pwindows, swindows, obs_times, samples) do pw, sw, ot, s
    DataFrame(
        pwindow = pw,
        swindow = sw,
        obs_time = ot,
        observed_delay = s,
        observed_delay_upper = s + sw
    )
end |>
               df -> @groupby(df, :pwindow, :swindow, :obs_time, :observed_delay,
    :observed_delay_upper) |>
                     gd -> @combine(gd, :n=length(:pwindow))

# ╔═╡ c0cce80f-dec7-4a55-aefd-339ef863f854
md"
Compare the samples with and without secondary censoring to the true distribution and calculate empirical CDF
"

# ╔═╡ a7bff47d-b61f-499e-8631-206661c2bdc0
empirical_cdf = ecdf(samples)

# ╔═╡ 16bcb80a-970f-4633-aca2-261fa04172f7
empirical_cdf_obs = ecdf(delay_counts.observed_delay, weights = delay_counts.n)

# ╔═╡ 60711c3c-266e-42b5-acc6-6624db294f24
x_seq = range(minimum(samples), maximum(samples), 100)

# ╔═╡ 1f1bcee4-8e0d-46fb-9a6f-41998bf54957
theoretical_cdf = x_seq |> x -> cdf(true_dist, x)

# ╔═╡ 59bb2a18-eaf4-438a-9359-341efadfe897
let
    f = Figure()
    ax = Axis(f[1, 1],
        title = "Comparison of Observed vs Theoretical CDF",
        ylabel = "Cumulative Probability",
        xlabel = "Delay"
    )
    lines!(
        ax, x_seq, empirical_cdf_obs, label = "Empirical CDF", color = :blue, linewidth = 2)
    lines!(ax, x_seq, theoretical_cdf, label = "Theoretical CDF",
        color = :black, linewidth = 2)
    vlines!(ax, [mean(samples)], color = :blue, linestyle = :dash,
        label = "Empirical mean", linewidth = 2)
    vlines!(ax, [mean(true_dist)], linestyle = :dash,
        label = "Theoretical mean", color = :black, linewidth = 2)
    axislegend(position = :rb)

    f
end

# ╔═╡ f66d4b2e-ed66-423e-9cba-62bff712862b
md"
We've aggregated the data to unique combinations of `pwindow`, `swindow`, and `obs_time` and counted the number of occurrences of each `observed_delay` for each combination. This is the data we will use to fit our model.
"

# ╔═╡ 010ebe37-782b-4a35-bf5c-dca6dc0fee45
md"
## Fitting a naive model using Turing

We'll start by fitting a naive model using NUTS from `Turing`. We define the model in the `Turing` PPL.
"

# ╔═╡ d9d14c48-8700-42b5-89b4-7fc51d0f577c
@model function naive_model(N, y, n)
    mu ~ Normal(1.0, 1.0)
    sigma ~ truncated(Normal(0.5, 1.0); lower = 0.0)
    d = LogNormal(mu, sigma)

    for i in eachindex(y)
        Turing.@addlogprob! n[i] * logpdf(d, y[i])
    end
end

# ╔═╡ 8a7cd9ec-5640-4f5f-84c3-ae3f465ca68b
md"
Now lets instantiate this model with data
"

# ╔═╡ 028ade5c-17bd-4dfc-8433-23aaff02c181
naive_mdl = naive_model(
    size(delay_counts, 1),
    delay_counts.observed_delay .+ 1e-6, # Add a small constant to avoid log(0)
    delay_counts.n)

# ╔═╡ 04b4eefb-f0f9-4887-8db0-7cbb7f3b169b
md"
and now let's fit the compiled model.
"

# ╔═╡ 21655344-d12b-4e47-a9a9-d06bd909f6ea
naive_fit = sample(naive_mdl, NUTS(), MCMCThreads(), 500, 4)

# ╔═╡ 3b89fe00-6aaf-4764-8b29-e71479f1e641
summarize(naive_fit)

# ╔═╡ 8e09d931-fca7-4ac2-81f7-2bc36b0174f3
let
    f = pairplot(naive_fit)
    vlines!(f[1, 1], [meanlog], linewidth = 4)
    vlines!(f[2, 2], [sdlog], linewidth = 4)
    f
end

# ╔═╡ 43eac8dd-8f1d-440e-b1e8-85db9e740651
md"
We see that the model has converged and the diagnostics look good. However, just from the model posterior summary we see that we might not be very happy with the fit. `mu` is smaller than the target $(meanlog) and `sigma` is larger than the target $(sdlog).

"

# ╔═╡ b2efafab-8849-4a7a-bb64-ac9ce126ca75
md"
## Fitting an improved model using censoring utilities

We'll now fit an improved model using the `∫F` function from `EpiAware.EpiAwareUtils` for calculating the CDF of the _total delay_ from the beginning of the primary window to the secondary event time. This includes both the delay distribution we are making inference on and the time between the start of the primary censor window and the primary event.
The `∫F` function underlies `censored_pmf` function from the `EpiAware.EpiAwareUtils` submodule.

Using the `∫F` function we can write a log-pmf function `primary_censored_dist_lpmf` that accounts for:
- The primary and secondary censoring windows, which can vary in length.
- The effect of right truncation in biasing our observations.

This is the analog function to the function of the same name in `primarycensoreddist`: it calculates the log-probability of the secondary event occurring in the secondary censoring window conditional on the primary event occurring in the primary censoring window by calculating the increase in the CDF over the secondary window and rescaling by the probability of the secondary event occuring within the maximum observation time `D`.
"

# ╔═╡ 348fc3b4-073b-4997-ae50-58ede5d6d0c9
function primary_censored_dist_lpmf(dist, y, pwindow, y_upper, D)
    if y == 0.0
        return log(∫F(dist, y_upper, pwindow)) - log(∫F(dist, D, pwindow))
    else
        return log(∫F(dist, y_upper, pwindow) - ∫F(dist, y, pwindow)) -
               log(∫F(dist, D, pwindow))
    end
end

# ╔═╡ cefb5d56-fecd-4de7-bd0e-156be91c705c
md"
We make a new `Turing` model that now uses `primary_censored_dist_lpmf` rather than the naive uncensored and untruncated `logpdf`.
"

# ╔═╡ ef40112b-f23e-4d4b-8a7d-3793b786f472
@model function primarycensoreddist_model(y, y_upper, n, pws, Ds)
    mu ~ Normal(1.0, 1.0)
    sigma ~ truncated(Normal(0.5, 0.5); lower = 0.0)
    dist = LogNormal(mu, sigma)

    for i in eachindex(y)
        Turing.@addlogprob! n[i] * primary_censored_dist_lpmf(
            dist, y[i], pws[i], y_upper[i], Ds[i])
    end
end

# ╔═╡ b823d824-419d-41e9-9ac9-2c45ef190acf
md"
Lets instantiate this model with data
"

# ╔═╡ 93bca93a-5484-47fa-8424-7315eef15e37
primarycensoreddist_mdl = primarycensoreddist_model(
    delay_counts.observed_delay,
    delay_counts.observed_delay_upper,
    delay_counts.n,
    delay_counts.pwindow,
    delay_counts.obs_time
)

# ╔═╡ d5144247-eb57-48bf-8e32-fd71167ecbc8
md"Now let’s fit the compiled model."

# ╔═╡ 7ae6c61d-0e33-4af8-b8d2-e31223a15a7c
primarycensoreddist_fit = sample(
    primarycensoreddist_mdl, NUTS(), MCMCThreads(), 1000, 4)

# ╔═╡ 1210443f-480f-4e9f-b195-d557e9e1fc31
summarize(primarycensoreddist_fit)

# ╔═╡ b2376beb-dd7b-442d-9ff5-ac864e75366b
let
    f = pairplot(primarycensoreddist_fit)
    CairoMakie.vlines!(f[1, 1], [meanlog], linewidth = 3)
    CairoMakie.vlines!(f[2, 2], [sdlog], linewidth = 3)
    f
end

# ╔═╡ 673b47ec-b333-45e8-9557-9e65ad425c35
md"
We see that the model has converged and the diagnostics look good. We also see that the posterior means are very near the true parameters and the 90% credible intervals include the true parameters.
"

# ╔═╡ Cell order:
# ╟─8de5c5e0-6e95-11ef-1693-bfd465c8d919
# ╠═a2624404-48b1-4faa-abbe-6d78b8e04f2b
# ╟─30dd9af4-b64f-42b1-8439-a890752f68e3
# ╠═5baa8d2e-bcf8-4e3b-b007-175ad3e2ca95
# ╟─c5704f67-208d-4c2e-8513-c07c6b94ca99
# ╠═aed124c7-b4ba-4c97-a01f-ff553f376c86
# ╟─ec5ed3e9-6ea9-4cfe-afd2-82aabbbe8130
# ╠═105b9594-36ce-4ae8-87a8-5c81867b1ce3
# ╠═8aa9f9c1-d3c4-49f3-be18-a400fc71e8f7
# ╠═84bb3999-9f2b-4eaa-9c2d-776a86677eaf
# ╠═2bf6677e-ebe9-4aa8-aa91-f631e99669bb
# ╟─f4083aea-8106-401a-b60f-383d0b94102a
# ╠═aea8b28e-fffe-4aa6-b51e-8199a7c7975c
# ╠═4d3a853d-0b8d-402a-8309-e9f6da2b7a8c
# ╠═7522f05b-1750-4983-8947-ef70f4298d06
# ╟─5eac2f60-8cec-4460-9d10-6bade7f0f406
# ╠═9443b893-9e22-4267-9a1f-319a3adb8c0d
# ╠═a4f5e9b6-ff3a-48fa-aa51-0abccb9c7bed
# ╟─2a9da9e5-0925-4ae0-8b70-8db90903cb0b
# ╠═0b5e96eb-9312-472e-8a88-d4509a4f25d0
# ╟─c0cce80f-dec7-4a55-aefd-339ef863f854
# ╠═a7bff47d-b61f-499e-8631-206661c2bdc0
# ╠═16bcb80a-970f-4633-aca2-261fa04172f7
# ╠═60711c3c-266e-42b5-acc6-6624db294f24
# ╠═1f1bcee4-8e0d-46fb-9a6f-41998bf54957
# ╠═59bb2a18-eaf4-438a-9359-341efadfe897
# ╟─f66d4b2e-ed66-423e-9cba-62bff712862b
# ╠═010ebe37-782b-4a35-bf5c-dca6dc0fee45
# ╠═d9d14c48-8700-42b5-89b4-7fc51d0f577c
# ╟─8a7cd9ec-5640-4f5f-84c3-ae3f465ca68b
# ╠═028ade5c-17bd-4dfc-8433-23aaff02c181
# ╟─04b4eefb-f0f9-4887-8db0-7cbb7f3b169b
# ╠═21655344-d12b-4e47-a9a9-d06bd909f6ea
# ╠═3b89fe00-6aaf-4764-8b29-e71479f1e641
# ╠═8e09d931-fca7-4ac2-81f7-2bc36b0174f3
# ╟─43eac8dd-8f1d-440e-b1e8-85db9e740651
# ╟─b2efafab-8849-4a7a-bb64-ac9ce126ca75
# ╠═348fc3b4-073b-4997-ae50-58ede5d6d0c9
# ╟─cefb5d56-fecd-4de7-bd0e-156be91c705c
# ╠═ef40112b-f23e-4d4b-8a7d-3793b786f472
# ╟─b823d824-419d-41e9-9ac9-2c45ef190acf
# ╠═93bca93a-5484-47fa-8424-7315eef15e37
# ╟─d5144247-eb57-48bf-8e32-fd71167ecbc8
# ╠═7ae6c61d-0e33-4af8-b8d2-e31223a15a7c
# ╠═1210443f-480f-4e9f-b195-d557e9e1fc31
# ╠═b2376beb-dd7b-442d-9ff5-ac864e75366b
# ╟─673b47ec-b333-45e8-9557-9e65ad425c35
