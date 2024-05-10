"""
    plot_truth_data(data, config)

Plot the true cases and latent infections.

# Arguments
- `data`: A dictionary containing the data for plotting.
- `config`: The configuration for the truth data scenario.

# Returns
- `plt_cases`: The plot object representing the cases and latent infections.
"""
function plot_truth_data(data, config)
    plt_cases = scatter(
        data["y_t"], label = "Cases", xlabel = "Time", ylabel = "Daily cases",
        title = "Cases and latent infections", legend = :bottomright)
    plot!(plt_cases, data["I_t"], label = "True latent infections")

    if !isdir(plotsdir("truth_data"))
        mkdir(plotsdir("truth_data"))
    end

    savefig(plt_cases, plotsdir("truth_data", savename("truth_cases", config, "png")))
    return plt_cases
end

"""
    plot_Rt(true_Rt)

Plot and save the plot of the true Rt values over time.

# Arguments
- `true_Rt`: An array of true Rt values.

# Returns
- `plt_Rt`: The plot object.

"""
function plot_Rt(true_Rt)
    plt_Rt = plot(true_Rt, label = "True Rt", xlabel = "Time", ylabel = "Rt",
        title = "True Rt", legend = :topright)

    if !isdir(plotsdir("truth_data"))
        mkdir(plotsdir("truth_data"))
    end
    savefig(plt_Rt, plotsdir("truth_data", "true_Rt"))

    return plt_Rt
end
