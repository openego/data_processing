-- Copyright 2016 by NEXT ENERGY
-- Published under GNU GENERAL PUBLIC LICENSE Version 3 (see https://github.com/openego/data_processing/blob/master/LICENSE)

-- script to assign osmTGmod-id to substation

-- update calc_ego_substation.ego_deu_substations table with new column of respective osmtgmod bus_i
ALTER TABLE calc_ego_substation.ego_deu_substations 
ADD COLUMN otg_id bigint;

-- fill table with bus_i from osmtgmod
UPDATE calc_ego_substation.ego_deu_substations
SET otg_id = calc_ego_osmtgmod.bus_data.bus_i
FROM calc_ego_osmtgmod.bus_data
WHERE (SELECT TRIM(leading 'n' FROM TRIM(leading 'w' FROM calc_ego_substation.ego_deu_substations.osm_id))::BIGINT)=calc_ego_osmtgmod.bus_data.osm_substation_id; 

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.1' AS version,
		'calc_ego_substation' AS schema_name,
		'ego_deu_substations' AS table_name,
		'otg_id_to_substations.sql' AS script_name,
		COUNT(subst_id)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	calc_ego_loads.ego_deu_consumption;

-- do the same with calc_ego_substation.ego_deu_substations_ehv

-- update calc_ego_substation.ego_deu_substations_ehv table with new column of respective osmtgmod bus_i
ALTER TABLE calc_ego_substation.ego_deu_substations_ehv
ADD COLUMN otg_id bigint;

-- fill table with bus_i from osmtgmod
UPDATE calc_ego_substation.ego_deu_substations_ehv
SET otg_id = calc_ego_osmtgmod.bus_data.bus_i
FROM calc_ego_osmtgmod.bus_data
WHERE (SELECT TRIM(leading 'n' FROM TRIM(leading 'w' FROM TRIM(leading 'r' FROM calc_ego_substation.ego_deu_substations_ehv.osm_id)))::BIGINT)=calc_ego_osmtgmod.bus_data.osm_substation_id; 

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.1' AS version,
		'calc_ego_substation' AS schema_name,
		'ego_deu_substations_ehv' AS table_name,
		'otg_id_to_substations.sql' AS script_name,
		COUNT(subst_id)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	calc_ego_loads.ego_deu_consumption;
