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