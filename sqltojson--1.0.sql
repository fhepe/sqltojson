--complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION sqltojson" to load this file. \quit


CREATE OR REPLACE FUNCTION public.SQLTOJSON(ASelect text) 
RETURNS SETOF RECORD AS $$
declare
  sCampoAntigo text;
  sCampoNovo text;
  r RECORD;
begin
  loop  
    sCampoAntigo = trim(split_part(ASelect, '$', 2));
    EXIT WHEN sCampoAntigo = '';
    sCampoNovo = '%s';
    if (substring(sCampoAntigo from 1 for 1) = '!') then
      sCampoNovo = 'cast(%s as integer)'; 
    elsif (substring(sCampoAntigo from 1 for 1) = '@') then
      sCampoNovo = 'cast(%s as numeric(18,2))';
    end if;
          
    sCampoNovo = replace(sCampoNovo, '%s', 'data->>''' || sCampoAntigo || '''');
    ASelect = REPLACE(ASelect, '$' || sCampoAntigo || '$', sCampoNovo);
    ASelect = REPLACE(ASelect, '!', '');
    ASelect = REPLACE(ASelect, '@', '');    
  END LOOP;
  
  for r in EXECUTE ASelect loop
    return next r;
  end loop;
  return;
end
$$ LANGUAGE plpgsql;