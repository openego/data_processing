from itertools import count

import pandas as pd
import shapely.geometry as sg
import xarray as xr

import feedinlib.weather as fw


mean = xr.open_mfdataset('./hourly-mean*.nc')
inst = xr.open_mfdataset('./hourly-instantaneous*.nc')
zlvl = xr.open_mfdataset('./zlevel-*.nc')

print('Checking Netcdf file sanity.')
for axis in ['lat', 'lon']:
    assert(mean[axis].equals(inst[axis]))
    assert(inst[axis].equals(zlvl[axis]))
print('Done.')

print('Generating point/integer index tuples.')
piits = [(
            sg.Point(float(zlvl['lon'][yi, xi]), float(zlvl['lat'][yi, xi])),
            (yi, xi))
        for yi in range(len(zlvl['rlat']))
        for xi in range(len(zlvl['rlon']))]
print('Generating lookup table: coordinates -> integer indexes')
grid = {(point.x, point.y): gridpoint
        for point, gridpoint  in piits}
print('Done.')

print('Generating `points` triples.')
points = ((IDs[gridpoint], gtype, point)
        for point, gridpoint in piits
        for gtype in ['wind_offshore', 'wind_onshore', 'solar'])
print('Done.')

print('Generating bounds.')
bounds = {
        'mean':[(list(b.values)[0], list(b.values)[1]) for b in mean.time_bnds],
        'inst':[(list(b.values)[0], list(b.values)[1]) for b in inst.time_bnds],
        # zlevel time_bnds don't have a unit attribute so they are messed up.
        # hackishly/forcefully using mean ones for this.
        'zlvl':[(list(b.values)[0], list(b.values)[1]) for b in mean.time_bnds]}
print('Done.')

print('Gnerating IDs.')
IDs = {gridpoint: ID for (ID, gridpoint) in zip(count(1300000), grid.values())}
print('Done.')


def resample(dataarray, bounds):
    series = dataarray.to_series()
    half = pd.Timedelta('30M')
    series.index = pd.DatetimeIndex((b[0] for b in bounds))
    if series.index[0].minute == 30:
        series = pd.Series(
                series[0],
                index=pd.DatetimeIndex([series.index[0]-half])).append(series)
    if pd.DatetimeIndex((b[1] for b in bounds))[-1].minute == 30:
        series = series[:-1]
    series.index = series.index.tz_localize('UTC').tz_convert('Etc/GMT+1')
    return series.resample('H', label='right').mean()


def get_weather(conn, geom, weather_year):
    """Create an oemof weather object for the given geometry"""
    index_of_80 = [n for n,flag in enumerate(zlvl['height'] == 80) if flag][0]
    variables = (
        ('ASWDIFD_S', 'dhi', (slice(None),), 'mean'),
        ('ASWDIR_S', 'dirhi', (slice(None),), 'mean'),
        ('P', 'pressure', (slice(None), index_of_80), 'zlvl'),
        ('T', 'temp_air', (slice(None), index_of_80), 'zlvl'),
        ('WSS', 'v_wind', (slice(None), index_of_80), 'zlvl'),
        ('Z0', 'z0', (slice(None),), 'inst'))

    time_series = {
            v[1]: resample(
                globals()[v[3]][v[0]][v[2] + grid[geom.x, geom.y]],
                bounds[v[3]])
            for v in variables}

    tsindexes = [ts.index for ts in time_series.values()]
    for n in list(range(len(tsindexes)-1)):
        try:
            assert(tsindexes[n].equals(tsindexes[n+1]))
        except AssertionError as e:
            import pudb
            pu.db

    weather = fw.FeedinWeather()
    data_height = {}
    # Create a pandas.DataFrame with the time series of the weather data set
    weather_df = pd.DataFrame(index=tsindexes[0])
    for key in time_series:
        weather_df[key] = time_series[key]
        data_height[key] = 80
    weather.data = weather_df
    weather.timezone = weather_df.index.tz
    weather.longitude = geom.x
    weather.latitude = geom.y
    weather.geometry = geom
    weather.data_height = data_height
    weather.name = IDs[grid[geom.x, geom.y]]
    return weather


