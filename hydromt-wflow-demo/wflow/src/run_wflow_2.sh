#!/usr/bin/env -S julia --project=/env 


using Pkg

Pkg.activate("/env");

using Comonicon
using Wflow

@main function run(arg)
    @show arg


    Wflow.run(arg)

end

