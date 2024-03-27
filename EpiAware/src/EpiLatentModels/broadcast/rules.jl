@doc raw"
`RepeatEach` is a struct that represents a broadcasting rule. It is a subtype of `AbstractBroadcastRule`.

It repeats the latent process at each period. An example of this rule is to repeat the latent process at each day of the week (though for this we also provide the `dayofweek` helper function).

## Examples
```julia
using EpiAware
rule = RepeatEach()
latent = [1, 2, 3]
n = 10
period = 2
broadcast_rule(rule, latent, n, period)
```
"
struct RepeatEach <: AbstractBroadcastRule end

@doc raw"
A function that returns the length of the latent periods to generate using the `RepeatEach` rule which is equal to the period.

## Arguments
- `rule::RepeatEach`: The broadcasting rule.
- `n`: The number of samples to generate.
- `period`: The period of the broadcast.

## Returns
- `m`: The length of the latent periods to generate.
"
function EpiAwareBase.broadcast_n(::RepeatEach, n, period)
    m = period
    return m
end

@doc raw"
`broadcast_rule` is a function that applies the `RepeatEach` rule to the latent process `latent` to generate `n` samples.

## Arguments
- `rule::RepeatEach`: The broadcasting rule.
- `latent::Vector`: The latent process.
- `n`: The number of samples to generate.
- `period`: The period of the broadcast.

## Returns
- `latent`: The generated broadcasted latent periods.
"
function EpiAwareBase.broadcast_rule(::RepeatEach, latent, n, period)
    @assert length(latent)==period "length(latent) must be equal to period"
    broadcast_latent = repeat(latent, outer = ceil(Int, n / period))
    return broadcast_latent[1:n]
end

@doc raw"
`RepeatBlock` is a struct that represents a broadcasting rule. It is a subtype of `AbstractBroadcastRule`.

It repeats the latent process in blocks of size `period`. An example of this rule is to repeat the latent process in blocks of size 7 to model a weekly process (though for this we also provide the `weekly` helper function).

## Examples
```julia
using EpiAware
rule = RepeatBlock()
latent = [1, 2, 3, 4, 5]
n = 10
period = 2
broadcast_rule(rule, latent, n, period)
```
"
struct RepeatBlock <: AbstractBroadcastRule end

@doc raw"
A function that returns the length of the latent periods to generate using the `RepeatBlock` rule which is equal n divided by the period and rounded up to the nearest integer.

## Arguments
- `rule::RepeatBlock`: The broadcasting rule.
- `n`: The number of samples to generate.
- `period`: The period of the broadcast.
"
function EpiAwareBase.broadcast_n(::RepeatBlock, n, period)
    m = ceil(Int, n / period)
    return m
end

@doc raw"
`broadcast_rule` is a function that applies the `RepeatBlock` rule to the latent process `latent` to generate `n` samples.

## Arguments
- `rule::RepeatBlock`: The broadcasting rule.
- `latent::Vector`: The latent process.
- `n`: The number of samples to generate.
- `period`: The period of the broadcast.

## Returns
- `latent`: The generated broadcasted latent periods.
"
function EpiAwareBase.broadcast_rule(::RepeatBlock, latent, n, period)
    @assert n<=period * length(latent) "n must be less than or equal to period * length(latent)"
    broadcast_latent = [latent[j] for j in 1:length(latent) for i in 1:period]
    return broadcast_latent[1:n]
end
