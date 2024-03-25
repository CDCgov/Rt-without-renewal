abstract type BroadcastRule end
struct RepeatEach <: BroadcastRule end
struct RepeatBlock <: BroadcastRule end

struct BroadcastLatentModel{M <: AbstractLatentModel, P <: Int, B <: BroadcastRule} <:
       AbstractLatentModel
    model::M
    period::P
    broadcast_rule::B
    function BroadcastLatentModel(model::M; period::Int,
            broadcast_rule::B) where {M <: AbstractLatentModel, B <: BroadcastRule}
        @assert period>0 "period must be greater than 0"
        new{typeof(model), typeof(period), typeof(broadcast_rule)}(
            model, period, broadcast_rule)
    end

    function BroadcastLatentModel(model::M, period::Int,
            broadcast_rule::B) where {M <: AbstractLatentModel, B <: BroadcastRule}
        @assert period>0 "period must be greater than 0"
        new{typeof(model), typeof(period), typeof(broadcast_rule)}(
            model, period, broadcast_rule)
    end
end

function broadcast_rule(::BroadcastRule)
    error("broadcast_rule not implemented")
end

function broadcast_rule(::RepeatEach, latent, n, period)
    latent = repeat(latent, outer = ceil(Int, n / period))
    return latent[1:n]
end

function broadcast_rule(::RepeatBlock, latent, n, period)
    indices = [ceil(Int, i / period) for i in 1:n]
    return latent[indices]
end

@model function EpiAwareBase.generate_latent(model::BroadcastLatentModel, n)
    @submodel latent_period, latent_period_aux = generate_latent(model.model, model.period)
    broadcasted_latent = broadcast_rule(
        model.broadcast_rule, latent_period, n, model.period)
    return broadcasted_latent, (; latent_period_aux...)
end
