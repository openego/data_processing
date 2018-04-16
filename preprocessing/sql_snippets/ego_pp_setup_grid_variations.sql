/*
This script creates and fills a table with information on the NEP 2035 B2 scenario. 

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "ClaraBuettner, IlkaCu" 
*/


DROP TABLE IF EXISTS  model_draft.scn_nep2035_b2_line ;
CREATE TABLE model_draft.scn_nep2035_b2_line
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  project character varying,
  project_id bigint,
  startpunkt character varying,
  endpunkt character varying,
  spannung bigint,
  s_nom numeric DEFAULT 0,
  cables bigint,
  nova character varying,
  geom geometry(MultiLineString,4326)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.scn_nep2035_b2_line
  OWNER TO oeuser;
  
COPY model_draft.scn_nep2035_b2_line FROM '/GitHub/data_processing/documentation/scn_nep2035_b2.csv' DELIMITER ',' CSV HEADER;
