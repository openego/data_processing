
DROP FUNCTION IF EXISTS ST_SAFE_INTERSECTION(geom_a geometry, geom_b geometry);
CREATE OR REPLACE FUNCTION ST_SAFE_INTERSECTION(geom_a geometry, geom_b geometry)
RETURNS geometry AS
$$
BEGIN
    RETURN ST_Intersection(geom_a, geom_b);
    EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                RETURN ST_Intersection(ST_Buffer(geom_a, 0.0000001), ST_Buffer(geom_b, 0.0000001));
                EXCEPTION
                    WHEN OTHERS THEN
                        RETURN ST_GeomFromText('POLYGON EMPTY');
    END;
END
$$
LANGUAGE 'plpgsql' STABLE STRICT;

-- Grant oeuser   (OK!) -> 100ms =0
ALTER FUNCTION		public.st_safe_intersection(geometry, geometry) OWNER TO ludwig_schneider;
