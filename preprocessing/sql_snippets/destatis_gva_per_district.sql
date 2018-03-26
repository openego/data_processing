﻿/*
Setup for table economic.destatis_gva_per_district		

__copyright__ = "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu" 

*/


-- CREATE TABLE orig_ego_consumption.destatis_gva_per_districts
-- ( 
--   eu_code character varying(7) NOT NULL, 
--   district character varying NOT NULL, 
--   total_gva double precision NOT NULL, 
--   gva_industry double precision NOT NULL, 
--   gva_tertiary_sector double precision NOT NULL, ‐‐ Commercial, trading, public buildings etc. 
-- PRIMARY KEY (eu_code) 
-- ) 
-- ;


--CREATE TABLE economic.destatis_gva_per_district AS
--SELECT * FROM orig_ego_consumption.destatis_gva_per_district; 

  COMMENT ON TABLE  economic.destatis_gva_per_district IS
'{
"Name": "Gross value added per district in Germany",
"Source": [{
                  "Name": "Statistisches Bundesamt (Destatis)- VGR der Länder",
                  "URL":  "https://www.destatis.de/DE/Publikationen/Thematisch/VolkswirtschaftlicheGesamtrechnungen/VGRderLaender/VGR_KreisergebnisseBand1.html" }],
"Reference date": "2011",
"Date of collection": "15.12.2015",
"Original file": "VGR_KreisergebnisseBand1_5820009117005.xls",
"Spatial resolution": ["Germany"],
"Description": ["Gross value added per administrative district for the business sectors industry and tertiary sector"],
"Column": [
                   {"Name": "eu_code",
                    "Description": "nuts id for district",
                    "Unit": "" },
                   {"Name": "district",
                    "Description": "district name",
                    "Unit": "" },
                   {"Name": "total_gva",
                    "Description": "total gross value added per district",
                    "Unit": "Million Euro" },
                   {"Name": "gva_industry",
                    "Description": "gross value added of industry per district",
                    "Unit": "Mullion Euro" },
                   {"Name": "gva_tertiary_sector",
                    "Description": "gross value added of tertiary sector per district",
                    "Unit": "Million Euro" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }, 
                    
                   {"Name": "Ilka Cussmann",
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "25.10.2016",
                    "Comment": "Completed json-string" }, 

                   {"Name": "Ilka Cussmann",
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "01.02.2017",
                    "Comment": "Add licence" },
                    
                  ],
"ToDo": [""],
"Licence": ["
	"Name":		"Open Database License (ODbL) v1.0",
	"URL":		"http://opendatacommons.org/licenses/odbl/1.0/",
	"Copyright": 	"Flensburg University of Applied Sciences""],
"Instructions for proper use": [""]
}';
