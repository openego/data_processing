# Getting this to work

This script will use openFRED weather data stored in NetCDF files to
generate feedin time series.

Most things are hardcoded so be sure have the prerequisites ready
exactly as described.

## Prerequisites

You need:

  * A PostgreSQL database containing the schemas `model_draft` and
    supply, the tables `model_draft.ego_renewable_feedin`
    `model_draft.openfredgrid` and the extensions `dblink`, `hstore`,
    `plpgsql`, `postgis` and `postgis_topology`. The tables should have
    the same structure as `model_draft.ego_renewable_feedin` and
    `climate.cosmoclm` in the OEDB. You need write privileges for these
    tables.  
    There are also some other tables with power plant data for different
    power classes, but I don't know which ones these are exactly, so you
    have to figure that out for yourself. If you just want to generate
    feedin time series for a single, hardcoded onshore wind power plant,
    revert the commit `Use power classes from db` and change the wind
    turbine parameters directly in `simple_feedin.py`, somewhere around
    line 541.

  * A configuration file located at `'~/.open_eGo/config.ini'`
    specifying how to connect to the database via these fields:

    ```
    [coastdat]
    username = USERNAME
    db       = DATABASE_NAME
    host     = DATABASE_HOST_IP_OR_NAME
    port     = DATABASE_PORT
    password = PASSWORT_FOR_USERNAME
    ```

    The `[coastdat]` header is mandatory.

  * The NetCDF files for the timespan for which you want to generate
    feedins. The maximum time span is one year and you should not cross
    year boundaries. Also, make sure to ONLY have the files for the
    timespan you want to import downloaded, as the script will
    unconditionally import every '*.nc' file it finds in the working
    directory. Having more than one year lying around might mean that
    the year gets importet, but documented as the wrong year.

  * The Python dependencies. Use `pip install -r requirements.txt` to
    install them. Use the `requirements.txt` file that resides in the
    same folder as this `README.md`.


## Running the script

Before running the script, make sure to edit a few lines in
`simple_feedin.py`. Change `weather_year = 2015` to the year you want to
import. You can also change `weather_scenario_id = 2` to a more obscure
number of which only you know what it means. ;) Now you are ready to
run the script via `python PATH/TO/simple_feedin.py`. The NetCDF files
should be in the same directory in which you start the Python
Interpreter. Be sure to use Python 3.

