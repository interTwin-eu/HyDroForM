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

#  config = Wflow.Config()

   args = parse_commandline()

   runconfig = args["runconfig"]
#  forcing = args["forcing"]

  
#  config.output.path = joinpath("/data",output)
#  config.input.forcing_path = joinpath("/data",forcing)
  
#  println(config.output.path, config.input.forcing_path)

  Wflow.run(runconfig)

 end

 main()
