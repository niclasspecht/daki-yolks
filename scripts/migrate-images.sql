-- Stellt bestehende Server von ghcr.io/ptero-eggs/yolks auf die eigenen Images um.
-- Vorher: mysqldump -u root -p panel servers > ~/servers-backup-$(date +%F).sql
-- Ausführen: mysql -u root -p panel, dann: source migrate-images.sql
-- Die Transaktion bleibt offen: Zahlen prüfen, dann COMMIT; oder ROLLBACK; eintippen.
-- Wirkt erst beim nächsten Start/Restart eines Servers.

USE panel;

-- Bestand vorher
SELECT image, COUNT(*) AS servers FROM servers GROUP BY image ORDER BY image;

START TRANSACTION;

-- 1) Gleiche Version, nur gepatcht: risikolos
UPDATE servers
SET image = REPLACE(image, 'ghcr.io/ptero-eggs/yolks:', 'ghcr.io/niclasspecht/daki-yolks:')
WHERE image IN (
  'ghcr.io/ptero-eggs/yolks:nodejs_22',
  'ghcr.io/ptero-eggs/yolks:nodejs_24',
  'ghcr.io/ptero-eggs/yolks:python_3.11',
  'ghcr.io/ptero-eggs/yolks:python_3.12',
  'ghcr.io/ptero-eggs/yolks:python_3.13'
);

-- 2) EOL-Versionen: erst nach Ankündigung an die Kunden einkommentieren.
--    Major-Sprung, native Module (Node) bzw. venv/pip-Pakete (Python) müssen neu gebaut werden.
-- UPDATE servers SET image = 'ghcr.io/niclasspecht/daki-yolks:nodejs_26' WHERE image = 'ghcr.io/ptero-eggs/yolks:nodejs_25';
-- UPDATE servers SET image = 'ghcr.io/niclasspecht/daki-yolks:nodejs_24' WHERE image = 'ghcr.io/ptero-eggs/yolks:nodejs_23';
-- UPDATE servers SET image = 'ghcr.io/niclasspecht/daki-yolks:nodejs_22' WHERE image IN (
--   'ghcr.io/ptero-eggs/yolks:nodejs_18', 'ghcr.io/ptero-eggs/yolks:nodejs_19',
--   'ghcr.io/ptero-eggs/yolks:nodejs_20', 'ghcr.io/ptero-eggs/yolks:nodejs_21');
-- UPDATE servers SET image = 'ghcr.io/niclasspecht/daki-yolks:python_3.11' WHERE image IN (
--   'ghcr.io/ptero-eggs/yolks:python_3.9', 'ghcr.io/ptero-eggs/yolks:python_3.10');

-- Bestand nachher. Passt es: COMMIT;  Sonst: ROLLBACK;
SELECT image, COUNT(*) AS servers FROM servers GROUP BY image ORDER BY image;

