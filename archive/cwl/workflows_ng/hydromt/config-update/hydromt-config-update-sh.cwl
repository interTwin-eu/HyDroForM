cwlVersion: v1.2
class: CommandLineTool
baseCommand: ["bash", "config_gen.sh"]

requirements:
  DockerRequirement:
    dockerPull: potato55/hydromtng:0.1
  InitialWorkDirRequirement:
    listing:
      - entryname: config_gen.sh
        entry: |
          #!/usr/bin/env bash

          set_permissions() {
              chmod 777 "$PWD"
          }

          generate_config() {
              local res=$1
              local precip_fn=$2

              cat <<EOL
          [setup_config]
          starttime = 2001-01-01T00:00:00
          endtime = 2001-03-31T00:00:00
          timestepsec = 86400
          input.path_forcing = forcings.nc

          [setup_basemaps]
          hydrography_fn = merit_hydro_stac
          basin_index_fn = merit_hydro_index
          upscale_method = ihu
          res = $res

          [setup_rivers]
          hydrography_fn = merit_hydro_stac
          river_geom_fn = rivers_lin2019
          river_upa = 30
          rivdph_method = powlaw
          min_rivdph = 1
          min_rivwth = 30
          slope_len = 2000
          smooth_len = 5000

          [setup_lakes]
          lakes_fn = hydrolakes_v10
          min_area = 2.0

          [setup_reservoirs]
          reservoirs_fn = grand_v1.3
          timeseries_fn = gww
          min_area = 0.5

          [setup_glaciers]
          glaciers_fn = rgi60_global
          min_area = 1.0

          [setup_gauges]
          gauges_fn = ado_gauges
          index_col = id
          snap_to_river = True
          derive_subcatch = False

          [setup_lulcmaps]
          lulc_fn = corine_2012
          lulc_mapping_fn = corine_mapping

          [setup_laimaps]
          lai_fn = modis_lai_v061

          [setup_soilmaps]
          soil_fn = soilgrids_2020_stac
          ptf_ksatver = brakensiek

          [setup_precip_forcing]
          precip_fn = $precip_fn
          precip_clim_fn = None
          chunksize = 1

          [setup_temp_pet_forcing]
          temp_pet_fn = cerra_stac
          kin_fn = cerra_land_stac
          press_correction = True
          temp_correction = True
          wind_correction = False
          dem_forcing_fn = cerra_orography
          pet_method = makkink
          skip_pet = False
          chunksize = 1

          [setup_constant_pars]
          KsatHorFrac = 100
          Cfmax = 3.75653
          cf_soil = 0.038
          EoverR = 0.11
          InfiltCapPath = 5
          InfiltCapSoil = 600
          MaxLeakage = 0
          rootdistpar = -500
          TT = 0
          TTI = 2
          TTM = 0
          WHC = 0.1
          G_Cfmax = 5.3
          G_SIfrac = 0.002
          G_TT = 1.3
          EOL
          }

          main() {
              if [ "$#" -ne 2 ]; then
                  echo "Usage: $0 <res> <precip_fn>"
                  exit 1
              fi

              local res=$1
              local precip_fn=$2

              set_permissions

              generate_config "$res" "$precip_fn"

          }

          main "$@"

inputs:
  res:
    type: float
    inputBinding:
      position: 1
  precip_fn:
    type: string
    inputBinding:
      position: 2

outputs:
  wflow_ini:
    type: stdout

stdout: wflow.ini