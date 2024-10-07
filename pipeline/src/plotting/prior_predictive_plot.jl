"""
Internal method for generating a title string for a prior predictive plot based on the provided
    configuration.

# Arguments
- `config::InferenceConfig`: `InferenceConfig` object containing the configuration for the
    prior predictive plot.
# Returns
- `String`: A formatted title string for the prior predictive plot.

"""
function _make_prior_plot_title(config::InferenceConfig)
    igp_str = string(config.igp)
    latent_model_str = config.latent_model_name |> uppercase
    gi_mean_str = config.gi_mean |> string
    T_str = config.tspan[2] |> string
    return "Prior pred. IGP: $(igp_str), latent model: $(latent_model_str), truth gi mean: $(gi_mean_str), T: $(T_str)"
end

"""
Generate a prior predictive plot for the given configuration, output, and epidemiological probabilities.

# Arguments
- `config`: Configuration object containing settings for the plot.
- `output`: Output object containing generated data for plotting.
- `epiprob`: Epidemiological probabilities object.
- `ps`: Array of percentiles for quantile calculations (default: [0.05, 0.1, 0.25]).
- `bottom_alpha`: Opacity for the lowest percentile band (default: 0.1).
- `top_alpha`: Opacity for the highest percentile band (default: 0.5).
- `case_color`: Color for the cases plot (default: :black).
- `logI_color`: Color for the log(Incidence) plot (default: :purple).
- `rt_color`: Color for the exponential growth rate plot (default: :blue).
- `Rt_color`: Color for the reproduction number plot (default: :green).
- `figsize`: Tuple specifying the size of the figure (default: (750, 600)).

# Returns
- `fig`: A Figure object containing the prior predictive plots.

# Notes
- The function asserts that all percentiles in `ps` are in the range [0, 0.5).
- The function creates a 2x2 grid of subplots with linked x-axes for the top and bottom rows.
- The function plots the median and percentile bands for cases, log(Incidence), exponential growth rate, and reproduction number.
"""
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
