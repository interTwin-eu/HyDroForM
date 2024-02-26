using Pkg 

Pkg.instantiate()

# TODO: compile to an executable https://github.com/tshort/StaticCompiler.jl


using Wflow
using ArgParse

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--runconfig"
            help = "an option with an argument"
	    required = true 
    end

    return parse_args(s)
end

function main()

   args = parse_commandline()

   runconfig = args["runconfig"]

   println(runconfig)

  Wflow.run(runconfig)

 end

 main()
