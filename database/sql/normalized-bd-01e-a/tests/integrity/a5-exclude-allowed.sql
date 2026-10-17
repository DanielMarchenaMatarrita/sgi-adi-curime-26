BEGIN;
INSERT INTO public.reservable_resources (id,name,status,price,currency,pricing_type,updated_at) VALUES (2100000023,'A5 Allowed Resource','ACTIVE',0,'CRC','FREE',timestamp '2026-01-01 00:00:00');
INSERT INTO public.resource_unavailabilities (id,reservable_resource_id,starts_at,ends_at,reason) VALUES (2100000023,2100000023,timestamp '2026-02-01 08:00:00',timestamp '2026-02-01 10:00:00','A5 first allowed interval');
INSERT INTO public.resource_unavailabilities (id,reservable_resource_id,starts_at,ends_at,reason) VALUES (2100000024,2100000023,timestamp '2026-02-01 10:00:00',timestamp '2026-02-01 11:00:00','A5 adjacent allowed interval');
SELECT 'PASS exclude_gist_adjacent_allowed';
ROLLBACK;
