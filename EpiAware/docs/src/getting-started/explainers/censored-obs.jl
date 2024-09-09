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
	Pkg.add(["DataFramesMeta", "StatsBase", "TuringBenchmarking"])
    Pkg.instantiate()
end

# ╔═╡ 5baa8d2e-bcf8-4e3b-b007-175ad3e2ca95
begin
	using EpiAware.EpiAwareUtils: censored_pmf
	using Random, Distributions, StatsBase #utilities for random events
	using DataFramesMeta #Data wrangling
	using StatsPlots #plotting
	using Turing, TuringBenchmarking #PPL
end

# ╔═╡ 8de5c5e0-6e95-11ef-1693-bfd465c8d919
md"
# Fitting distributions using `censored_pmf` and Turing PPL

## Introduction

### What are we going to do in this Vignette

In this vignette, we'll demonstrate how to use `EpiAwareUtils.censored_pmf` in conjunction with the Turing PPL for Bayesian inference of epidemiological delay distributions. We'll cover the following key points:

1. Simulating censored delay distribution data
2. Fitting a naive model using Turing
3. Evaluating the naive model's performance
4. Fitting an improved model using `censored_pmf` functionality
5. Comparing the `censored_pmf` model's performance to the naive model

### What might I need to know before starting

This note builds on the concepts introduced in the R/stan package [`primarycensoreddist`](https://github.com/epinowcast/primarycensoreddist), especially the [Getting Started with primarycensoreddist](https://primarycensoreddist.epinowcast.org/articles/fitting-dists-with-stan.html) vignette and assumes familiarity with using Turing tools as covered in the [Turing documentation](https://turinglang.org/).

This note is generated using the `EpiAware` package locally via `Pkg.develop`, in the `EpiAware/docs` environment. It is also possible to install `EpiAware` using 

```julia
Pkg.add(url=\"https://github.com/CDCgov/Rt-without-renewal\", subdir=\"EpiAware\")
```

"

# ╔═╡ 30dd9af4-b64f-42b1-8439-a890752f68e3
md"
The other dependencies are as follows:
"

# ╔═╡ c5704f67-208d-4c2e-8513-c07c6b94ca99
md"
## Simulating censored and truncated delay distribution data

We'll start by simulating some censored and truncated delay distribution data.
"

# ╔═╡ aed124c7-b4ba-4c97-a01f-ff553f376c86
Random.seed!(123) # For reproducibility

# ╔═╡ 105b9594-36ce-4ae8-87a8-5c81867b1ce3
# Define the true distribution parameters
n = 1000

# ╔═╡ 8aa9f9c1-d3c4-49f3-be18-a400fc71e8f7
meanlog = 1.5

# ╔═╡ 84bb3999-9f2b-4eaa-9c2d-776a86677eaf
sdlog = 0.75

# ╔═╡ 2bf6677e-ebe9-4aa8-aa91-f631e99669bb
true_dist = LogNormal(meanlog, sdlog)

# ╔═╡ aea8b28e-fffe-4aa6-b51e-8199a7c7975c
# Generate varying pwindow, swindow, and obs_time lengths
pwindows = rand(1:1, n)

# ╔═╡ d231bd0c-165f-4973-a46f-f66991813ea7
swindows = rand(1:1, n)

# ╔═╡ 7522f05b-1750-4983-8947-ef70f4298d06
obs_times = fill(10.0,n)

# ╔═╡ a4f5e9b6-ff3a-48fa-aa51-0abccb9c7bed
#Sample secondary time relative to beginning of primary censor window respecting the right-truncation
samples = map(pwindows, swindows, obs_times) do pw, sw, ot
	P = rand() * pw # Primary event time 
	T = rand(truncated(true_dist; upper= ot - P))
end

# ╔═╡ 0b5e96eb-9312-472e-8a88-d4509a4f25d0
# Generate samples
delay_counts = mapreduce(vcat, samples, pwindows, swindows, obs_times) do T, pw, sw, ot
	DataFrame(
		pwindow = pw, 
		swindow = sw, 
		obs_time = ot, 
		observed_delay = T ÷ sw .|> Int,
		observed_delay_upper = (T ÷ sw) + sw |> Int,
	)
end |> # Aggregate to unique combinations and count occurrences
	df -> @groupby(df, :pwindow, :swindow, :obs_time, :observed_delay, :observed_delay_upper) |>
	gd -> @combine(gd, :n = length(:pwindow))

# ╔═╡ a7bff47d-b61f-499e-8631-206661c2bdc0
empirical_cdf = ecdf(samples)

# ╔═╡ 16bcb80a-970f-4633-aca2-261fa04172f7
empirical_cdf_obs = ecdf(delay_counts.observed_delay, weights=delay_counts.n)

# ╔═╡ 60711c3c-266e-42b5-acc6-6624db294f24
x_seq = range(minimum(samples), maximum(samples), 100)

# ╔═╡ c6fe3c52-af87-4a84-b280-bc9a8532e269
#plot
let
	plot(; title = "Comparison of Observed vs Theoretical CDF",
		ylabel = "Cumulative Probability",
		xlabel = "Delay",
		xticks = 0:obs_times[1],
		xlims = (-0.1, obs_times[1] + 0.5)
	)
	plot!(x_seq, x_seq .|> x->empirical_cdf(x), 
		lab = "Observed secondary times",
		c = :blue,
		lw = 3,
	)
	plot!(x_seq, x_seq .|> x->empirical_cdf_obs(x), 
		lab = "Observed censored secondary times",
		c = :green,
		lw = 3,
	)
	plot!(x_seq, x_seq .|> x -> cdf(true_dist, x),
		lab = "Theoretical",
		c = :black,
		lw = 3,
	)
	vline!([mean(samples)], ls = :dash, c= :blue, lw = 3, lab = "")
	vline!([mean(true_dist)], ls = :dash, c= :black, lw = 3, lab = "")
end

# ╔═╡ f66d4b2e-ed66-423e-9cba-62bff712862b
md"
We've aggregated the data to unique combinations of `pwindow`, `swindow`, and `obs_time` and counted the number of occurrences of each `observed_delay` for each combination. This is the data we will use to fit our model.
"

# ╔═╡ 010ebe37-782b-4a35-bf5c-dca6dc0fee45
md"
## Fitting a naive model using Turing

We'll start by fitting a naive model using Turing.
"

# ╔═╡ d9d14c48-8700-42b5-89b4-7fc51d0f577c
@model function naive_model(N, y, n)
	mu ~ Normal(1., 1.)
	sigma ~ truncated(Normal(0.5, 1.0); lower= 0.0)
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
	size(delay_counts,1), 
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

# ╔═╡ 43eac8dd-8f1d-440e-b1e8-85db9e740651
md"
We see that the model has converged and the diagnostics look good. However, just from the model posterior summary we see that we might not be very happy with the fit. `mu` is smaller than the target $(meanlog) and `sigma` is larger than the target $(sdlog).

"

# ╔═╡ b2efafab-8849-4a7a-bb64-ac9ce126ca75
md"
## Fitting an improved model using primarycensoreddist

We'll now fit an improved model using the `censored_pmf` function from the `EpiAware.EpiAwareUtils` submodule. This accounts for the primary and secondary censoring windows as well as the truncation.

"

# ╔═╡ ef40112b-f23e-4d4b-8a7d-3793b786f472
@model function primarycensoreddist_model(N, y, y_upper, n, pwindow, D)
	try
		mu ~ Normal(1., 1.)
		sigma ~ truncated(Normal(0.5, 0.5); lower= 0.1,)
		d = LogNormal(mu, sigma)
		log_pmf = censored_pmf(d; Δd = pwindow, D = D) .|> log
	
		for i in eachindex(y)
			Turing.@addlogprob! n[i] * log_pmf[y[i] + 1] #0 obs is first element of array
		end
		return log_pmf
	catch
		Turing.@addlogprob! -Inf
	end
end

# ╔═╡ b823d824-419d-41e9-9ac9-2c45ef190acf
md"
Lets instantiate this model with data
"

# ╔═╡ 93bca93a-5484-47fa-8424-7315eef15e37
primarycensoreddist_mdl = primarycensoreddist_model(
	size(delay_counts,1), 
	delay_counts.observed_delay, # Add a small constant to avoid log(0)
	delay_counts.observed_delay_upper, # Add a small constant to avoid log(0)
	delay_counts.n,
	delay_counts.pwindow[1],
	delay_counts.obs_time[1]
)

# ╔═╡ 8f1d32fd-f54b-4f69-8c93-8f0786366cef
# ╠═╡ disabled = true
#=╠═╡
benchmark_model(
           primarycensoreddist_mdl;
           # Check correctness of computations
           check=true,
           # Automatic differentiation backends to check and benchmark
           adbackends=[:forwarddiff, :reversediff, :reversediff_compiled]
       )
  ╠═╡ =#

# ╔═╡ 44132e2e-5a1a-49ad-9e57-cec24f981f52
map_estimate = [maximum_a_posteriori(primarycensoreddist_mdl) for _ in 1:10] |>
	opts -> (opts, findmax([o.lp for o in opts])[2]) |>
	opts_i -> opts_i[1][opts_i[2]]

# ╔═╡ a34c19e8-ba9e-4276-a17e-c853bb3341cf
# ╠═╡ disabled = true
#=╠═╡
primarycensoreddist_fit = sample(primarycensoreddist_mdl, NUTS(), MCMCThreads(), 500, 4)
  ╠═╡ =#

# ╔═╡ 1210443f-480f-4e9f-b195-d557e9e1fc31
summarize(primarycensoreddist_fit)

# ╔═╡ 46711233-f680-4962-9e3e-60c747db4d2c
censored_pmf(true_dist; D = obs_times[1] )

# ╔═╡ 604458a6-7b6f-4b5c-b2e7-09be1908c0f9
# ╠═╡ disabled = true
#=╠═╡
primarycensoreddist_fit = sample(primarycensoreddist_mdl, MH(), 100_000; initial_params=map_estimate.values.array) |>
	chn -> chn[50_000:end, :, :]
  ╠═╡ =#

# ╔═╡ 7ae6c61d-0e33-4af8-b8d2-e31223a15a7c
primarycensoreddist_fit = sample(primarycensoreddist_mdl, NUTS(), 1000; initial_params=map_estimate.values.array)

# ╔═╡ Cell order:
# ╟─8de5c5e0-6e95-11ef-1693-bfd465c8d919
# ╠═a2624404-48b1-4faa-abbe-6d78b8e04f2b
# ╟─30dd9af4-b64f-42b1-8439-a890752f68e3
# ╠═5baa8d2e-bcf8-4e3b-b007-175ad3e2ca95
# ╟─c5704f67-208d-4c2e-8513-c07c6b94ca99
# ╠═aed124c7-b4ba-4c97-a01f-ff553f376c86
# ╠═105b9594-36ce-4ae8-87a8-5c81867b1ce3
# ╠═8aa9f9c1-d3c4-49f3-be18-a400fc71e8f7
# ╠═84bb3999-9f2b-4eaa-9c2d-776a86677eaf
# ╠═2bf6677e-ebe9-4aa8-aa91-f631e99669bb
# ╠═aea8b28e-fffe-4aa6-b51e-8199a7c7975c
# ╠═d231bd0c-165f-4973-a46f-f66991813ea7
# ╠═7522f05b-1750-4983-8947-ef70f4298d06
# ╠═a4f5e9b6-ff3a-48fa-aa51-0abccb9c7bed
# ╠═0b5e96eb-9312-472e-8a88-d4509a4f25d0
# ╠═a7bff47d-b61f-499e-8631-206661c2bdc0
# ╠═16bcb80a-970f-4633-aca2-261fa04172f7
# ╠═60711c3c-266e-42b5-acc6-6624db294f24
# ╠═c6fe3c52-af87-4a84-b280-bc9a8532e269
# ╟─f66d4b2e-ed66-423e-9cba-62bff712862b
# ╟─010ebe37-782b-4a35-bf5c-dca6dc0fee45
# ╠═d9d14c48-8700-42b5-89b4-7fc51d0f577c
# ╟─8a7cd9ec-5640-4f5f-84c3-ae3f465ca68b
# ╠═028ade5c-17bd-4dfc-8433-23aaff02c181
# ╟─04b4eefb-f0f9-4887-8db0-7cbb7f3b169b
# ╠═21655344-d12b-4e47-a9a9-d06bd909f6ea
# ╠═3b89fe00-6aaf-4764-8b29-e71479f1e641
# ╟─43eac8dd-8f1d-440e-b1e8-85db9e740651
# ╠═b2efafab-8849-4a7a-bb64-ac9ce126ca75
# ╠═ef40112b-f23e-4d4b-8a7d-3793b786f472
# ╟─b823d824-419d-41e9-9ac9-2c45ef190acf
# ╠═93bca93a-5484-47fa-8424-7315eef15e37
# ╠═8f1d32fd-f54b-4f69-8c93-8f0786366cef
# ╠═44132e2e-5a1a-49ad-9e57-cec24f981f52
# ╠═604458a6-7b6f-4b5c-b2e7-09be1908c0f9
# ╠═a34c19e8-ba9e-4276-a17e-c853bb3341cf
# ╠═7ae6c61d-0e33-4af8-b8d2-e31223a15a7c
# ╠═1210443f-480f-4e9f-b195-d557e9e1fc31
# ╠═46711233-f680-4962-9e3e-60c747db4d2c
