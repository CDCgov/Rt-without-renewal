"""
Internal method for creating a path/name for a plot. This also creates the directory
if it does not exist.
"""
function _mkplotpath(pipeline::AbstractEpiAwarePipeline, config, plotsubdir)
    !isdir(plotsdir(plotsubdir)) ? mkdir(plotsdir(plotsubdir)) : nothing
    _plotsname = _simulate_prefix(pipeline)
    return plotsdir(plotsubdir, savename(_plotsname, config, "png"))
end

"""
Plot the true cases and latent infections. This is the default method for plotting.

# Arguments
- `data`: A dictionary containing the data for plotting.
- `config`: The configuration for the truth data scenario.
- `pipeline::AbstractEpiAwarePipeline`: The pipeline object which sets pipeline
    behavior.
- `plotsubdir`: The subdirectory to save the plot.
- `saveplot`: A boolean indicating whether to save the plot.

# Returns
- `f`: The plot object representing the cases and latent infections.
- `plotpath`: The path of the plot.
"""
function plot_truth_data(data, config, pipeline::AbstractEpiAwarePipeline;
        plotsubdir = "truth_data", saveplot = true, kwargs...)
    f = Figure(; backgroundcolor = :white)
    ax = Axis(f[1, 1],
        title = "Cases and latent infections",
        xlabel = "Time",
        ylabel = "Daily cases",
        kwargs...
    )
    scatter!(ax, data["y_t"], color = :black, label = "Daily cases")
    lines!(ax, data["I_t"], label = "True latent infections", color = :red,
        linestyle = :dash)
    axislegend(position = :rt, framevisible = false, backgroundcolor = (:white, 0.0))

    plotpath = _mkplotpath(pipeline, config, plotsubdir)
    saveplot && CairoMakie.save(plotpath, f)
    return f, plotpath
end

"""
Plot and save the plot of the true Rt values over time.

# Arguments
- `true_Rt`: An array of true Rt values.
- `config`: A scenario configuration.
- `pipeline::AbstractEpiAwarePipeline`: The pipeline object which sets pipeline
    behavior.
- `plotsubdir`: The subdirectory to save the plot.
- `saveplot`: A boolean indicating whether to save the plot.

# Returns
- `f`: The plot object representing the cases and latent infections.
- `plotpath`: The path of the plot.

"""
function plot_Rt(true_Rt, config, pipeline::AbstractEpiAwarePipeline; plotsubdir = "truth_data", saveplot = true)
    f = Figure(; backgroundcolor = :white)
    ax = Axis(f[1, 1],
        title = "True Reproduction number",
        xlabel = "Time",
        ylabel = "Rt",
    )
    lines!(ax, true_Rt)

    plotpath = EpiAwarePipeline._mkplotpath(pipeline, config, plotsubdir)
    saveplot && CairoMakie.save(plotpath, f)
    return f, plotpath
end
