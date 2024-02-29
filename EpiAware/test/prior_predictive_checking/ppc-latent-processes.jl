#=
# Prior predictive checking for latent processes

## Random walk
Sample from the prior predictive distribution of the random walk process with random noise variance sampled from the default HalfNormal(0.05) distribution.
Plotted as a spaghetti plot against theoretical 3 sigma spread (solved using law of total var).
=#

using Turing, Distributions, StatsPlots, Random
using Plots.PlotMeasures
using EpiAware
Random.seed!(0)
n = 30
latent_model_priors = (var_RW_prior = truncated(Normal(0.0, 0.5), 0.0, Inf),)

model = random_walk(n; latent_model_priors = latent_model_priors)
n_samples = 2000
prior_chn = sample(model, Prior(), n_samples)
sampled_walks = prior_chn |> chn -> mapreduce(hcat, generated_quantities(model, chn)) do gen
    gen[1]
end
## From law of total variance and known mean of HalfNormal distribution
theoretical_std = [t * latent_model_priors.var_RW_prior.untruncated.σ * sqrt(2) / sqrt(π)
                   for t in 1:n] .|> sqrt

plt_ppc_rw = plot(sampled_walks, lab = "", ylabel = "RW", xlabel = "t", c = :grey,
    alpha = 0.1)
plot!(plt_ppc_rw,
    zeros(n),
    lw = 2,
    c = :red,
    lab = "Theoretical 3 sigma spread",
    ribbon = 3 * theoretical_std,
    fillalpha = 0.2)

σ_hist = histogram(prior_chn[:σ²_RW],
    norm = :pdf,
    lab = "",
    ylabel = "Density",
    xlabel = "σ²_RW",
    c = :grey,
    alpha = 0.5)
plot!(σ_hist,
    latent_model_priors.var_RW_prior,
    lw = 2,
    c = :red,
    alpha = 0.5,
    lab = "Prior",
    bins = 100)

plt_rw = plot(plt_ppc_rw,
    σ_hist,
    layout = (1, 2),
    size = (800, 400),
    left_margin = 3mm,
    bottom_margin = 3mm)
savefig(plt_rw, joinpath(@__DIR__(), "assets", "ppc_rw.png"))
