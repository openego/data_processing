COMMENT ON TABLE model_draft.ego_renewable_feedin IS '{
	"title": "model_draft.ego_renewable_feedin",
	"description": "Renewable feedin timeseries for each weather cell",
	"language": [],
	"spatial": 
		{"location": "Germany and its electrical neighbours and Baltic Sea/North Sea",
		"extent": "",
		"resolution": "Coastdat2 weather cells"},
	"temporal": 
		{"reference_date": "",
		"start": "",
		"end": "",
		"resolution": ""},
	"sources": [
		{"name": "open_eGo preprocessing", "description": "", "url": "https://github.com/openego/data_processing/tree/master/preprocessing", "license": "", "copyright": ""} ],
	"license": 
		{"id": "",
		"name": "",
		"version": "",
		"url": "",
		"instruction": "",
		"copyright": ""},
	"contributors": [
		{"name": "Marlon Schlemminger", "email": "marlon@wmkamp46a.de", "date": "13.03.2018", "comment": ""}],
	"resources": [
		{"name": "",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "weather_scenario_id", "description": "Identifier for weather data version", "unit": ""},
			{"name": "w_id", "description": "Coastdat2 identifier", "unit": ""},
			{"name": "source", "description": "Renewable energy source", "unit": ""},
			{"name": "weather_year", "description": "Year of weather data", "unit": ""},
			{"name": "feedin", "description": "Feedin timeseries", "unit": "pu"} ] } ],
	"metadata_version": "1.3"}';

-- select description
SELECT obj_description('model_draft.ego_renewable_feedin' ::regclass) ::json;

COMMENT ON TABLE model_draft.ego_power_class IS '{
	"title": "model_draft.ego_power_class",
	"description": "Power classes used for feedin timeseries",
	"language": [],
	"spatial": 
		{"location": "",
		"extent": "",
		"resolution": ""},
	"temporal": 
		{"reference_date": "",
		"start": "",
		"end": "",
		"resolution": ""},
	"sources": [
		{"name": "open_eGo preprocessing", "description": "", "url": "https://github.com/openego/data_processing/tree/master/preprocessing", "license": "", "copyright": ""} ],
	"license": 
		{"id": "",
		"name": "",
		"version": "",
		"url": "",
		"instruction": "",
		"copyright": ""},
	"contributors": [
		{"name": "Marlon Schlemminger", "email": "marlon@wmkamp46a.de", "date": "26.03.2018", "comment": ""}],
	"resources": [
		{"name": "",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "power_class_id", "description": "Identifier for power class", "unit": ""},
			{"name": "lower_limit", "description": "Lower limit of the power class", "unit": "MW"},
			{"name": "upper_limit", "description": "Upper limit of the power class", "unit": "MW"},
			{"name": "wea", "description": "Type of WEA used in this powerclass", "unit": ""},
			{"name": "h_hub", "description": "Hub height of WEA", "unit": "m"},
			{"name": "d_rotor", "description": "Rotor diameter of WEA", "unit": "m"} ] } ],
	"metadata_version": "1.3"}';

-- select description
SELECT obj_description('model_draft.ego_renewable_feedin' ::regclass) ::json;