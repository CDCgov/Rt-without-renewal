@doc raw"
The `BroadcastLatentModel` struct represents a latent model that supports broadcasting of latent periods.

## Constructors
- `BroadcastLatentModel(;model::M; period::Int, broadcast_rule::B)`: Constructs a `BroadcastLatentModel` with the given `model`, `period`, and `broadcast_rule`.
- `BroadcastLatentModel(model::M, period::Int, broadcast_rule::B)`: An alternative constructor that allows the `model`, `period`, and `broadcast_rule` to be specified without keyword arguments.

## Examples
```julia
using EpiAware, Turing
each_model = BroadcastLatentModel(RandomWalk(), 7, RepeatEach())
gen_each_model = generate_latent(each_model, 10)
rand(gen_each_model)

block_model = BroadcastLatentModel(RandomWalk(), 3, RepeatBlock())
gen_block_model = generate_latent(block_model, 10)
rand(gen_block_model)
```
"
struct BroadcastLatentModel{
    M <: AbstractTuringLatentModel, P <: Integer, B <: AbstractBroadcastRule} <:
       AbstractTuringLatentModel
    "The underlying latent model."
    model::M
    "The period of the broadcast."
    period::P
    "The broadcast rule to be applied."
    broadcast_rule::B

    function BroadcastLatentModel(model::M, period::Integer,
            broadcast_rule::B) where {
            M <: AbstractTuringLatentModel, B <: AbstractBroadcastRule}
        @assert period>0 "period must be greater than 0"
        new{typeof(model), typeof(period), typeof(broadcast_rule)}(
            model, period, broadcast_rule)
    end
end

function BroadcastLatentModel(model::M; period::Integer,
        broadcast_rule::B) where {
        M <: AbstractTuringLatentModel, B <: AbstractBroadcastRule}
    BroadcastLatentModel(model, period, broadcast_rule)
end

@doc raw"
Generates latent periods using the specified `model` and `n` number of samples.

## Arguments
- `model::BroadcastLatentModel`: The broadcast latent model.
- `n::Any`: The number of samples to generate.

## Returns
- `broadcasted_latent`: The generated broadcasted latent periods.

"
@model function EpiAwareBase.generate_latent(model::BroadcastLatentModel, n)
    m = broadcast_n(model.broadcast_rule, n, model.period)
    @submodel latent_period = generate_latent(model.model, m)
    broadcasted_latent = broadcast_rule(
        model.broadcast_rule, latent_period, n, model.period)
    return broadcasted_latent
end
