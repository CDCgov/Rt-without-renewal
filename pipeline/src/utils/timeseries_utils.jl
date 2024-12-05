"""
Transforms a matrix of time series samples into quantiles.

This function takes a matrix `X` where each row represents a time series and transforms
    it into a matrix of quantiles. The `qs` argument specifies the quantiles to compute.

# Arguments
- `X`: A matrix of time series samples in shape (num_time_points, num_samples).
- `qs`: A vector of quantiles to compute.

# Returns
A matrix where each row represents the quantiles of a time series.
"""
function timeseries_samples_into_quantiles(X, qs)
    mapreduce(vcat, eachrow(X)) do row
        if any(ismissing, row)
            return fill(missing, length(qs))'
        else
            _row = filter(x -> !isnan(x), row)
            return quantile(_row, qs)'
        end
    end
end

"""
Internal function for reducing a sequence of results from calls to `calculate_processes`.
"""
function _process_reduction(procs_1, procs_2)
    (; log_I_t = hcat(procs_1.log_I_t, procs_2.log_I_t),
        Rt = hcat(procs_1.Rt, procs_2.Rt), rt = hcat(procs_1.rt, procs_2.rt))
end

"""
Generate quantiles for targets based on the output and EpiData.

# Arguments
- `output`: The output containing inference results.
- `D::EpiData`: The `EpiData` object containing data about underlying infection process,
    e.g. the generation interval distribution.
- `qs`: The quantiles to generate.

# Returns
An array of quantiles for each target.

"""
function generate_quantiles_for_targets(output, D::EpiData, qs)
    mapreduce(_process_reduction, output.generated,
        output.samples[:init_incidence]) do gen, logI0
        calculate_processes(gen.I_t, exp(logI0), D)
    end |> res -> map(res) do X
        timeseries_samples_into_quantiles(X, qs)
    end
end

"""
Internal method that given a list of percentiles `ps`, this function calculates the corresponding quantile levels.
This function returns both the `p/2` and `1 - p/2` quantiles for each percentile `p` in `ps`.
# Arguments
- `ps::Vector{Float64}`: A vector of percentiles.

# Returns
- `qs::Vector{Float64}`: A vector of quantile levels, including the median (0.5) and the calculated quantiles based on the input percentiles.
- `n_levels::Int`: The number of input percentiles.

"""
function _setup_levels(ps)
    n_levels = length(ps)
    qs = mapreduce(vcat, ps) do percentile
        [percentile / 2, 1 - percentile / 2]
    end |> x -> [0.5; x]
    return qs, n_levels
end
