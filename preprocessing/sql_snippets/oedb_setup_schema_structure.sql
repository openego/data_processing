/*
Setup the OpenEnergy Database (oedb) schema structure

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/


-- rename (v0.2)
ALTER SCHEMA political_boundary RENAME TO boundaries;
ALTER SCHEMA weather RENAME TO climate;
ALTER SCHEMA economic RENAME TO economy;
ALTER SCHEMA environmental RENAME TO environment;
ALTER SCHEMA social RENAME TO society;

-- CREATE SCHEMA boundaries;
ALTER SCHEMA boundaries OWNER TO oeuser;
GRANT ALL ON SCHEMA boundaries TO oeuser WITH GRANT OPTION;
ALTER DEFAULT PRIVILEGES IN SCHEMA boundaries GRANT ALL ON TABLES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA boundaries GRANT ALL ON SEQUENCES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA boundaries GRANT EXECUTE ON FUNCTIONS TO oeuser;
COMMENT ON SCHEMA boundaries IS '{
"name": "Boundaries",
"description": "Legal land descriptions",
"examples": "Political and administrative boundaries",
"contributors": [
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2016-09-12",
		"comment": "Create schema" },
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2017-06-30",
		"comment": "Update schema metadata" },
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2017-06-30",
		"comment": "Rename schema name" }
		] }';

-- CREATE SCHEMA climate;
ALTER SCHEMA climate OWNER TO oeuser;
GRANT ALL ON SCHEMA climate TO oeuser WITH GRANT OPTION;
ALTER DEFAULT PRIVILEGES IN SCHEMA climate GRANT ALL ON TABLES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA climate GRANT ALL ON SEQUENCES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA climate GRANT EXECUTE ON FUNCTIONS TO oeuser;
COMMENT ON SCHEMA climate IS '{
"name": "Climate",
"description": "Processes and phenomena of the atmosphere",
"examples": "Cloud cover, weather, climate, atmospheric conditions, climate change, precipitation",
"contributors": [
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2016-09-12",
		"comment": "Create schema" },
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2017-06-30",
		"comment": "Update schema metadata" },
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2017-06-30",
		"comment": "Rename schema name" }
		] }';

-- CREATE SCHEMA economy; 
ALTER SCHEMA economy OWNER TO oeuser;
GRANT ALL ON SCHEMA economy TO oeuser WITH GRANT OPTION;
ALTER DEFAULT PRIVILEGES IN SCHEMA economy GRANT ALL ON TABLES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA economy GRANT ALL ON SEQUENCES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA economy GRANT EXECUTE ON FUNCTIONS TO oeuser;
COMMENT ON SCHEMA economy IS '{
"name": "Economy",
"description": "Economic activities, conditions and employment",
"examples": "Production, labour, revenue, commerce, industry, tourism and ecotourism, forestry, fisheries, commercial or subsistence hunting, exploration and exploitation of resources such as minerals, oil and gas",
"contributors": [
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2016-09-12",
		"comment": "Create schema" },
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2017-06-30",
		"comment": "Update schema metadata" },
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2017-06-30",
		"comment": "Rename schema name" }
		] }';

-- CREATE SCHEMA demand; 
ALTER SCHEMA demand OWNER TO oeuser;
GRANT ALL ON SCHEMA demand TO oeuser WITH GRANT OPTION;
ALTER DEFAULT PRIVILEGES IN SCHEMA demand GRANT ALL ON TABLES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA demand GRANT ALL ON SEQUENCES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA demand GRANT EXECUTE ON FUNCTIONS TO oeuser;
COMMENT ON SCHEMA demand IS '{
"name": "Demand",
"description": "Consumption and use of energy",
"examples": "Peak loads, load curves, load areas",
"contributors": [
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2016-09-12",
		"comment": "Create schema" },
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2017-06-30",
		"comment": "Update schema metadata" }
		] }';

-- CREATE SCHEMA grid; 
ALTER SCHEMA grid OWNER TO oeuser;
GRANT ALL ON SCHEMA grid TO oeuser WITH GRANT OPTION;
ALTER DEFAULT PRIVILEGES IN SCHEMA grid GRANT ALL ON TABLES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA grid GRANT ALL ON SEQUENCES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA grid GRANT EXECUTE ON FUNCTIONS TO oeuser;
COMMENT ON SCHEMA grid IS '{
"name": "Grid",
"description": "Energy transmission infrastructure",
"examples": "Power lines, substation, pipelines",
"contributors": [
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2016-09-12",
		"comment": "Create schema" },
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2017-06-30",
		"comment": "Update schema metadata" }
		] }';

-- CREATE SCHEMA supply; 
ALTER SCHEMA supply OWNER TO oeuser;
GRANT ALL ON SCHEMA supply TO oeuser WITH GRANT OPTION;
ALTER DEFAULT PRIVILEGES IN SCHEMA supply GRANT ALL ON TABLES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA supply GRANT ALL ON SEQUENCES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA supply GRANT EXECUTE ON FUNCTIONS TO oeuser;
COMMENT ON SCHEMA supply IS '{
"name": "Supply",
"description": "Conversion (generation) of energy",
"examples": "Power stations, renewables",
"contributors": [
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2016-09-12",
		"comment": "Create schema" },
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2017-06-30",
		"comment": "Update schema metadata" }
		] }';

-- CREATE SCHEMA environment; 
ALTER SCHEMA environment OWNER TO oeuser;
GRANT ALL ON SCHEMA environment TO oeuser WITH GRANT OPTION;
ALTER DEFAULT PRIVILEGES IN SCHEMA environment GRANT ALL ON TABLES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA environment GRANT ALL ON SEQUENCES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA environment GRANT EXECUTE ON FUNCTIONS TO oeuser;
COMMENT ON SCHEMA environment IS '{
"name": "Environment",
"description": "Environmental resources, protection and conservation",
"examples": "Environmental pollution, waste storage and treatment, environmental impact assessment, monitoring environmental risk, nature reserves, landscape",
"contributors": [
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2016-09-12",
		"comment": "Create schema" },
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2017-06-30",
		"comment": "Update schema metadata" },
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2017-06-30",
		"comment": "Rename schema name" }
		] }';

-- CREATE SCHEMA model_draft; 
ALTER SCHEMA model_draft OWNER TO oeuser;
GRANT ALL ON SCHEMA model_draft TO oeuser WITH GRANT OPTION;
ALTER DEFAULT PRIVILEGES IN SCHEMA model_draft GRANT ALL ON TABLES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA model_draft GRANT ALL ON SEQUENCES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA model_draft GRANT EXECUTE ON FUNCTIONS TO oeuser;
COMMENT ON SCHEMA model_draft IS '{
"name": "Model Draft",
"description": "Modelling sandbox, temp tables",
"examples": "eGo_DataProcessing (eGo_dp), DINGO",
"contributors": [
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2016-09-12",
		"comment": "Create schema" },
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2017-06-30",
		"comment": "Update schema metadata" }
		] }';

-- CREATE SCHEMA reference; 
ALTER SCHEMA reference OWNER TO oeuser;
GRANT ALL ON SCHEMA reference TO oeuser WITH GRANT OPTION;
ALTER DEFAULT PRIVILEGES IN SCHEMA reference GRANT ALL ON TABLES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA reference GRANT ALL ON SEQUENCES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA reference GRANT EXECUTE ON FUNCTIONS TO oeuser;
COMMENT ON SCHEMA reference IS '{
"name": "Reference",
"description": "Sources, literature",
"examples": "Studies, Paper, Websites",
"contributors": [
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2016-09-12",
		"comment": "Create schema" },
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2017-06-30",
		"comment": "Update schema metadata" }
		] }';

-- CREATE SCHEMA scenario; 
ALTER SCHEMA scenario OWNER TO oeuser;
GRANT ALL ON SCHEMA scenario TO oeuser WITH GRANT OPTION;
ALTER DEFAULT PRIVILEGES IN SCHEMA scenario GRANT ALL ON TABLES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA scenario GRANT ALL ON SEQUENCES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA scenario GRANT EXECUTE ON FUNCTIONS TO oeuser;
COMMENT ON SCHEMA scenario IS '{
"name": "Scenario",
"description": "Scenario data",
"examples": "Assumptions, configurations",
"contributors": [
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2016-09-12",
		"comment": "Create schema" },
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2017-06-30",
		"comment": "Update schema metadata" }
		] }';

-- CREATE SCHEMA society; 
ALTER SCHEMA society OWNER TO oeuser;
GRANT ALL ON SCHEMA society TO oeuser WITH GRANT OPTION;
ALTER DEFAULT PRIVILEGES IN SCHEMA society GRANT ALL ON TABLES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA society GRANT ALL ON SEQUENCES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA society GRANT EXECUTE ON FUNCTIONS TO oeuser;
COMMENT ON SCHEMA society IS '{
"name": "Society",
"description": "Characteristics of society and cultures",
"examples": "Settlements, anthropology, archaeology, education, traditional beliefs, manners and customs, demographic data, recreational areas and activities, social impact assessments, crime and justice, census information",
"contributors": [
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2016-09-12",
		"comment": "Create schema" },
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2017-06-30",
		"comment": "Update schema metadata" },
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2017-06-30",
		"comment": "Rename schema name" }
		] }';

-- CREATE SCHEMA public; 
COMMENT ON SCHEMA public IS '{
"name": "Public",
"description": "Cinfiguration tables",
"examples": "QGIS layer styles, OEP tags, Metadata",
"contributors": [
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2016-09-12",
		"comment": "Create schema" },
		{"name": "Ludwig Hülk",
		"email": "",
		"date":  "2017-06-30",
		"comment": "Update schema metadata" }
		] }';
