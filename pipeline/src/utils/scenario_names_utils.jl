"""
Internal method to get a list of truth data scenarios from a vector of pipelines.
"""
function _get_scenario_list(pipelines::Vector{<:AbstractEpiAwarePipeline})
    map(pipelines) do pipeline
        _prefix_from_pipeline(pipeline)
    end
end

"""
Internal method to get a list of truth data mean generation intervals
"""
function _get_truth_mean_gi_string_list(pipelines::Vector{<:AbstractEpiAwarePipeline})
    gi_params = make_gi_params(pipelines[1])
    gi_mean_strs = gi_params["gi_means"] .|> x -> "gi_mean=$(x)"
    gi_mean_strs
end

"""
Internal method to get the scenario from a filename.
"""
function _get_scenario_from_filename(
        filename, pipelines::Vector{<:AbstractEpiAwarePipeline})
    sc_list = _get_scenario_list(pipelines)
    scenario = filter(sc -> occursin(sc, filename), sc_list)[1]
end

"""
Internal method to get the latent model from a filename.
"""
function _get_latent_model_from_filename(filename;
        latent_namemodels::Vector{String} = ["wkly_ar", "wkly_diff_ar", "wkly_rw"])
    latent_model = filter(lm -> occursin(lm, filename), latent_namemodels)[1]
end

"""
Internal method to get the true GI mean from a filename.
"""
function _get_true_gi_mean_from_filename(filename;
        truth_gi_mean_strings::Vector{String} = "truth_gi_mean_" .*
                                                string.([2.0, 10.0, 20.0]))
    true_gi = filter(tgi -> occursin(tgi, filename), truth_gi_mean_strings)[1] |>
              str -> split(str, "_")[end] |> s -> parse(Float64, s)
end

"""
Internal method to get the used GI mean from a filename.
"""
function _get_used_gi_mean_from_filename(filename;
        used_gi_mean_strings::Vector{String} = "_gi_mean=" .*
                                               string.([2.0, 10.0, 20.0]))
    used_gi = filter(ugi -> occursin(ugi, filename), used_gi_mean_strings)[1] |>
              str -> split(str, "=")[end] |> s -> parse(Float64, s)
end
