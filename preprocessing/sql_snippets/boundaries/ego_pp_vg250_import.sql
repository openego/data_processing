/*
Import vg250 tables

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/


-- 1.
CREATE TABLE political_boundary.bkg_vg250_1_sta (
	reference_date date,
	id serial NOT NULL,
	geom geometry(MultiPolygon,31467),
	ade bigint,
	gf bigint,
	bsg bigint,
	rs character varying(12),
	ags character varying(12),
	sdv_rs character varying(12),
	gen character varying(50),
	bez character varying(50),
	ibz bigint,
	bem character varying(75),
	nbd character varying(4),
	sn_l character varying(2),
	sn_r character varying(1),
	sn_k character varying(2),
	sn_v1 character varying(2),
	sn_v2 character varying(2),
	sn_g character varying(3),
	fk_s3 character varying(2),
	nuts character varying(5),
	rs_0 character varying(12),
	ags_0 character varying(12),
	wsk date,
	debkg_id character varying(16),
	CONSTRAINT bkg_vg250_1_sta_pkey PRIMARY KEY (reference_date,id) )WITH (OIDS=FALSE);

-- grant (oeuser)
ALTER TABLE political_boundary.bkg_vg250_1_sta OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX bkg_vg250_1_sta_geom_idx ON political_boundary.bkg_vg250_1_sta USING gist (geom);

-- insert data
INSERT INTO political_boundary.bkg_vg250_1_sta
	SELECT 	'2015-01-01',
		vg.*
	FROM	political_boundary.bkg_vg250_20150101_1_sta AS vg;

INSERT INTO political_boundary.bkg_vg250_1_sta
	SELECT 	'2016-01-01',
		vg.*
	FROM	political_boundary.bkg_vg250_20160101_1_sta AS vg; */


-- 2.
CREATE TABLE political_boundary.bkg_vg250_2_lan (
	reference_date date,
	id serial NOT NULL,
	ade double precision,
	gf double precision,
	bsg double precision,
	rs character varying(12),
	ags character varying(12),
	sdv_rs character varying(12),
	gen character varying(50),
	bez character varying(50),
	ibz double precision,
	bem character varying(75),
	nbd character varying(4),
	sn_l character varying(2),
	sn_r character varying(1),
	sn_k character varying(2),
	sn_v1 character varying(2),
	sn_v2 character varying(2),
	sn_g character varying(3),
	fk_s3 character varying(2),
	nuts character varying(5),
	rs_0 character varying(12),
	ags_0 character varying(12),
	wsk date,
	debkg_id character varying(16),
	geom geometry(MultiPolygon,31467),
	CONSTRAINT bkg_vg250_2_lan_pkey PRIMARY KEY (reference_date,id) )WITH (OIDS=FALSE);

-- grant (oeuser)
ALTER TABLE political_boundary.bkg_vg250_2_lan OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX bkg_vg250_2_lan_geom_idx ON political_boundary.bkg_vg250_2_lan USING gist (geom);

-- insert data
INSERT INTO political_boundary.bkg_vg250_2_lan
	SELECT 	'2016-01-01',
		vg.*
	FROM	political_boundary.vg250_2_lan AS vg;


-- 3.
CREATE TABLE political_boundary.bkg_vg250_3_rbz (
	reference_date date,
	id serial NOT NULL,
	ade double precision,
	gf double precision,
	bsg double precision,
	rs character varying(12),
	ags character varying(12),
	sdv_rs character varying(12),
	gen character varying(50),
	bez character varying(50),
	ibz double precision,
	bem character varying(75),
	nbd character varying(4),
	sn_l character varying(2),
	sn_r character varying(1),
	sn_k character varying(2),
	sn_v1 character varying(2),
	sn_v2 character varying(2),
	sn_g character varying(3),
	fk_s3 character varying(2),
	nuts character varying(5),
	rs_0 character varying(12),
	ags_0 character varying(12),
	wsk date,
	debkg_id character varying(16),
	geom geometry(MultiPolygon,31467),
	CONSTRAINT bkg_vg250_3_rbz_pkey PRIMARY KEY (reference_date,id) )WITH (OIDS=FALSE);

-- grant (oeuser)
ALTER TABLE political_boundary.bkg_vg250_3_rbz OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX bkg_vg250_3_rbz_geom_idx ON political_boundary.bkg_vg250_3_rbz USING gist (geom);

-- insert data
INSERT INTO political_boundary.bkg_vg250_3_rbz
	SELECT 	'2016-01-01',
		vg.*
	FROM	political_boundary.vg250_3_rbz AS vg;


-- 4.
CREATE TABLE political_boundary.bkg_vg250_4_krs (
	reference_date date,
	id serial NOT NULL,
	ade double precision,
	gf double precision,
	bsg double precision,
	rs character varying(12),
	ags character varying(12),
	sdv_rs character varying(12),
	gen character varying(50),
	bez character varying(50),
	ibz double precision,
	bem character varying(75),
	nbd character varying(4),
	sn_l character varying(2),
	sn_r character varying(1),
	sn_k character varying(2),
	sn_v1 character varying(2),
	sn_v2 character varying(2),
	sn_g character varying(3),
	fk_s3 character varying(2),
	nuts character varying(5),
	rs_0 character varying(12),
	ags_0 character varying(12),
	wsk date,
	debkg_id character varying(16),
	geom geometry(MultiPolygon,31467),
	CONSTRAINT bkg_vg250_4_krs_pkey PRIMARY KEY (reference_date,id) )WITH (OIDS=FALSE);

