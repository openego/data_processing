/* 
SQL Script which insert coastDat-2 Geo-Ids to renewable and conventional power plant data 

__copyright__ = "Europa-Universität Flensburg - ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke"	
      

*/


--
Alter Table  model_draft.ego_dp_supply_conv_powerplant
 DROP COLUMN IF EXISTS coastdat_gid CASCADE,
 ADD COLUMN coastdat_gid bigint;


Alter Table  model_draft.ego_dp_supply_res_powerplant
 DROP COLUMN IF EXISTS coastdat_gid CASCADE,
 ADD COLUMN coastdat_gid bigint;

-- local Database until Open_Fred is publishing
Update model_draft.ego_dp_supply_conv_powerplant as b
  set coastdat_gid = a.gid
  From coastdat.cosmoclmgrid a
  Where
  ST_intersects(a.geom, b.geom);

Update model_draft.ego_dp_supply_res_powerplant as b
  set coastdat_gid = a.gid
  From coastdat.cosmoclmgrid a
  Where
  ST_intersects(a.geom, b.geom);


-- QGIS Query
-- Power plants with coastdat polygon
SELECT
b.*,
a.geom as coastdat_geom
FROM
  coastdat.cosmoclmgrid a,
  model_draft.ego_dp_supply_conv_powerplant b
Where b.coastdat_gid = a.gid;

SELECT
b.*,
a.geom as coastdat_geom
FROM
  coastdat.cosmoclmgrid a,
  model_draft.ego_dp_supply_res_powerplant b
Where b.coastdat_gid = a.gid;
    

-- Statistic
-- number of units per weather point and subst
SELECT
count(*)
FROM model_draft.ego_dp_supply_conv_powerplant
Group by coastdat_gid, subst_id;

SELECT
count(*)
FROM model_draft.ego_dp_supply_res_powerplant
Group by coastdat_gid, subst_id;


-- check ids
SELECT
coastdat_gid, count(*)
FROM
 model_draft.ego_dp_supply_conv_powerplant
group by coastdat_gid


-- relation tables for oedb
CREATE TABLE model_draft.ego_conv_powerplant_costdat_gid AS
  SELECT id, coastdat_gid FROM model_draft.ego_dp_supply_conv_powerplant;

CREATE TABLE model_draft.ego_res_powerplant_costdat_gid AS
  SELECT id, coastdat_gid FROM model_draft.ego_dp_supply_res_powerplant;

Update  model_draft.ego_dp_supply_res_powerplant as A
  set coastdat_gid = B.coastdat_gid
  FROM  model_draft.ego_res_powerplant_costdat_gid B
  Where A.id = B.id;

Update  model_draft.ego_conv_powerplant_costdat_gid as A
  set coastdat_gid = B.coastdat_gid
  FROM  model_draft.ego_conv_powerplant_costdat_gid B
  Where A.id = B.id;


