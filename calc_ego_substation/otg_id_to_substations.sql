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
WHERE (SELECT TRIM(leading 'n' FROM TRIM(leading 'w' FROM calc_ego_substation.ego_deu_substations.osm_id)))=calc_ego_osmtgmod.bus_data.osm_substation_id; 

-- do the same with calc_ego_substation.ego_deu_substations_ehv

-- update calc_ego_substation.ego_deu_substations_ehv table with new column of respective osmtgmod bus_i
ALTER TABLE calc_ego_substation.ego_deu_substations_ehv
ADD COLUMN otg_id bigint;

-- fill table with bus_i from osmtgmod
UPDATE calc_ego_substation.ego_deu_substations_ehv
SET otg_id = calc_ego_osmtgmod.bus_data.bus_i
FROM calc_ego_osmtgmod.bus_data
WHERE (SELECT TRIM(leading 'n' FROM TRIM(leading 'w' FROM calc_ego_substation.ego_deu_substations_ehv.osm_id)))=calc_ego_osmtgmod.bus_data.osm_substation_id; 
