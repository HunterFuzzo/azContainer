Config = {}

Config.StashLocation = {x = -441.56, y = -920.26, z = 29.39, h = 30}

Config.NPCs = {
    {
        type = 'shop',
        model = 'a_m_m_business_01',
        coords = {x = -455.4, y = -906.0, z = 29.39, h = 270.0},
        label = 'Epicerie',
        items = {
            {name = 'CONSUMABLE_BANDAGE', label = 'Bandage', price = 100},
            {name = 'CONSUMABLE_MEDKlT', label = 'Kit de soin', price = 250},
            {name = 'EQUIPMENT_KEVLAR', label = 'Kevlar', price = 500},
            {name = 'CONSUMABLE_GREEN_SYRINGE', label = 'Seringue Verte', price = 750},
            {name = 'CONSUMABLE_RED_SYRINGE', label = 'Seringue Rouge', price = 750},
            {name = 'CONSUMABLE_BLUE_SYRINGE', label = 'Seringue Bleue', price = 750},
            {name = 'AMMO_12', label = 'Munitions 12 Gauge', price = 150},
            {name = 'AMMO_45', label = 'Munitions .45 ACP', price = 150},
            {name = 'AMMO_50', label = 'Munitions .50 AE', price = 200},
            {name = 'AMMO_556', label = 'Munitions 5.56mm', price = 250},
            {name = 'AMMO_762', label = 'Munitions 7.62mm', price = 300},
            {name = 'AMMO_ROCKET', label = 'Roquette', price = 1500},
        }
    },
    {
        type = 'weapon',
        model = 'a_m_m_business_01',
        coords = {x = -441.56, y = -916.43, z = 29.39, h = 90},
        label = 'Armurier'
    },
    {
        type = 'vehicle',
        model = 'a_m_y_stbla_02',
        coords = {x = -441.66, y = -906.43, z = 29.39, h = 90},
        label = 'Mecano'
    },
    {
        type = 'clothing',
        model = 'a_f_y_bevhills_01',
        coords = {x = -441.66, y = -897.42, z = 29.39, h = 90},
        label = 'Vestiaire'
    },
    {
        type = 'teleporter',
        model = 's_m_m_security_01',
        coords = {x = -447.66, y = -895.31, z = 29.39, h = 180},
        label = 'Teleporteur',
        locations = {
            {label = 'Commissariat', coords = vector3(425.1, -979.5, 30.7)},
            {label = 'Hopital', coords = vector3(291.3, -581.7, 43.2)},
            {label = 'Place Cubes', coords = vector3(185.7, -929.0, 30.6)},
        }
    }
}