-- grant (oeuser)
ALTER TABLE political_boundary.bkg_vg250_4_krs OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX bkg_vg250_4_krs_geom_idx ON political_boundary.bkg_vg250_4_krs USING gist (geom);

-- insert data
INSERT INTO political_boundary.bkg_vg250_4_krs
	SELECT 	'2016-01-01',
		vg.*
	FROM	political_boundary.vg250_4_krs AS vg;


-- 5.
CREATE TABLE political_boundary.bkg_vg250_5_vwg (
	reference_date date,
	id serial NOT NULL,
	ade double precision,
	gf double precision,
	bsg double precision,
	rs character varying(12),
	ags character varying(12),
	sdv_rs character varying(12),
	gen character varying(50),
	bez character varying(50),
	ibz double precision,
	bem character varying(75),
	nbd character varying(4),
	sn_l character varying(2),
	sn_r character varying(1),
	sn_k character varying(2),
	sn_v1 character varying(2),
	sn_v2 character varying(2),
	sn_g character varying(3),
	fk_s3 character varying(2),
	nuts character varying(5),
	rs_0 character varying(12),
	ags_0 character varying(12),
	wsk date,
	debkg_id character varying(16),
	geom geometry(MultiPolygon,31467),
	CONSTRAINT bkg_vg250_5_vwg_pkey PRIMARY KEY (reference_date,id) )WITH (OIDS=FALSE);

-- grant (oeuser)
ALTER TABLE political_boundary.bkg_vg250_5_vwg OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX bkg_vg250_5_vwg_geom_idx ON political_boundary.bkg_vg250_5_vwg USING gist (geom);

-- insert data
INSERT INTO political_boundary.bkg_vg250_5_vwg
	SELECT 	'2016-01-01',
		vg.*
	FROM	political_boundary.vg250_5_vwg AS vg;


-- 6.
CREATE TABLE political_boundary.bkg_vg250_6_gem (
	reference_date date,
	id serial NOT NULL,
	ade double precision,
	gf double precision,
	bsg double precision,
	rs character varying(12),
	ags character varying(12),
	sdv_rs character varying(12),
	gen character varying(50),
	bez character varying(50),
	ibz double precision,
	bem character varying(75),
	nbd character varying(4),
	sn_l character varying(2),
	sn_r character varying(1),
	sn_k character varying(2),
	sn_v1 character varying(2),
	sn_v2 character varying(2),
	sn_g character varying(3),
	fk_s3 character varying(2),
	nuts character varying(5),
	rs_0 character varying(12),
	ags_0 character varying(12),
	wsk date,
	debkg_id character varying(16),
	geom geometry(MultiPolygon,31467),
	CONSTRAINT bkg_vg250_6_gem_pkey PRIMARY KEY (reference_date,id) )WITH (OIDS=FALSE);

-- grant (oeuser)
ALTER TABLE political_boundary.bkg_vg250_6_gem OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX bkg_vg250_6_gem_geom_idx ON political_boundary.bkg_vg250_6_gem USING gist (geom);

-- insert data
INSERT INTO political_boundary.bkg_vg250_6_gem
	SELECT 	'2016-01-01',
		vg.*
	FROM	political_boundary.bkg_vg250_6_gem AS vg;

/*
-- alter data type
ALTER TABLE orig_vg250.vg250_6_gem
	ALTER COLUMN ade TYPE double precision,
	ALTER COLUMN gf TYPE double precision,
	ALTER COLUMN bsg TYPE double precision;

-- insert data
INSERT INTO political_boundary.bkg_vg250_6_gem (reference_date,id,ade,gf,bsg,rs,ags,sdv_rs,gen,bez,ibz,bem,nbd,sn_l,sn_r,sn_k,sn_v1,sn_v2,sn_g,fk_s3,nuts,rs_0,ags_0,wsk,debkg_id,geom)
	SELECT 	'2016-01-01',
		gid,ade,gf,bsg,rs,ags,sdv_rs,gen,bez,ibz,bem,nbd,sn_l,sn_r,sn_k,sn_v1,sn_v2,sn_g,fk_s3,nuts,rs_0,ags_0,wsk,debkg_id,ST_TRANSFORM(geom,31467)
	FROM	political_boundary.vg250_6_gem AS vg;
*/

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','preprocessing','political_boundary','bkg_vg250_1_sta','ego_pp_vg250_import.sql','setup vg250 tables');
SELECT ego_scenario_log('v0.2.10','preprocessing','political_boundary','bkg_vg250_2_lan','ego_pp_vg250_import.sql','setup vg250 tables');
SELECT ego_scenario_log('v0.2.10','preprocessing','political_boundary','bkg_vg250_3_rbz','ego_pp_vg250_import.sql','setup vg250 tables');
SELECT ego_scenario_log('v0.2.10','preprocessing','political_boundary','bkg_vg250_4_krs','ego_pp_vg250_import.sql','setup vg250 tables');
SELECT ego_scenario_log('v0.2.10','preprocessing','political_boundary','bkg_vg250_5_vwg','ego_pp_vg250_import.sql','setup vg250 tables');
SELECT ego_scenario_log('v0.2.10','preprocessing','political_boundary','bkg_vg250_6_gem','ego_pp_vg250_import.sql','setup vg250 tables');
