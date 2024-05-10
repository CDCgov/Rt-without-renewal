## Set up the truth Rt and save a plot of it
# Set up the EpiAware models to use for inference.
using .AnalysisPipeline, Plots, EpiAware, Distributions

## Parameter settings
# Rolled out to a vector of inference configurations using `dict_list`.

sim_configs = Dict(:igp => [DirectInfections, ExpGrowthRate, Renewal],
    :latent_model => [wkly_ar, wkly_rw, wkly_diff_ar],
    :gi_mean => gi_means, :gi_std => gi_stds) |> dict_list
