/*
This script loads the renpassGIS tabel parameter_region whith the Geoinformation 
into the database V2 and set Metadata

__copyright__ = "Europa-Universität Flensburg, Centre for Sustainable Energy Systems"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke"

*/

-- Export from server
COPY (SELECT * FROM app_renpassgis.parameter_region) 
TO '/tmp/app_renpassgis_parameter_region.csv'
DELIMITER ',' CSV HEADER;

-- Drop Table model_draft.renpassgis_parameter_region;
-- Drop Sequence model_draft.renpassgis_parameter_region_gid_seq cascade;

Create Sequence model_draft.renpass_gis_parameter_region_gid_seq START 1;

CREATE TABLE model_draft.renpass_gis_parameter_region
(
  gid integer NOT NULL DEFAULT nextval('model_draft.renpassgis_parameter_region_gid_seq'::regclass),
  u_region_id character varying(14) NOT NULL,
  stat_level integer,
  geom geometry(MultiPolygon,4326),
  geom_point geometry(Point,4326),
  CONSTRAINT register_regions_pkey PRIMARY KEY (gid)
);

ALTER TABLE model_draft.renpassgis_economic_weatherpoint_voronoi
  OWNER TO oeuser;
  
-- Import to oep
COPY model_draft.renpass_gis_parameter_region (gid,u_region_id,stat_level,geom,geom_point)
FROM '/tmp/app_renpassgis_parameter_region.csv' DELIMITER ',' CSV HEADER;

--  META Documentation
--

COMMENT ON TABLE model_draft.renpass_gis_parameter_region IS
'{
"Name": "renpassGIS scenario regions geometries",
"Source": [	{
                  "Name": "renpassGIS",
                  "URL":  "https://github.com/znes/" },
		{ "Name": "",
                  "URL":  "https://osf.io/XXX" }
                  ],
"Reference date": "2050",
"Date of collection": "21-11-2016",
"Original file": "https://github.com/openego/data_processing/blob/refactor/oedb-restructuring_v0.2/calc_geo_powerplants/app_renpassgis.sql",
"Spatial resolution": ["Germany"],
"Description": [" XXXX"],
"Column": [
                   {"Name": "gid",
                    "Description": "Primary ID",
                    "Unit": "" }, 
                   {"Name": "u_region_id",
                    "Description": "Unique region ID, based on EU NUTS standard",
                    "Unit": "" }, 
		   {"Name": "stat_level",
                    "Description": "",
                    "Unit": "" },
		   {"Name": "geom",
                    "Description": "Polygon Geom represent a scenario region",
                    "Unit": "" },
                   {"Name": "geom_point",
                    "Description": "Centruide Point of scenarion region",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Wolf-Dieter Bunke",
                    "Mail": "wolf-dieter.bunke@uni-flensburg.de",
                    "Date":  "10.02.2017",
                    "Comment": "Move tabel to oep V2 with meta data" }               
                  ],
"Notes": ["..."],
"Licence":      [{
                    "Name":       "Open Database License (ODbL) v1.0",
		    "URL":        "http://opendatacommons.org/licenses/odbl/1.0/",
	            "Copyright":  "Europa-Universität Flensburg, Centre for Sustainable Energy Systems"}],
"Instructions for proper use": ["..."] 
}';

--- 
SELECT obj_description('model_draft.ego_supply_res_powerplant_2050'::regclass)::json;

-- END
