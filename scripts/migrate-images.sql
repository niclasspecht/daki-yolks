-- Points existing servers at the images listed in the Daki eggs, so customers can switch
-- versions themselves again. A server whose image is not in its egg's list shows
-- "Set by an administrator" and the image cannot be changed from the client panel.
--
--   Built versions (Node 22/24/26, Python 3.11-3.15) -> ghcr.io/niclasspecht/daki-yolks
--   EOL versions on older yolk names (parkervcp, pterodactyl) -> ghcr.io/ptero-eggs/yolks
--   EOL versions already on ptero-eggs stay as they are.
--
-- Backup first: mysqldump -u root -p panel servers > ~/servers-backup-$(date +%F).sql
-- Run:          mysql -u root -p panel, then: source migrate-images.sql
-- The transaction stays open: check the numbers, then type COMMIT; or ROLLBACK;
-- Takes effect on the next start/restart of each server.

USE panel;

START TRANSACTION;

-- Same version, only patched: safe
UPDATE servers
SET image = CONCAT('ghcr.io/niclasspecht/daki-yolks:', SUBSTRING_INDEX(image, ':', -1))
WHERE image REGEXP '^(ghcr[.]io/)?(ptero-eggs|parkervcp|pterodactyl)/yolks:(nodejs_(22|24|26)|python_3[.](11|12|13|14|15))$';

-- EOL versions on older yolk names: same version, the name the egg lists
UPDATE servers
SET image = CONCAT('ghcr.io/ptero-eggs/yolks:', SUBSTRING_INDEX(image, ':', -1))
WHERE image REGEXP '^(ghcr[.]io/)?(parkervcp|pterodactyl)/yolks:(nodejs_(18|19|20|21|23|25)|python_3[.](9|10))$';

-- Optional: force EOL versions onto a supported one. Announce this to customers first,
-- major upgrades need native modules (Node) or venvs/pip packages (Python) to be rebuilt.
-- UPDATE servers SET image = 'ghcr.io/niclasspecht/daki-yolks:nodejs_26' WHERE image = 'ghcr.io/ptero-eggs/yolks:nodejs_25';
-- UPDATE servers SET image = 'ghcr.io/niclasspecht/daki-yolks:nodejs_24' WHERE image = 'ghcr.io/ptero-eggs/yolks:nodejs_23';
-- UPDATE servers SET image = 'ghcr.io/niclasspecht/daki-yolks:nodejs_22' WHERE image IN (
--   'ghcr.io/ptero-eggs/yolks:nodejs_18', 'ghcr.io/ptero-eggs/yolks:nodejs_19',
--   'ghcr.io/ptero-eggs/yolks:nodejs_20', 'ghcr.io/ptero-eggs/yolks:nodejs_21');
-- UPDATE servers SET image = 'ghcr.io/niclasspecht/daki-yolks:python_3.11' WHERE image IN (
--   'ghcr.io/ptero-eggs/yolks:python_3.9', 'ghcr.io/ptero-eggs/yolks:python_3.10');

-- After: images per server count
SELECT image, COUNT(*) AS servers FROM servers GROUP BY image ORDER BY image;

-- Servers (of any egg) whose image is still not in their egg's list. Empty is ideal.
SELECT e.name AS egg, s.image, COUNT(*) AS servers
FROM servers s JOIN eggs e ON e.id = s.egg_id
WHERE NOT JSON_CONTAINS(JSON_EXTRACT(e.docker_images, '$.*'), JSON_QUOTE(s.image))
GROUP BY e.name, s.image ORDER BY e.name, s.image;

-- Looks right: COMMIT;  Otherwise: ROLLBACK;
