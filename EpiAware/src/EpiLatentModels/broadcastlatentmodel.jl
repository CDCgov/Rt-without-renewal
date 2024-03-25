struct RepeatEach end
struct RepeatBlock end

struct BroadcastLatentModel{M, B, P} <: AbstractLatentModel
    model::M
    period::Int
    broadcast_rule::B
    function BroadcastLatentModel(model::M, period::Int, broadcast_rule::B) where {M, B}
        @assert period > 0 "period must be greater than 0"
        new{M, B, typeof(period)}(model, period, broadcast_rule)
    end
end

# Outer constructor for DayOfWeek
function DayOfWeek(model::BroadcastLatentModel)
    return BroadcastLatentModel(model, 7, RepeatEach())
end

# Outer constructor for Weekly
function Weekly(model)
    return BroadcastLatentModel(model, 7, RepeatBlock())
end

function generate_latent(model::BroadcastLatentModel{<:Any, RepeatEach, <:Any}, n::Int)
    latent_period = generate_latent(model.model, model.period)
    broadcasted_latent = repeat(latent_period, outer = ceil(Int, n / model.period))
    return broadcasted_latent[1:n]
end

function generate_latent(model::BroadcastLatentModel<:Any, RepeatBlock, <:Any}, n::Int)
    latent_period = generate_latent(model.model, model.period)
    indices = [ceil(Int, i / model.period) for i in 1:n]
    broadcasted_latent = latent_period[indices]
    return broadcasted_latent
end
