/*
SQL Script in order to make an over all validation of the RES future allogation
           as well as for the conventional power plants by using plots.
           
__copyright__ = "Europa-Universität Flensburg, Fachhochschule Flensburg - ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke"

*/


-- Plots 
-- Sum per federal state and type of generation of RES

DROP TABLE orig_geo_powerplants.validation_sq CASCADE;

CREATE TABLE orig_geo_powerplants.validation_sq
(
  id serial,
  fs_name character varying,
  sum_cap numeric,
  generation_type text,
  scenario_name character varying,
  geom geometry(MultiPolygon,3035),
  CONSTRAINT validation_sq_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE orig_geo_powerplants.validation_sq
  OWNER TO oeuser;

--
CREATE INDEX validation_sq_geom_idx
  ON orig_geo_powerplants.validation_sq
  USING gist
  (geom);
  
---

Insert into orig_geo_powerplants.validation_sq (fs_name,sum_cap,generation_type,scenario_name,geom)
	SELECT
	 state.gen fs_name,
	 sum(res.electrical_capacity) sum_cap,
	 res.generation_type,
	 'SQ'::text as scenario_name,
	 state.geom
	FROM
	  political_boundary.bkg_vg250_2_lan_mview state,
	  supply.ego_renewable_powerplant res
	Where 
	  ST_Intersects(St_Transform(res.geom,3035),state.geom)
	Group by state.gen,res.generation_type, state.geom
;
