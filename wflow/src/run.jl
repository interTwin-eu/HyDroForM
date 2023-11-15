using Pkg;Pkg.instantiate()

using Wflow
using ArgParse




function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--forcing"
            help = "an option with an argument"
	    required = true
        "--output"
            help = "another option with an argument"
	    required = true
    end

    return parse_args(s)
end

function main()

  println("using Wflow!")

  config = Wflow.Config("wflow_sbm.toml")

  args = parse_commandline()

  output = args["output"]
  forcing = args["forcing"]

  
  config.output.path = joinpath("/data",output)
  config.input.forcing_path = joinpath("/data",forcing)
  
  println(config.output.path, config.input.forcing_path)

  Wflow.run(config)

 end

 main()
