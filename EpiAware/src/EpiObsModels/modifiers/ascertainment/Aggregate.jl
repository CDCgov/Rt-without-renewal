struct Aggregate{M <: AbstractTuringLatentModel,} <: AbstractTuringLatentModel
    model::M
    aggregation = [0, 7, 0, 0, 0, 0, 0]
    present = [false, true, false, false, false, false, false]
end

@model function EpiAwareBase.generate_observations(ag::Aggregate, y_t, Y_t)
    if ismissing(y_t)
        y_t = Vector{Real}(0.0, length(Y_t))
    end

    n = length(y_t)
    m = length(ag.aggregation)

    aggregation = broadcast_n(RepeatEach(), ag.aggregation, n, m)
    present = broadcast_n(RepeatEach(), ag.present, n, m)

    agg_Y_t = map(eachindex(aggregation)) do i
        if present[i]
            exp_Y_t = sum(Y_t[min(1, i - aggregation[i] + 1):i])
        else
            exp_Y_t = 0.0
        end
        return exp_Y_t
    end

    @submodel exp_obs = generate_observations(ag.model, y_t[present], agg_Y_t[present])
    return _return_aggregate(exp_obs, y_t, present)
end

function _return_aggregate(exp_obs, y_t, present)
    y_t[present] = exp_obs
    return y_t
end
