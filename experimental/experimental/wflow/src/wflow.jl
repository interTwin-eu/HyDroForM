#!/usr/local/julia/bin/julia

#/usr/bin/env -S julia --project=/env 


using Pkg

Pkg.activate("/app/env");

Pkg.status()

using Comonicon
using Wflow

@main function run(arg)
    @show arg
    Wflow.run(arg)

end

