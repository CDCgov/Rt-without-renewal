# Run inference for random scenario
using Test, DrWatson
quickactivate(@__DIR__(), "EpiAwarePipeline")

using EpiAwarePipeline, EpiAware, Plots, Turing
pipetype = [SmoothOutbreakPipeline, MeasuresOutbreakPipeline,
    SmoothEndemicPipeline, RoughEndemicPipeline] |> rand

P = SmoothOutbreakPipeline(; testmode = true, nchains = 1)
truthdata = fetch.(do_truthdata(P)) |> first

cs = 1:length(truthdata["y_t"]) .|> t -> t % 7 ∈ [1, 2, 3, 4, 5] ? 1 : 2
p_data = truthdata["y_t"] |> y_t -> scatter(y_t, c = [ones(5); 2 * ones(2)])

inference_method = make_inference_method(P)
inference_config = make_inference_configs(P) |> first
# inference_config["T"] = 35

results = generate_inference_results(
    truthdata, inference_config, P; inference_method)
##
inf_results = results["inference_results"]
ts = max(inference_config["T"] - inference_config["lookback"], 1):inference_config["T"] |>
     collect
plt_labs = hcat(fill("", 1, 2), ["forecast quantiles"], fill("", 1, 2))
##
forecast_I_t = mapreduce(hcat, inf_results.generated) do gen
    gen.I_t
end |>
               mat -> mapreduce(hcat, [0.025, 0.25, 0.5, 0.75, 0.975]) do q
    map(eachrow(mat)) do row
        if any(ismissing, row)
            return missing
        else
            quantile(row, q)
        end
    end
end
plt = scatter(xlabel = "t", ylabel = "I_t")

plot!(plt, truthdata["I_t"], label = "truth I_t", lw = 3, c = :red)
plot!(plt, ts, forecast_I_t, label = plt_labs,
    color = :grey, lw = [0.5 1.5 3 1.5 0.5])
scatter!(plt, truthdata["y_t"], label = "obs. data", c = :green)

## Calculate processes

function calculate_processes(I_t, I0, data::EpiData)
    log_I_t = _calc_log_infections(I_t)
    rt = _calc_rt(I_t, I0)
    Rt = _calc_Rt(I_t, I0, data)
    return (; log_I_t, rt, Rt, I_t, log_Rt = log.(Rt))
end

##

forecast_R_t = mapreduce(hcat, inf_results.generated) do gen
    gen.I_t
end |>
               mat -> mapreduce(hcat, [0.025, 0.25, 0.5, 0.75, 0.975]) do q
    map(eachrow(mat)) do row
        if any(ismissing, row)
            return missing
        else
            quantile(row, q)
        end
    end
end
plt_Z_t = scatter(xlabel = "t", ylabel = "Z_t")
plot!(plt_Z_t, ts, forecast_Z_t, label = plt_labs,
    color = :grey, lw = [0.5 1.5 3 1.5 0.5])
scatter!(plt, truthdata["truth_process"], label = "truth I_t")

##

@test results["inference_results"] isa EpiAwareObservables
# @test results["forecast_results"] isa EpiAwareObservables
