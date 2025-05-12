/obj/structure/closet/crate/freezer/food/ingridients
	name = "Всячина"

/obj/structure/closet/crate/freezer/food/ingridients/PopulateContents()
	. = ..()
	for(var/food_path in subtypesof(/obj/item/food/grown))
		for(var/i in 1 to 4)
			new food_path(src)

/obj/machinery/smartfridge/full_food
	name = "Всячина"
	max_n_of_items = SHORT_REAL_LIMIT
	light_flags = LIGHT_FROZEN

/obj/machinery/smartfridge/full_food/New()
	. = ..()
	for(var/food_path in subtypesof(/obj/item/food/grown))
		initial_contents += list("[food_path]" = 100)
