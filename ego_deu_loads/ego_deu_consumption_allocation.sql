DROP TABLE orig_geo_rli.znes_deu_consumption_spf;

CREATE TABLE orig_geo_rli.znes_deu_consumption_spf
(
	la_id integer NOT NULL,
	sector_consumption_residential numeric,
	sector_consumption_retail numeric,
	sector_consumption_industrial numeric,
	sector_consumption_agricultural numeric,
	CONSTRAINT znes_deu_consumption_spf_pkey PRIMARY KEY (la_id)
);

GRANT ALL ON TABLE orig_consumption_znes.destatis_gva_per_districts TO oeuser;
GRANT ALL ON TABLE orig_consumption_znes.destatis_gva_per_districts TO oerest;

INSERT INTO orig_geo_rli.znes_deu_consumption_spf (la_id)
	SELECT la_id
	FROM orig_geo_rli.rli_deu_loadarea_spf;


-- Calculate the industrial area per district 

SELECT sum(sector_area_industrial), substr(nuts,1,5) 
	INTO orig_consumption_znes.temp_table
	FROM orig_geo_rli.rli_deu_loadarea_spf
	GROUP BY substr(nuts,1,5);

UPDATE orig_consumption_znes.lak_consumption_per_district a
	SET area_industry = sum
	FROM orig_consumption_znes.temp_table b
	WHERE b.substr = substr(a.eu_code,1,5);

DROP TABLE orig_consumption_znes.temp_table;

-- Calculate the retail area per district

SELECT sum(sector_area_retail), substr(nuts,1,5) 
	INTO orig_consumption_znes.temp_table
	FROM orig_geo_rli.rli_deu_loadarea_spf
	GROUP BY substr(nuts,1,5);

UPDATE orig_consumption_znes.lak_consumption_per_district a
	SET area_retail = sum
	FROM orig_consumption_znes.temp_table b
	WHERE b.substr = substr(a.eu_code,1,5);

DROP TABLE orig_consumption_znes.temp_table;

-- Calculate the agricultural area per district

SELECT sum(sector_area_agricultural), substr(nuts,1,5) 
	INTO orig_consumption_znes.temp_table
	FROM orig_geo_rli.rli_deu_loadarea_spf
	GROUP BY substr(nuts,1,5);

UPDATE orig_consumption_znes.lak_consumption_per_district a
	SET area_agriculture = sum
	FROM orig_consumption_znes.temp_table b
	WHERE b.substr = substr(a.eu_code,1,5);

DROP TABLE orig_consumption_znes.temp_table;

-- Calculate area of tertiary sector by adding agricultural and retail area up


update orig_consumption_znes.lak_consumption_per_district 
	set area_tertiary_sector = coalesce(area_retail,0) + coalesce(area_agriculture,0);

-- Calculate electricity demand per loadarea

UPDATE orig_consumption_znes.lak_consumption_per_district
	SET consumption_per_area_tertiary_sector = elec_consumption_tertiary_sector/nullif(area_tertiary_sector,0);

UPDATE orig_consumption_znes.lak_consumption_per_district
	SET consumption_per_area_industry = elec_consumption_industry/nullif(area_industry,0);

-- Calculate sector consumption of industry per loadarea

UPDATE orig_geo_rli.znes_deu_consumption_spf a
SET   sector_consumption_industrial = sub.result 
FROM
(
	SELECT
	c.la_id,
	b.consumption_per_area_industry * c.sector_area_industrial as result
	FROM
	orig_consumption_znes.lak_consumption_per_district b,
	orig_geo_rli.rli_deu_loadarea_spf c
	WHERE
	c.nuts = b.eu_code
) AS sub
WHERE
sub.la_id = a.la_id;

-- Calculate sector consumption of tertiary sector per loadarea

UPDATE orig_geo_rli.znes_deu_consumption_spf a
SET   sector_consumption_retail = sub.result 
FROM
(
	SELECT
	c.la_id,
	b.consumption_per_area_tertiary_sector * c.sector_area_retail as result
	FROM
	orig_consumption_znes.lak_consumption_per_district b,
	orig_geo_rli.rli_deu_loadarea_spf c
	WHERE
	c.nuts = b.eu_code
) AS sub
WHERE
sub.la_id = a.la_id;

-- Calculate sector consumption of agriculture per loadarea

UPDATE orig_geo_rli.znes_deu_consumption_spf a
SET   sector_consumption_agricultural = sub.result 
FROM
(
	SELECT
	c.la_id,
	b.consumption_per_area_tertiary_sector * c.sector_area_agricultural as result
	FROM
	orig_consumption_znes.lak_consumption_per_district b,
	orig_geo_rli.rli_deu_loadarea_spf c
	WHERE
	c.nuts = b.eu_code
) AS sub
WHERE
sub.la_id = a.la_id;


-- Calculate sector consumption of households per loadarea

UPDATE orig_geo_rli.znes_deu_consumption_spf a
SET   sector_consumption_residential = sub.result 
FROM
(
	SELECT
	c.la_id,
	b.elec_consumption_households_per_person * c.zensus_sum as result
	FROM 
	orig_consumption_znes.lak_consumption_per_federalstate b,
	orig_geo_rli.rli_deu_loadarea_spf c
	WHERE
	substring(c.nuts,1,3) = b.eu_code

) AS sub
WHERE
sub.la_id = a.la_id;



