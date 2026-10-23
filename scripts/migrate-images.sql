-- Moves existing servers from ghcr.io/ptero-eggs/yolks to the patched daki-yolks images.
-- Only versions that daki-yolks builds are changed. EOL versions stay on their old image.
--
-- Backup first: mysqldump -u root -p panel servers > ~/servers-backup-$(date +%F).sql
-- Run:          mysql -u root -p panel, then: source migrate-images.sql
-- The transaction stays open: check the numbers, then type COMMIT; or ROLLBACK;
-- Takes effect on the next start/restart of each server.

USE panel;

-- Before
SELECT image, COUNT(*) AS servers FROM servers GROUP BY image ORDER BY image;

START TRANSACTION;

-- Same version, only patched: safe
UPDATE servers
SET image = REPLACE(image, 'ghcr.io/ptero-eggs/yolks:', 'ghcr.io/niclasspecht/daki-yolks:')
WHERE image IN (
  'ghcr.io/ptero-eggs/yolks:nodejs_22',
  'ghcr.io/ptero-eggs/yolks:nodejs_24',
  'ghcr.io/ptero-eggs/yolks:python_3.11',
  'ghcr.io/ptero-eggs/yolks:python_3.12',
  'ghcr.io/ptero-eggs/yolks:python_3.13'
);

-- Optional: force EOL versions onto a supported one. Announce this to customers first,
-- major upgrades need native modules (Node) or venvs/pip packages (Python) to be rebuilt.
-- UPDATE servers SET image = 'ghcr.io/niclasspecht/daki-yolks:nodejs_26' WHERE image = 'ghcr.io/ptero-eggs/yolks:nodejs_25';
-- UPDATE servers SET image = 'ghcr.io/niclasspecht/daki-yolks:nodejs_24' WHERE image = 'ghcr.io/ptero-eggs/yolks:nodejs_23';
-- UPDATE servers SET image = 'ghcr.io/niclasspecht/daki-yolks:nodejs_22' WHERE image IN (
--   'ghcr.io/ptero-eggs/yolks:nodejs_18', 'ghcr.io/ptero-eggs/yolks:nodejs_19',
--   'ghcr.io/ptero-eggs/yolks:nodejs_20', 'ghcr.io/ptero-eggs/yolks:nodejs_21');
-- UPDATE servers SET image = 'ghcr.io/niclasspecht/daki-yolks:python_3.11' WHERE image IN (
--   'ghcr.io/ptero-eggs/yolks:python_3.9', 'ghcr.io/ptero-eggs/yolks:python_3.10');

-- After. Looks right: COMMIT;  Otherwise: ROLLBACK;
SELECT image, COUNT(*) AS servers FROM servers GROUP BY image ORDER BY image;
