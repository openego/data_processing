/*
Import gn250 tables
Geographische Namen 1:250 000 - GN250

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/


-- 1.
CREATE TABLE boundaries.bkg_gn250_p (
	reference_date date,
	id serial NOT NULL,
	nnid character varying(16),
	datum character varying(10),
	oba character varying(40),
	oba_wert character varying(40),
	name character varying(90),
	sprache character varying(25),
	genus character varying(10),
	name2 character varying(90),
	sprache2 character varying(25),
	genus2 character varying(10),
	zusatz character varying(40),
	ags character varying(8),
	rs character varying(12),
	hoehe character varying(8),
	hoehe_ger character varying(5),
	ewz character varying(8),
	ewz_ger character varying(8),
	gewk character varying(18),
	gemteil character varying(4),
	virtuell character varying(4),
	gemeinde character varying(40),
	verwgem character varying(40),
	kreis character varying(40),
	regbezirk character varying(40),
	bundesland character varying(40),
	staat character varying(40),
	geola character varying(6),
	geobr character varying(6),
	gkre numeric,
	gkho numeric,
	utmre numeric,
	utmho numeric,
	box_geo character varying(250),
	box_gk character varying(250),
	box_utm character varying(250),
	geom geometry(Point,31467),
	CONSTRAINT bkg_gn250_p_pkey PRIMARY KEY (reference_date,id) );

-- grant (oeuser)
ALTER TABLE boundaries.bkg_gn250_p OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX bkg_gn250_p_geom_idx ON boundaries.bkg_gn250_p USING gist (geom);



-- 2.
CREATE TABLE boundaries.bkg_gn250_b (
	reference_date date,
	id serial NOT NULL,
	nnid character varying(16),
	datum character varying(10),
	oba character varying(40),
	oba_wert character varying(40),
	name character varying(90),
	sprache character varying(25),
	genus character varying(10),
	name2 character varying(90),
	sprache2 character varying(25),
	genus2 character varying(10),
	zusatz character varying(40),
	ags character varying(8),
	rs character varying(12),
	hoehe character varying(8),
	hoehe_ger character varying(5),
	ewz character varying(8),
	ewz_ger character varying(8),
	gewk character varying(18),
	gemteil character varying(4),
	virtuell character varying(4),
	gemeinde character varying(40),
	verwgem character varying(40),
	kreis character varying(40),
	regbezirk character varying(40),
	bundesland character varying(40),
	staat character varying(40),
	geola character varying(6),
	geobr character varying(6),
	gkre numeric,
	gkho numeric,
	utmre numeric,
	utmho numeric,
	box_geo character varying(250),
	box_gk character varying(250),
	box_utm character varying(250),
	geom geometry(Multipolygon,31467),
	CONSTRAINT bkg_gn250_b_pkey PRIMARY KEY (reference_date,id) );

-- grant (oeuser)
ALTER TABLE boundaries.bkg_gn250_b OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX bkg_vg250_2_lan_geom_idx ON boundaries.bkg_gn250_b USING gist (geom);


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','preprocessing','boundaries','gn250_p','ego_pp_gn250_import.sql','setup gn250 tables');
SELECT ego_scenario_log('v0.2.10','preprocessing','boundaries','gn250_b','ego_pp_gn250_import.sql','setup gn250 tables');
