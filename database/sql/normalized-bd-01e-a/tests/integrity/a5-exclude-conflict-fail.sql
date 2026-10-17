BEGIN;
INSERT INTO public.reservable_resources (id,name,status,price,currency,pricing_type,updated_at) VALUES (2100000021,'A5 Exclusion Resource','ACTIVE',0,'CRC','FREE',timestamp '2026-01-01 00:00:00');
INSERT INTO public.resource_unavailabilities (id,reservable_resource_id,starts_at,ends_at,reason) VALUES (2100000021,2100000021,timestamp '2026-02-01 08:00:00',timestamp '2026-02-01 10:00:00','A5 first synthetic interval');
INSERT INTO public.resource_unavailabilities (id,reservable_resource_id,starts_at,ends_at,reason) VALUES (2100000022,2100000021,timestamp '2026-02-01 09:00:00',timestamp '2026-02-01 11:00:00','A5 conflicting synthetic interval');
ROLLBACK;
