-- Funktion erzeugt aus den relation parts vom type way einen gemittelten geometry point
DROP FUNCTION IF EXISTS st_relation_geometry (members text[]) ;
CREATE OR REPLACE FUNCTION st_relation_geometry (members text[]) 
RETURNS geometry 
AS $$
DECLARE 
way  geometry;
BEGIN
   way = (SELECT ST_SetSRID(ST_MakePoint((max(lon) + min(lon))/200.0,(max(lat) + min(lat))/200.0),900913) 
	  FROM openstreetmap.osm_deu_nodes 
	  WHERE id in (SELECT unnest(nodes) 
             FROM openstreetmap.osm_deu_ways 
             WHERE id in (SELECT trim(leading 'w' from member)::bigint 
			  FROM (SELECT unnest(members) as member) t
	                  WHERE member~E'[w,1,2,3,4,5,6,7,8,9,0]')));        
RETURN way;
END;
$$ LANGUAGE plpgsql;

-- Grant oeuser   (OK!) -> 100ms =0
ALTER FUNCTION		st_relation_geometry (members text[]) OWNER TO oeuser;
