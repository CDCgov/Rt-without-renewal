# Analysis pipeline overview

An overview of the purpose of this pipeline is:

1. Generate cases from a defined gold standard model to act as synthetic "truth" data.
2. Build a matrix set of scenario models, defined using `EpiAware`.
3. Run inference on each scenario model using `EpiAware`. This will be done using the No U-Turns Sampler (NUTS) algorithm.
4. Compare inferred time-varying reproductive number and forecasts to the truth data to evaluate the performance of the inference, and/or forecast.

## Synthetic truth data

We generate three truth data sets, each with the same time-varying reproductive number $R_t$ but with three different generation intervals $g$.

### "Truth" Reproductive Number

The baseline "truth" for the $R_t$ is piecewise constant followed by oscillating over 160 days. The values are:

- 1.1 for two weeks.
- 2 for two weeks.
- 0.5 for two weeks.
- 1.5 for two weeks.
- 0.75 for two weeks.
- 1.1 for six weeks.
- Sine curve centered at 1 with amplitude of 0.3 afterwards.

### Generation Intervals

The generation intervals are:
- *Short:* We use a Gamma(shape = 2, scale = 1), corresponding to a pathogen with a relatively short generation interval.
- *Medium:* We use a Gamma(shape = 2, scale = 5).
- *Long:* We use a Gamma(shape = 2, scale = 10), corresponding to a pathogen with a moderately long generation interval.

## Scenario models

Each model in the scenario matrix is defined by a structural combination of choice of infection-generating process (IGP), choice of latent process model driving the infection-generating process, and possible misspecification of the generation interval. The models are defined using `EpiAware`. In this analysis we assume that the observation model is correctly specified.

### Infection-generating processes

We consider three infection-generating processes:
- *Direct infections*. The underlying IGP is directly a latent process.
- *Exponential growth*. The underlying IGP is determined by the time-varying exponential growth rate $r_t$ being modelled as a latent process.
- *Renewal*. The underlying IGP is a Renewal process determined by the time-varying reproductive number $R_t$ being modelled as a latent process.

### Latent process models

We consider three latent process models:
- *Random walk*. The latent process is modelled as a random walk.
- *AR(p)*. The latent process is modelled as an AR(p) process with $p=1,2$.
- *Differenced AR(p)*. The latent process is modelled as a differenced AR(p) process with $p=1,2$.

### Generation interval misspecification

We consider three types of (mis)specification of the generation interval:
- *Correct*. The generation interval is correctly specified.
- *Short*. The generation interval is misspecified as short.
- *Long*. The generation interval is misspecified as long.

## Model scoring

We score each scenario model in two ways:
- *Inferred $R_t$*. We compare the inferred $R_t$ to the truth process using summed CRPS over time steps.
- *Forecasts*. We compare the forecasts of the number of cases, aggregated in weeks, to the truth aggregated data using summed CRPS over forecast time steps.

## Running the pipeline

The pipeline structure is built using [DrWatson.jl](https://github.com/JuliaDynamics/DrWatson.jl) for project management of simulation parameters/settings, saved results, and figures. Compute is done with [Dagger.jl](https://github.com/JuliaParallel/Dagger.jl) for organizing parallel computation and checkpointing of results.
