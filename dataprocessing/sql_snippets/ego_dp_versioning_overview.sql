/*
eGo Data Processing overview
Check all versioned tables

__copyright__   = "© Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Ludee"
*/



/*-- overview

-- View all versions
SELECT  *
FROM    model_draft.ego_scenario_overview
ORDER BY name, version, id;

-- Select one version
SELECT  *
FROM    model_draft.ego_scenario_overview
WHERE   version = 'v0.4.5'
ORDER BY id;

-- Remove version
DELETE FROM model_draft.ego_scenario_overview
WHERE   version = 'v0.4.5';
*/


-- Loop version

-- versioning tables
SELECT  schema_name AS schema,
        table_name AS table,
        version
FROM    model_draft.scenario_log
WHERE   version = 'v0.4.5'
        AND io = 'result'
        AND comment = 'versioning'
GROUP BY schema_name, table_name, version
ORDER BY min(id)

-- loop
DO
$$
DECLARE
    row record;
BEGIN
    FOR row IN 
        SELECT  schema_name AS schema,
                table_name AS table,
                version
        FROM    model_draft.scenario_log
        WHERE   version = 'v0.4.5'
                AND io = 'result'
                AND comment = 'versioning'
        GROUP BY schema_name, table_name, version
        ORDER BY min(id)
    LOOP
        EXECUTE 'INSERT INTO model_draft.ego_scenario_overview (name,version,cnt)
                SELECT  ' || quote_literal(row.schema || '.' || row.table ) || ', '
                    || quote_literal(row.version) || ',
                    count(*) AS cnt
                FROM    ' || quote_ident(row.schema) || '.' || quote_ident(row.table) || ';';
    END LOOP;
END;
$$


/*-- Manual version
INSERT INTO model_draft.ego_scenario_overview (name,version,cnt)
    SELECT  'grid.ego_dp_ehv_substation' AS name,
            version,
            count(*) AS cnt
    FROM    grid.ego_dp_ehv_substation
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'grid.ego_dp_hvmv_substation' AS name,
            version,
            count(*) AS cnt
    FROM    grid.ego_dp_hvmv_substation
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'grid.ego_dp_mvlv_substation' AS name,
            version,
            count(*) AS cnt
    FROM    grid.ego_dp_mvlv_substation
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'grid.ego_dp_ehv_griddistrict' AS name,
            version,
            count(*) AS cnt
    FROM    grid.ego_dp_ehv_griddistrict
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'grid.ego_dp_mv_griddistrict' AS name,
            version,
            count(*) AS cnt
    FROM    grid.ego_dp_mv_griddistrict
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'grid.ego_dp_lv_griddistrict' AS name,
            version,
            count(*) AS cnt
    FROM    grid.ego_dp_lv_griddistrict
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'demand.ego_dp_loadarea' AS name,
            version,
            count(*) AS cnt
    FROM    demand.ego_dp_loadarea
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'supply.ego_dp_conv_powerplant' AS name,
            version,
            count(*) AS cnt
    FROM    supply.ego_dp_conv_powerplant
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'supply.ego_dp_res_powerplant' AS name,
            version,
            count(*) AS cnt
    FROM    supply.ego_dp_res_powerplant
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'grid.ego_pf_hv_bus' AS name,
            version,
            count(*) AS cnt
    FROM    grid.ego_pf_hv_bus
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'grid.ego_pf_hv_generator' AS name,
            version,
            count(*) AS cnt
    FROM    grid.ego_pf_hv_generator
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'grid.ego_pf_hv_generator_pq_set' AS name,
            version,
            count(*) AS cnt
    FROM    grid.ego_pf_hv_generator_pq_set
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'grid.ego_pf_hv_line' AS name,
            version,
            count(*) AS cnt
    FROM    grid.ego_pf_hv_line
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'grid.ego_pf_hv_load' AS name,
            version,
            count(*) AS cnt
    FROM    grid.ego_pf_hv_load
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'grid.ego_pf_hv_load_pq_set' AS name,
            version,
            count(*) AS cnt
    FROM    grid.ego_pf_hv_load_pq_set
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'grid.ego_pf_hv_source' AS name,
            version,
            count(*) AS cnt
    FROM    grid.ego_pf_hv_source
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'grid.ego_pf_hv_storage' AS name,
            version,
            count(*) AS cnt
    FROM    grid.ego_pf_hv_storage
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'grid.ego_pf_hv_storage_pq_set' AS name,
            version,
            count(*) AS cnt
    FROM    grid.ego_pf_hv_storage_pq_set
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'grid.ego_pf_hv_temp_resolution' AS name,
            version,
            count(*) AS cnt
    FROM    grid.ego_pf_hv_temp_resolution
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'grid.ego_pf_hv_transformer' AS name,
            version,
            count(*) AS cnt
    FROM    grid.ego_pf_hv_transformer
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL       -- supply
    SELECT  'supply.ego_dp_conv_powerplant_sq_mview' AS name,
            version,
            count(*) AS cnt
    FROM    supply.ego_dp_conv_powerplant_sq_mview
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'supply.ego_dp_conv_powerplant_nep2035_mview' AS name,
            version,
            count(*) AS cnt
    FROM    supply.ego_dp_conv_powerplant_nep2035_mview
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'supply.ego_dp_conv_powerplant_ego100_mview' AS name,
            version,
            count(*) AS cnt
    FROM    supply.ego_dp_conv_powerplant_ego100_mview
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'supply.ego_dp_res_powerplant_sq_mview' AS name,
            version,
            count(*) AS cnt
    FROM    supply.ego_dp_res_powerplant_sq_mview
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'supply.ego_dp_res_powerplant_nep2035_mview' AS name,
            version,
            count(*) AS cnt
    FROM    supply.ego_dp_res_powerplant_nep2035_mview
    WHERE   version = 'v0.4.5'
    GROUP BY version
UNION ALL
    SELECT  'supply.ego_dp_res_powerplant_ego100_mview' AS name,
            version,
            count(*) AS cnt
    FROM    supply.ego_dp_res_powerplant_ego100_mview
    WHERE   version = 'v0.4.5'
    GROUP BY version
;
*/
