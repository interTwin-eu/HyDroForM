using Pkg;Pkg.instantiate()

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

   println(runconfig.output.path, runconfig.input.forcing_path)

  Wflow.run(runconfig)

 end

 main()
