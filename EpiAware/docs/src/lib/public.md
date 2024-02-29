# Public Documentation

Documentation for `EpiAware.jl`'s public interface.

See the Internals section of the manual for internal package docs covering all submodules.

## Contents

```@contents
Pages = ["public.md"]
Depth = 2:2
```

## Index

```@index
Pages = ["public.md"]
```
## Modules

```@docs
EpiAware
```

## Abstract types

```@docs
AbstractModel
AbstractEpiModel
AbstractLatentModel
AbstractObservationModel
```

## Types

```@docs
EpiData
Renewal
ExpGrowthRate
DirectInfections
RandomWalk
```

## Functions

```@docs
make_epi_aware
create_discrete_pmf
spread_draws
scan
```
