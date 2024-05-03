using DrWatson
@quickactivate "Analysis pipeline"

# include AnlysisPipeline module
include(srcdir("AnalysisPipeline.jl"))

@info("""
      Running inference on truth data.

      ---------------------------------------------
      Currently active project is: $(projectname())
      Path of active project: $(projectdir())
      """)

## Set up the truth Rt and save a plot of it
using .AnalysisPipeline, Plots, JLD2, EpiAware, Distributions

wkly_ar = AR(
    damp_priors = [truncated(Normal(0.8, 0.05), 0, 1)],
    std_prior = HalfNormal(1.0),
    init_priors = [Normal(0.0, 0.25)]
) |> ar -> BroadcastLatentModel(ar, 7, RepeatBlock())

wkly_rw = RandomWalk(
    std_prior = HalfNormal(1.0),
    init_prior = Normal(0.0, 0.25)
) |> rw -> BroadcastLatentModel(rw, 7, RepeatBlock())

wkly_diff_ar = AR(
    damp_priors = [truncated(Normal(0.8, 0.05), 0, 1)],
    std_prior = HalfNormal(1.0),
    init_priors = [Normal(0.0, 0.25)]
) |>
               ar -> DiffLatentModel(; model = ar, init_priors = [Normal(0.0, 0.25)]) |>
                     diff_ar -> BroadcastLatentModel(ar, 7, RepeatBlock())

## Parameter settings
sim_configs = Dict(:igp => [DirectInfections, ExpGrowthRate, Renewal],
    :latent_model => [wkly_ar, wkly_rw, wkly_diff_ar],
    :gi_mean => [2.0, 10.0, 20.0], :gi_std => 2.0) |>
    dict_list
