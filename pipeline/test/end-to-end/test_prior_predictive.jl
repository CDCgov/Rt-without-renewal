using Test, DrWatson
quickactivate(@__DIR__(), "EpiAwarePipeline")

using EpiAwarePipeline, EpiAware, Plots, Turing
pipetype = [SmoothOutbreakPipeline, MeasuresOutbreakPipeline,
    SmoothEndemicPipeline, RoughEndemicPipeline] |> rand

P = pipetype(; testmode = true, nchains = 1, ndraws = 2000, priorpredictive = true)

##

inference_config = make_inference_configs(P) |> first

missingdata = Dict("y_t" => missing, "I_t" => fill(1.0, 100), "truth_I0" => 1.0,
    "truth_gi_mean" => inference_config.gi_mean)
results = generate_inference_results(missingdata, inference_config, P)

res = results["inference_results"]

gens = generate_quantiles_for_targets(
    res, results["epiprob"].epi_model.data, [0.025, 0.25, 0.5, 0.75, 0.975])

gens.log_I_t

##
using CairoMakie

function _make_prior_plot_title(config)
    igp_str = string(config.igp)
    latent_model_str = config.latent_model_name |> uppercase
    gi_mean_str = config.gi_mean |> string
    T_str = config.tspan[2] |> string
    return "Prior pred. IGP: $(igp_str), latent model: $(latent_model_str), truth gi mean: $(gi_mean_str), T: $(T_str)"
end
_make_prior_plot_title(config)

function _setup_levels(ps)
    n_levels = length(ps)
    qs = mapreduce(vcat, ps) do percentile
        [percentile / 2, 1 - percentile / 2]
    end |> x -> [0.5; x]
    return qs, n_levels
end
##
# _get_priorpred_plot_title(results["inference_config"])
##

function prior_predictive_plot(config, output, epiprob;
        ps = [0.05, 0.1, 0.25],
        bottom_alpha = 0.1,
        top_alpha = 0.5,
        case_color = :black,
        logI_color = :purple,
        rt_color = :blue,
        Rt_color = :green,
        figsize = (750, 600))
    @assert all(0 .<= ps .< 0.5) "Percentiles must be in the range [0, 0.5)"
    prior_pred_plot_title = _make_prior_plot_title(config)
    qs, n_levels = _setup_levels(sort(ps))
    opacity_scale = range(bottom_alpha, top_alpha, length = n_levels) |> collect

    # Create the figure and axes
    fig = Figure(size = figsize)
    ax11 = Axis(fig[1, 1]; xlabel = "t", ylabel = "Cases")
    ax12 = Axis(fig[1, 2]; xlabel = "t", ylabel = "log(Incidence)")
    ax21 = Axis(fig[2, 1]; xlabel = "t", ylabel = "Exp. growth rate")
    ax22 = Axis(fig[2, 2]; xlabel = "t", ylabel = "Reproduction number")
    linkxaxes!(ax11, ax21)
    linkxaxes!(ax12, ax22)
    Label(fig[0, :]; text = prior_pred_plot_title, fontsize = 16)

    # Quantile calculations
    gen_y_t = mapreduce(hcat, output.generated) do gen
        gen.generated_y_t
    end |> X -> timeseries_samples_into_quantiles(X, qs)
    gen_quantities = generate_quantiles_for_targets(output, epiprob.epi_model.data, qs)

    # Plot the prior predictive samples
    # Cases
    f = findfirst(!ismissing, gen_y_t[:, 1])
    lines!(ax11, 1:size(gen_y_t, 1), gen_y_t[:, 1],
        color = case_color, linewidth = 3, label = "Median")
    for i in 1:n_levels
        band!(ax11, f:size(gen_y_t, 1), gen_y_t[f:size(gen_y_t, 1), (2 * i)],
            gen_y_t[f:size(gen_y_t, 1), (2 * i) + 1],
            color = (case_color, opacity_scale[i]),
            label = "($(ps[i]*100)-$((1 - ps[i])*100))%")
    end
    vlines!(ax11, [f], color = case_color, linestyle = :dash, label = "Obs. window")
    axislegend(ax11; position = :lt, framevisible = false)

    # Other quantities
    for (ax, target, c) in zip(
        [ax12, ax21, ax22], [gen_quantities.log_I_t, gen_quantities.rt, gen_quantities.Rt],
        [logI_color, rt_color, Rt_color])
        lines!(ax, 1:size(target, 1), target[:, 1],
            color = logI_color, linewidth = 3, label = "Median")
        for i in 1:n_levels
            band!(ax, 1:size(target, 1), target[:, (2 * i)], target[:, (2 * i) + 1],
                color = (c, opacity_scale[i]), label = "")
        end
    end

    fig
end

##
fig = prior_predictive_plot(config, res, results["epiprob"]; ps = [0.025, 0.1, 0.25])
##
gen_y_t = mapreduce(hcat, res.generated) do gen
    gen.generated_y_t
end |> X -> timeseries_samples_into_quantiles(X, [0.025, 0.25, 0.5, 0.75, 0.975])

##
fig = Figure()
ax_logIt = Axis(fig[1, 1];
    xticks = vcat(1, 5:5:50)    # xlabel
)

for i in 1:5
    lines!(ax_logIt, gen_y_t[:, i], color = :black, alpha = 0.5)
end

# hlines!(ax, [1.0], color = :red, linestyle = :dash)
fig
