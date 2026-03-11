ALTER TABLE `users` ADD COLUMN `container` LONGTEXT NULL DEFAULT '[]';
ALTER TABLE `users` ADD COLUMN `weapon_components` LONGTEXT NULL DEFAULT '{}';
