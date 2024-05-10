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
    plt_cases = scatter(data["y_t"], label = "Cases", xlabel = "Time", ylabel = "Daily cases",
        title = "Cases and latent infections", legend = :bottomright)
    plot!(plt_cases, data["I_t"], label = "True latent infections")

    if !isdir(plotsdir("truth_data"))
        mkdir(plotsdir("truth_data"))
    end

    savefig(plt_cases, plotsdir("truth_data", savename("truth_cases", config, "png")))
    return plt_cases
end
