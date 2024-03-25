#!/bin/sh
julia --threads 4 --project=EpiAware/docs -e 'using Pluto; Pluto.run()'
