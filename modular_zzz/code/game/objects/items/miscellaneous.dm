/obj/item/choice_beacon/personal_pets
	name = "Personal pets beacon"
	desc = "Summon your personal pet."
	icon_state = "sb_delivery"
	inhand_icon_state = "sb_delivery"
	w_class = WEIGHT_CLASS_TINY

/obj/item/choice_beacon/personal_pets/generate_display_names()
	var/static/list/pets
	if(!pets)
		pets = list(
		"Danik" = /mob/living/basic/pet/dog/corgi/danik,
		"Korka" = /mob/living/basic/pet/fox/eldritch_fennec,
		"Moro" = /mob/living/basic/pet/cat/moro,
		"Dolbajob" = /mob/living/basic/pet/dog/corgi/Lisa/ada,
		"Judas" = /mob/living/basic/pet/dog/juda,
		"Ordinary" = /mob/living/basic/pet/fox/emma,
		)
	return pets

/obj/item/choice_beacon/personal_allowed_pets
	name = "Personal pets beacon"
	desc = "Summon your personal pet."
	icon_state = "sb_delivery"
	inhand_icon_state = "sb_delivery"
	w_class = WEIGHT_CLASS_TINY

/obj/item/choice_beacon/personal_allowed_pets/generate_display_names()
	var/static/list/pets
	if(!pets)
		pets = list(
		"Alta" = /mob/living/basic/pet/cat/alta,
		"Space Alta" = /mob/living/basic/pet/cat/space/alta,
		"Jruttie" = /mob/living/basic/pet/cat/jruttie
		)
	return pets
