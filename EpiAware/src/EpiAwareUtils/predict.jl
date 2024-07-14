
"""
    struct MiniBatchContext{Tctx, T} <: AbstractContext
        context::Tctx
        loglike_scalar::T
    end

The `MiniBatchContext` enables the computation of
`log(prior) + s * log(likelihood of a batch)` when running the model, where `s` is the
`loglike_scalar` field, typically equal to `the number of data points / batch size`.
This is useful in batch-based stochastic gradient descent algorithms to be optimizing
`log(prior) + log(likelihood of all the data points)` in the expectation.
"""
struct PredictContext{Tctx <: DynamicPPL.AbstractContext} <: DynamicPPL.AbstractContext
    context::Tctx
end
DynamicPPL.NodeTrait(context::PredictContext) = DynamicPPL.IsParent()
DynamicPPL.childcontext(context::PredictContext) = context.context
function DynamicPPL.setchildcontext(parent::PredictContext, child)
    return PredictContext(child)
end

"""

    predict([rng::AbstractRNG,] model::Model, chain::MCMCChains.Chains; include_all=false)

Execute `model` conditioned on each sample in `chain`, and return the resulting `Chains`.

If `include_all` is `false`, the returned `Chains` will contain only those variables
sampled/not present in `chain`.

# Details
Internally calls `Turing.Inference.transitions_from_chain` to obtained the samples
and then converts these into a `Chains` object using `AbstractMCMC.bundle_samples`.

# Example
```jldoctest
julia> using Turing; Turing.setprogress!(false);
[ Info: [Turing]: progress logging is disabled globally

julia> @model function linear_reg(x, y, σ = 0.1)
           β ~ Normal(0, 1)

           for i ∈ eachindex(y)
               y[i] ~ Normal(β * x[i], σ)
           end
       end;

julia> σ = 0.1; f(x) = 2 * x + 0.1 * randn();

julia> Δ = 0.1; xs_train = 0:Δ:10; ys_train = f.(xs_train);

julia> xs_test = [10 + Δ, 10 + 2 * Δ]; ys_test = f.(xs_test);

julia> m_train = linear_reg(xs_train, ys_train, σ);

julia> chain_lin_reg = sample(m_train, NUTS(100, 0.65), 200);
┌ Info: Found initial step size
└   ϵ = 0.003125

julia> m_test = linear_reg(xs_test, Vector{Union{Missing, Float64}}(undef, length(ys_test)), σ);

julia> predictions = predict(m_test, chain_lin_reg)
Object of type Chains, with data of type 100×2×1 Array{Float64,3}

Iterations        = 1:100
Thinning interval = 1
Chains            = 1
Samples per chain = 100
parameters        = y[1], y[2]

2-element Array{ChainDataFrame,1}

Summary Statistics
  parameters     mean     std  naive_se     mcse       ess   r_hat
  ──────────  ───────  ──────  ────────  ───────  ────────  ──────
        y[1]  20.1974  0.1007    0.0101  missing  101.0711  0.9922
        y[2]  20.3867  0.1062    0.0106  missing  101.4889  0.9903

Quantiles
  parameters     2.5%    25.0%    50.0%    75.0%    97.5%
  ──────────  ───────  ───────  ───────  ───────  ───────
        y[1]  20.0342  20.1188  20.2135  20.2588  20.4188
        y[2]  20.1870  20.3178  20.3839  20.4466  20.5895


julia> ys_pred = vec(mean(Array(group(predictions, :y)); dims = 1));

julia> sum(abs2, ys_test - ys_pred) ≤ 0.1
true
```
"""
function predict(model::Model, chain::MCMCChains.Chains; kwargs...)
    return predict(Random.default_rng(), model, chain; kwargs...)
end
function predict(
        rng::AbstractRNG, model::Model, chain::MCMCChains.Chains; include_all = false)
    # Don't need all the diagnostics
    chain_parameters = MCMCChains.get_sections(chain, :parameters)

    spl = DynamicPPL.SampleFromPrior()
    cxt = PredictContext(DynamicPPL.DefaultContext())
    # Sample transitions using `spl` conditioned on values in `chain`
    transitions = transitions_from_chain(
        rng, model, chain_parameters; sampler = spl, context = cxt)

    # Let the Turing internals handle everything else for you
    chain_result = reduce(
        MCMCChains.chainscat, [AbstractMCMC.bundle_samples(
                                   transitions[:, chain_idx],
                                   model,
                                   spl,
                                   nothing,
                                   MCMCChains.Chains
                               ) for chain_idx in 1:size(transitions, 2)]
    )

    parameter_names = if include_all
        names(chain_result, :parameters)
    else
        filter(k -> ∉(k, names(chain_parameters, :parameters)),
            names(chain_result, :parameters))
    end

    return chain_result[parameter_names]
end

"""

    transitions_from_chain(
        [rng::AbstractRNG,]
        model::Model,
        chain::MCMCChains.Chains;
        sampler = DynamicPPL.SampleFromPrior()
    )

Execute `model` conditioned on each sample in `chain`, and return resulting transitions.

The returned transitions are represented in a `Vector{<:Turing.Inference.Transition}`.

# Details

In a bit more detail, the process is as follows:
1. For every `sample` in `chain`
   1. For every `variable` in `sample`
      1. Set `variable` in `model` to its value in `sample`
   2. Execute `model` with variables fixed as above, sampling variables NOT present
      in `chain` using `SampleFromPrior`
   3. Return sampled variables and log-joint

# Example
```julia-repl
julia> using Turing

julia> @model function demo()
           m ~ Normal(0, 1)
           x ~ Normal(m, 1)
       end;

julia> m = demo();

julia> chain = Chains(randn(2, 1, 1), ["m"]); # 2 samples of `m`

julia> transitions = Turing.Inference.transitions_from_chain(m, chain);

julia> [Turing.Inference.getlogp(t) for t in transitions] # extract the logjoints
2-element Array{Float64,1}:
 -3.6294991938628374
 -2.5697948166987845

julia> [first(t.θ.x) for t in transitions] # extract samples for `x`
2-element Array{Array{Float64,1},1}:
 [-2.0844148956440796]
 [-1.704630494695469]
```
"""
function transitions_from_chain(
        model::Turing.Model,
        chain::MCMCChains.Chains;
        kwargs...
)
    return transitions_from_chain(Random.default_rng(), model, chain; kwargs...)
end

function transitions_from_chain(
        rng::Random.AbstractRNG,
        model::Turing.Model,
        chain::MCMCChains.Chains;
        sampler = DynamicPPL.SampleFromPrior(),
        context = PredictContext()
)
    vi = Turing.VarInfo(model)

    iters = Iterators.product(1:size(chain, 1), 1:size(chain, 3))
    transitions = map(iters) do (sample_idx, chain_idx)
        # Set variables present in `chain` and mark those NOT present in chain to be resampled.
        DynamicPPL.setval_and_resample!(vi, chain, sample_idx, chain_idx)
        model(rng, vi, sampler, context)

        # Convert `VarInfo` into `NamedTuple` and save.
        Turing.Inference.Transition(model, vi)
    end

    return transitions
end
