-- SQL for vehicle presets
ALTER TABLE `users` ADD COLUMN IF NOT EXISTS `vehicle_presets` LONGTEXT DEFAULT '{}';
