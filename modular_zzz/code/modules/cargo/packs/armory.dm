/datum/supply_pack/security/armory/sec_glock // Два Глока, ебать. 1000 за каждый.
	cost = PAYCHECK_COMMAND * 20

/datum/supply_pack/security/armory/sec_glock_ammo // Патроны для стандартного Глока.
	cost = PAYCHECK_COMMAND * 5

/datum/supply_pack/security/armory/alert_level_firing_pin
	cost = PAYCHECK_COMMAND * 5

/datum/supply_pack/security/armory/dragnet // Стандартный инструмент. 1000 кредитов каждый.
	cost = PAYCHECK_COMMAND * 20

/datum/supply_pack/security/armory/battle_rifle // Две НовоТГшной винтовки. Каждая за 3000.
	cost = PAYCHECK_COMMAND * 60

/datum/supply_pack/security/armory/br_mag  // Патроны на винтовку стоят 500.
	cost = PAYCHECK_COMMAND * 5

/datum/supply_pack/security/armory/smartrifle // Довольно мощная винтовка, направленная на доставление стамин-урона.
	cost = CARGO_CRATE_VALUE * 100

/datum/supply_pack/security/armory/short_mod_laser // АЕГ за 5000 кредитов.
	name = "Hoshi Modular Laser Carbines Crate"
	desc = "В ящике находится три модулярных лазерных винтовок с интегрированной автозарядкой."
	cost = PAYCHECK_COMMAND * 150
	contains = list(/obj/item/gun/energy/modular_laser_rifle/carbine = 3)
	crate_name = "Hoshi Modular Laser Carbines Crate"

/datum/supply_pack/security/armory/ballistic // Три Комбат-Дробовика. Каждый за 1500 в связи с отсутствием необходимости дёргать затвор.
	cost = PAYCHECK_COMMAND * 45

/datum/supply_pack/security/armory/wt551 // Две рядовые автоматические винтовки. Каждая за 1500.
	cost = PAYCHECK_COMMAND * 30

/datum/supply_pack/security/armory/wt550_ammo_regular // Патроны на автоматическую винтовку стоят 500.
	cost = PAYCHECK_COMMAND * 5

/datum/supply_pack/security/armory/wespe // 1200 кредитов за каждый набор оружия, их тут три.
	name = "Wespe Three-Pack Crates"
	desc = "Contains three case of the .35 sol handgun, magazines included."
	cost = PAYCHECK_COMMAND * 36
	contains = list(/obj/item/gun/ballistic/automatic/pistol/sol = 3,
		/obj/item/ammo_box/magazine/c35sol_pistol = 3,
		/obj/item/ammo_box/c35sol/incapacitator = 3,
		)
	crate_name = "wespe pistols crate"

/datum/supply_pack/security/armory/miecz // Двенадцать выстрелов на хардкрит без учёта брони. Достаточно дешёвое огнестрельное оружие за 1600.
	name = "Miecz Submachine Gun Single-Pack"
	crate_name = "Miecz submachinegun crate"
	desc = "Contains a Miecz submachinegun and a spare magazine for it."
	contains = list(/obj/item/gun/ballistic/automatic/miecz = 1,
	/obj/item/ammo_box/magazine/miecz = 1)
	cost = PAYCHECK_COMMAND * 16

/datum/supply_pack/security/armory/laser // 500 кредитов за одну единицу летального лазгана.
	cost = PAYCHECK_COMMAND * 15
	contains = list(/obj/item/gun/energy/laser = 3)
	crate_name = "Laser Сrate"

/datum/supply_pack/security/armory/laser_carbine // НовоТГшный скорострельных лазган. Три штуки. 600 за штуку.
	cost = PAYCHECK_COMMAND * 18

/datum/supply_pack/security/armory/eland // 1200 кредитов за каждый набор оружия, их тут три.
	name = "Eland Three-Pack Crates"
	desc = "Contains three case of the .35 sol revolver, munition boxes included."
	cost = PAYCHECK_COMMAND * 36
	contains = list(/obj/item/gun/ballistic/revolver/sol = 3,
		/obj/item/ammo_box/c35sol/incapacitator = 3,
		)
	crate_name = "eland pistols crate"

/datum/supply_pack/security/armory/ionrifle
	cost = PAYCHECK_COMMAND * 20
