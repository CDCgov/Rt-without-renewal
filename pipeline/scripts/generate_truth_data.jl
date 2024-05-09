using DrWatson
@quickactivate "Analysis pipeline"

# include AnlysisPipeline module
include(srcdir("AnalysisPipeline.jl"))
include(scriptsdir("common_param_values.jl"));

@info("""
      Generating truth data for the `Rt-without-renewal` project.

      ---------------------------------------------
      Currently active project is: $(projectname())
      Path of active project: $(projectdir())
      """)

## Set up the truth Rt and save a plot of it

using .AnalysisPipeline, Plots, JLD2

plt_Rt = plot(1:N, true_Rt, label = "True Rt", xlabel = "Time", ylabel = "Rt",
    title = "True Rt", legend = :topright);

savefig(plt_Rt, plotsdir("truth_data", "true_Rt"));

## Parameter settings

sim_configs = Dict(:gi_mean => gi_means, :gi_std => gi_stds) |> dict_list .|>
              d -> TruthSimulationConfig(
                  truth_process = true_Rt, gi_mean = d[:gi_mean], gi_std = d[:gi_std])

## Generate the truth data

for config in sim_configs
    data, file = produce_or_load(
        simulate_or_infer, config, datadir("truth_data"); prefix = "truth_data")
    plt_cases = scatter(
        1:N, data["y_t"], label = "Cases", xlabel = "Time", ylabel = "Daily cases",
        title = "Cases and latent infections", legend = :bottomright)
    plot!(plt_cases, 1:N, data["I_t"], label = "True latent infections")

    savefig(plt_cases, plotsdir("truth_data", savename("truth_cases", config, "png")))
end
