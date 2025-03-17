cwlVersion: v1.2
class: CommandLineTool
baseCommand: ["bash", "generate_catalog.sh"]

requirements:
  DockerRequirement:
    dockerPull: potato55/hydromtng:0.1
  InitialWorkDirRequirement:
    listing:
      - entryname: generate_catalog.sh
        entry: |
          #!/usr/bin/env bash
          cat <<EOL > catalog.yaml
          eobs_stac:
            data_type: RasterDataset
            path: https://stac.eurac.edu/collections/EOBSv28
            driver: stac
            driver_kwargs:
              bands: "rr"
            filesystem: http
            crs: 4326
            rename:
              rr: precip
            meta:
              category: meteo
          cerra_land_stac:
            data_type: RasterDataset
            path: https://stac.eurac.edu/collections/CERRA_LAND
            driver: stac
            driver_kwargs:
              bands: ["tp", "ssrd"]
            filesystem: http
            crs: 4326
            rename:
              tp: precip
              ssrd: kin
            meta:
              category: meteo
          cerra_stac:
            data_type: RasterDataset
            path: https://stac.eurac.edu/collections/CERRA
            driver: stac
            driver_kwargs:
              bands: ["t2m","sp"]
            filesystem: http
            crs: 4326
            rename:
              t2m: temp
              sp: press_msl
            meta:
              category: meteo
          cerra_daily:
            data_type: RasterDataset
            path: https://eurac-eo.s3.amazonaws.com/INTERTWIN/HYDROFORM/wflow_forcings/cerra_forcings.nc
            driver: netcdf
            filesystem: http
            crs: 4326
            meta:
              category: meteo
              paper_doi: xx
              paper_ref: xx
              source_url: xx
              source_version: xx
              source_licence: xx
              description: ""
          cerra_orography:
            data_type: RasterDataset
            path: https://stac.eurac.edu/collections/CERRA_LAND_OROGRAPHY
            driver: stac
            driver_kwargs:
              bands: ["orog"]
              static: True
            filesystem: http
            crs: 4326
            meta:
              category: topography
          eobs:
            data_type: RasterDataset
            path: https://eurac-eo.s3.amazonaws.com/INTERTWIN/HYDROFORM/wflow_forcings/eobsv27_forcings.nc
            driver: netcdf 
            filesystem: http
            crs: 4326
            meta:
              category: meteo
              source_version: v27.0
          eobs_v28:
            data_type: RasterDataset
            path: https://eurac-eo.s3.amazonaws.com/INTERTWIN/HYDROFORM/wflow_forcings/eobsv28_forcings.nc
            driver: netcdf 
            filesystem: http
            crs: 4326
            meta:
              category: meteo
              source_version: v28.0
          eobs_orography:
            data_type: RasterDataset
            path: https://eurac-eo.s3.amazonaws.com/INTERTWIN/HYDROFORM/eobsv27/elev_ens_0.1deg_reg_v27.0e.nc
            driver: netcdf 
            filesystem: http
            crs: 4326
            meta:
              category: topography
          dem_merit:
            data_type: RasterDataset
            path: https://eurac-eo.s3.amazonaws.com/INTERTWIN/HYDROFORM/wflow_hydrography/elevtn.tif
            driver: raster
            filesystem: http
            crs: 4326
            meta:
              category: topography
          merit_hydro_stac:
            data_type: RasterDataset
            path: https://stac.eurac.edu/collections/MERIT_HYDRO
            driver: stac
            driver_kwargs:
              bands: ["basins","elevtn","flwdir","lndslp","rivmsk","strord","uparea"]
              static: True
            filesystem: http
            crs: 4326
            meta:
              category: hydrography
          merit_hydro_index:
            data_type: GeoDataFrame
            path: https://eurac-eo.s3.amazonaws.com/INTERTWIN/HYDROFORM/wflow_basins/merit_hydro_index.gpkg
            driver: vector
            filesystem: http
            meta:
              category: hydrography
          modis_lai_v061:
            data_type: RasterDataset
            path: https://stac.eurac.edu/collections/MODIS_LAI
            driver: stac
            driver_kwargs:
              bands: ["LAI"]
            filesystem: http
            crs: 4326
            unit_mult:
              LAI: 0.1
            meta:
              category: biosphere
          corine_2012:
            data_type: RasterDataset
            path: https://eurac-eo.s3.amazonaws.com/INTERTWIN/HYDROFORM/corine/2012/clc12_4326.tif
            driver: raster
            filesystem: http
            crs: 4326
            meta:
              category: landuse & landcover
          corine_2018_stac:
            data_type: RasterDataset
            path: https://stac.eurac.edu/collections/CLC2018
            driver: stac
            driver_kwargs:
              bands: ["corine_lcl"]
              static: True
            filesystem: http
            crs: 3035
            meta:
              category: landuse & landcover
          ecodatacube_2018:
            data_type: RasterDataset
            path: https://eurac-eo.s3.amazonaws.com/INTERTWIN/HYDROFORM/ecodatacube/4326/lcv_landcover.hcl_lucas.corine.rf_p_30m_0..0cm_2018_eumap_epsg4326_v0.1.tif
            driver: raster
            filesystem: http
            crs: 4326
            meta:
              category: landuse & landcover
          corine_mapping:
            data_type: DataFrame
            path: https://eurac-eo.s3.amazonaws.com/INTERTWIN/HYDROFORM/corine/corine_mapping.csv
            driver: csv
            filesystem: http
            meta:
              category: landuse & landcover
          soilgrids_2020_stac:
            data_type: RasterDataset
            path: https://stac.eurac.edu/collections/SOILGRIDS
            driver: stac
            filesystem: http
            nodata: -32768
            crs: 4326
            mask_nodata: True
            unit_mult:
              bd_sl1: 0.01
              bd_sl2: 0.01
              bd_sl3: 0.01
              bd_sl4: 0.01
              bd_sl5: 0.01
              bd_sl6: 0.01
              clyppt_sl1: 0.1
              clyppt_sl2: 0.1
              clyppt_sl3: 0.1
              clyppt_sl4: 0.1
              clyppt_sl5: 0.1
              clyppt_sl6: 0.1
              sltppt_sl1: 0.1
              sltppt_sl2: 0.1
              sltppt_sl3: 0.1
              sltppt_sl4: 0.1
              sltppt_sl5: 0.1
              sltppt_sl6: 0.1
              sndppt_sl1: 0.1
              sndppt_sl2: 0.1
              sndppt_sl3: 0.1
              sndppt_sl4: 0.1
              sndppt_sl5: 0.1
              sndppt_sl6: 0.1
              ph_sl1: 0.1
              ph_sl2: 0.1
              ph_sl3: 0.1
              ph_sl4: 0.1
              ph_sl5: 0.1
              ph_sl6: 0.1
              oc_sl1: 0.01
              oc_sl2: 0.01
              oc_sl3: 0.01
              oc_sl4: 0.01
              oc_sl5: 0.01
              oc_sl6: 0.01
            driver_kwargs:
              bands: ["bd_sl1","bd_sl2","bd_sl3", "bd_sl4", "bd_sl5", "bd_sl6",
              "clyppt_sl1","clyppt_sl2","clyppt_sl3", "clyppt_sl4", "clyppt_sl5", "clyppt_sl6",
              "sltppt_sl1","sltppt_sl2","sltppt_sl3", "sltppt_sl4", "sltppt_sl5", "sltppt_sl6",
              "sndppt_sl1","sndppt_sl2","sndppt_sl3", "sndppt_sl4", "sndppt_sl5", "sndppt_sl6",
              "ph_sl1","ph_sl2","ph_sl3", "ph_sl4", "ph_sl5", "ph_sl6",
              "oc_sl1","oc_sl2","oc_sl3", "oc_sl4", "oc_sl5", "oc_sl6",
              "soilthickness"]
              static: True
            meta:
              category: soil
              reference: https://www.isric.org/explore/soilgrids/faq-soilgrids#How_were_the_legends_generated
          rivers_lin2019:
            data_type: GeoDataFrame
            path: https://eurac-eo.s3.amazonaws.com/INTERTWIN/HYDROFORM/rivers_ge30m/rivers_ge30m_4326.gpkg
            driver: vector
            filesystem: http
            crs: 4326
            rename:
              width_m: rivwth
              QMEAN: qbankfull 
            meta: 
              category:
                hydrosphere: surface water 
              url: https://zenodo.org/records/3552776#.YVbOrppByUk
          hydrolakes_v10:
            data_type: GeoDataFrame
            path: https://eurac-eo.s3.amazonaws.com/INTERTWIN/HYDROFORM/hydrolakes/HydroLAKES_polys_v10.gpkg
            driver: vector
            filesystem: http
            crs: 4326
            rename:
              Depth_avg: Depth_avg
              Dis_avg: Dis_avg
              Hylak_id: waterbody_id
              Lake_area: Area_avg
              Pour_lat: yout
              Pour_long: xout
              Vol_total: Vol_avg
            unit_mult:
              Area_avg: 1000000.0
          rgi60_global:
            data_type: GeoDataFrame
            path: https://eurac-eo.s3.amazonaws.com/INTERTWIN/HYDROFORM/rgi60_global/rgi.gpkg
            driver: vector
            crs: 4326
            rename:
              C3S_ID: C3S_id
              GLIMSID: GLIMS_id
              ID: simple_id
              RGIID: RGI_id
            meta:
              category: 
                hydrosphere: surface water
              notes: Randolph Glacier Inventory
          grand_v1.3:
            data_type: GeoDataFrame
            path: https://eurac-eo.s3.amazonaws.com/INTERTWIN/HYDROFORM/grand/v1.3/GRanD_Version_1_3/GRanD_reservoirs_v1_3.gpkg
            driver: vector
            crs: 4326
            nodata: -99
            rename:
              DEPTH_M: Depth_avg
              DIS_AVG_LS: Dis_avg
              CAP_MAX: Capacity_max
              CAP_MIN: Capacity_min
              CAP_REP: Capacity_norm
              DAM_HGT_M: Dam_height
              GRAND_ID: waterbody_id
              AREA_SKM: Area_avg
              LAT_DD: yout
              LONG_DD: xout
              CAP_MCM: Vol_avg
            unit_mult:
              Area_avg: 1000000.0
              Capacity_max: 1000000.0
              Capacity_min: 1000000.0
              Capacity_norm: 1000000.0
              Vol_avg: 1000000.0
            meta:
              category: surface water
              notes: GRanD.v1.1_HydroLAKES.v10_JRC.2016
              source_author: Alessia Matano
              source_version: 1.0
          ado_gauges:
            data_type: GeoDataFrame
            path: https://eurac-eo.s3.amazonaws.com/INTERTWIN/HYDROFORM/ADO/ADO_discharge_metadata.csv
            driver: csv
            filesystem: http
            crs: 4326
            meta:
              category:
                hydrosphere: surface water
          ado_surrogate_test:
            data_type: GeoDataFrame
            path: https://eurac-eo.s3.amazonaws.com/INTERTWIN/HYDROFORM/ADO/ADO_Adige_surrogate_test_discharge_metadata.csv
            driver: csv
            filesystem: http
            crs: 4326
            meta:
              category:
                hydrosphere: surface water
          EOL
inputs: {}
outputs:
  data_catalog:
    type: stdout

stdout: catalog.yaml
