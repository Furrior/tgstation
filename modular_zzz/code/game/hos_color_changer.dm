GLOBAL_LIST_EMPTY(red_decals)
GLOBAL_LIST_EMPTY(security_closets)

/obj/effect/turf_decal/trimline/red/Initialize(mapload)
	. = ..()
	GLOB.red_decals += src

/obj/effect/turf_decal/trimline/red/Destroy(force)
	. = ..()
	GLOB.red_decals -= src

/obj/effect/turf_decal/siding/red/Initialize(mapload)
	. = ..()
	GLOB.red_decals += src

/obj/effect/turf_decal/siding/red/Destroy(force)
	. = ..()
	GLOB.red_decals -= src

/obj/structure/closet/secure_closet/security/sec/Initialize(mapload)
	. = ..()
	GLOB.security_closets += src

/obj/structure/closet/secure_closet/security/sec/Destroy()
	. = ..()
	GLOB.security_closets -= src

/obj/item/hos_color_changer
	name = "Brig Color Changer"
	desc = "Brig Color Changer."
	icon_state = "suspiciousphone"
	base_icon_state = "suspiciousphone"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	icon = 'icons/obj/antags/syndicate_tools.dmi'
	w_class = WEIGHT_CLASS_TINY

/obj/item/hos_color_changer/attack_self(mob/user)
	. = ..()
	user.visible_message(span_notice("[user] тыкается в [src]..."), \
						span_notice("Я начинаю тыкаться в [src]..."))

	if(tgui_alert(user, "Желаешь ли ты перекрасить Бриг в Красный?", "Какой СБшник ты сегодня?", list("Да", "Нет")) == "Да")
		for(var/obj/machinery/rnd/production/techfab/department/security/security_techfab as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/rnd/production/techfab/department/security))
			security_techfab.stripe_color = "#DE3A3A"
			security_techfab.update_icon()
		for(var/obj/machinery/door/airlock/security/security_doors as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/airlock/security))
			security_doors.icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/security2.dmi'
			security_doors.assemblytype = /obj/structure/door_assembly/door_assembly_sec/old
			security_doors.update_icon()
		// for(var/obj/effect/turf_decal/security_decals1 in GLOB.red_decals)
		// 	security_decals1.color = "#DE3A3A"
		// 	security_decals1.Initialize()
		// 	T.AddElement(/datum/element/decal, icon, icon_state, dir, null, layer, alpha, color, null, FALSE, null)
		for(var/obj/structure/closet/secure_closet/security/sec/security_closet in GLOB.security_closets)
			security_closet.icon = 'icons/obj/storage/closet.dmi'
			security_closet.update_icon()
		priority_announce("Кто-то перекрасил Бриг в Красный!", "Red Brig", 'sound/announcer/announcement/announce.ogg', "Central Command")

	qdel(src)
