
/////BONE FIXING SURGERIES//////

///// Repair Hairline Fracture (Severe)
/datum/surgery/repair_bone_hairline
	name = "Сращивание перелома (трещины) кости"
	surgery_flags = SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB | SURGERY_REQUIRES_REAL_LIMB
	targetable_wound = /datum/wound/blunt/bone/severe
	possible_locs = list(
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_LEG,
		BODY_ZONE_L_LEG,
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
	)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/repair_bone_hairline,
		/datum/surgery_step/close,
	)

///// Repair Compound Fracture (Critical)
/datum/surgery/repair_bone_compound
	name = "Сращивание открытого перелома кости"
	surgery_flags = SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB | SURGERY_REQUIRES_REAL_LIMB
	targetable_wound = /datum/wound/blunt/bone/critical
	possible_locs = list(
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_LEG,
		BODY_ZONE_L_LEG,
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
	)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/reset_compound_fracture,
		/datum/surgery_step/repair_bone_compound,
		/datum/surgery_step/close,
	)

//SURGERY STEPS

///// Repair Hairline Fracture (Severe)
/datum/surgery_step/repair_bone_hairline
	name = "Устраните закрытый перелом кости (костоправ/костный гель/хирургическая лента)"
	implements = list(
		TOOL_BONESET = 100,
		/obj/item/stack/medical/bone_gel = 100,
		/obj/item/stack/sticky_tape/surgical = 100,
		/obj/item/stack/sticky_tape/super = 50,
		/obj/item/stack/sticky_tape = 30)
	time = 40

/datum/surgery_step/repair_bone_hairline/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(surgery.operated_wound)
		display_results(
			user,
			target,
			span_notice("Вы приступаете к устранению перелома в [parse_zone(user.zone_selected)] у [target]..."),
			span_notice("[user] приступает к устранению перелома в [parse_zone(user.zone_selected)] у [target] при помощи [tool.name]."),
			span_notice("[user] приступает к устранению перелома в [parse_zone(user.zone_selected)] у [target]."),
		)
		display_pain(target, "Ваш [parse_zone(user.zone_selected)] испытывает сильную боль!")
	else
		user.visible_message(span_notice("[user] ищет у [target] в [parse_zone(user.zone_selected)]."), span_notice("Вы ищете у [target] в [parse_zone(user.zone_selected)]..."))

/datum/surgery_step/repair_bone_hairline/success(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(surgery.operated_wound)
		if(isstack(tool))
			var/obj/item/stack/used_stack = tool
			used_stack.use(1)
		display_results(
			user,
			target,
			span_notice("Вы успешно устранили перелом в [parse_zone(target_zone)] у [target]."),
			span_notice("[user] успешно устранил перелом в [parse_zone(target_zone)] у [target] при помощи [tool]!"),
			span_notice("[user] успешно устранил перелом в [parse_zone(target_zone)] у [target]!"),
		)
		log_combat(user, target, "успешно устранил закрытый перелом в", addition="COMBAT_MODE: [uppertext(user.combat_mode)]")
		qdel(surgery.operated_wound)
	else
		to_chat(user, span_warning("У [target] нет закрытого перелома здесь!"))
	return ..()

/datum/surgery_step/repair_bone_hairline/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, fail_prob = 0)
	..()
	if(isstack(tool))
		var/obj/item/stack/used_stack = tool
		used_stack.use(1)



///// Reset Compound Fracture (Crticial)
/datum/surgery_step/reset_compound_fracture
	name = "восстановите кость (костоправ)"
	implements = list(
		TOOL_BONESET = 100,
		/obj/item/stack/sticky_tape/surgical = 60,
		/obj/item/stack/sticky_tape/super = 40,
		/obj/item/stack/sticky_tape = 20)
	time = 40

/datum/surgery_step/reset_compound_fracture/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(surgery.operated_wound)
		display_results(
			user,
			target,
			span_notice("Вы начинаете восстанавливать кость в [parse_zone(user.zone_selected)] у [target]..."),
			span_notice("[user] начинает восстанавливать кость в [parse_zone(user.zone_selected)] у [target] при помощи [tool.name]."),
			span_notice("[user] начинает восстанавливать кость в [parse_zone(user.zone_selected)] у [target]."),
		)
		display_pain(target, "Острая боль в [parse_zone(user.zone_selected)] просто невыносима!")
	else
		user.visible_message(span_notice("[user] ищет у [target] в [parse_zone(user.zone_selected)]."), span_notice("Вы ищете у [target] в [parse_zone(user.zone_selected)]..."))

/datum/surgery_step/reset_compound_fracture/success(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(surgery.operated_wound)
		if(isstack(tool))
			var/obj/item/stack/used_stack = tool
			used_stack.use(1)
		display_results(
			user,
			target,
			span_notice("Вы успешно восстановили кость в [parse_zone(target_zone)] у [target]."),
			span_notice("[user] успешно восстановил кость в [parse_zone(target_zone)] у [target] при помощи [tool.name]!"),
			span_notice("[user] успешно восстановил кость в [parse_zone(target_zone)] у [target]!"),
		)
		log_combat(user, target, "успешно восстановил кость в", addition="COMBAT MODE: [uppertext(user.combat_mode)]")
	else
		to_chat(user, span_warning("У [target] нет открытого перелома здесь!"))
	return ..()

/datum/surgery_step/reset_compound_fracture/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, fail_prob = 0)
	..()
	if(isstack(tool))
		var/obj/item/stack/used_stack = tool
		used_stack.use(1)

#define IMPLEMENTS_THAT_FIX_BONES list( \
	/obj/item/stack/medical/bone_gel = 100, \
	/obj/item/stack/sticky_tape/surgical = 100, \
	/obj/item/stack/sticky_tape/super = 50, \
	/obj/item/stack/sticky_tape = 30, \
)


///// Repair Compound Fracture (Crticial)
/datum/surgery_step/repair_bone_compound
	name = "Устраните открытый перелом кости (костный гель/хирургическая лента)"
	implements = IMPLEMENTS_THAT_FIX_BONES
	time = 40

/datum/surgery_step/repair_bone_compound/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(surgery.operated_wound)
		display_results(
			user,
			target,
			span_notice("Вы приступаете к устранению перелома в [parse_zone(user.zone_selected)] у [target]..."),
			span_notice("[user] приступает к устранению перелома в [parse_zone(user.zone_selected)] у [target] при помощи [tool.name]."),
			span_notice("[user] приступает к устранению перелома в [parse_zone(user.zone_selected)] у [target]."),
		)
		display_pain(target, "Острая боль в [parse_zone(user.zone_selected)] просто невыносима!")
	else
		user.visible_message(span_notice("[user] ищет у [target] в [parse_zone(user.zone_selected)]."), span_notice("Вы ищете у [target] в [parse_zone(user.zone_selected)]..."))

/datum/surgery_step/repair_bone_compound/success(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(surgery.operated_wound)
		if(isstack(tool))
			var/obj/item/stack/used_stack = tool
			used_stack.use(1)
		display_results(
			user,
			target,
			span_notice("Вы успешно устранили перелом в [parse_zone(target_zone)] у [target]."),
			span_notice("[user] успешно устранил перелом в [parse_zone(target_zone)] у [target] при помощи [tool]!"),
			span_notice("[user] успешно устранил перелом в [parse_zone(target_zone)] у [target]!"),
		)
		log_combat(user, target, "успешно устранил закрытый перелом в", addition="COMBAT_MODE: [uppertext(user.combat_mode)]")
		qdel(surgery.operated_wound)
	else
		to_chat(user, span_warning("У [target] нет открытого перелома здесь!"))
	return ..()

/datum/surgery_step/repair_bone_compound/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, fail_prob = 0)
	..()
	if(isstack(tool))
		var/obj/item/stack/used_stack = tool
		used_stack.use(1)

/// Surgery to repair cranial fissures
/datum/surgery/cranial_reconstruction
	name = "Восстановление черепа"
	surgery_flags = SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB | SURGERY_REQUIRES_REAL_LIMB
	targetable_wound = /datum/wound/cranial_fissure
	possible_locs = list(
		BODY_ZONE_HEAD,
	)
	steps = list(
		/datum/surgery_step/clamp_bleeders/discard_skull_debris,
		/datum/surgery_step/repair_skull
	)

/datum/surgery_step/clamp_bleeders/discard_skull_debris
	name = "избавьтесь от обломков черепа (гемостат)"
	implements = list(
		TOOL_HEMOSTAT = 100,
		TOOL_WIRECUTTER = 40,
		TOOL_SCREWDRIVER = 40,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/surgery/hemostat1.ogg'

/datum/surgery_step/clamp_bleeders/discard_skull_debris/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете избавляться от мелких обломков черепа в [parse_zone(target_zone)] у [target]..."),
		span_notice("[user] начинает избавляться от мелких обломков черепа в [parse_zone(target_zone)] у [target]..."),
		span_notice("[user] начинает копошиться в [parse_zone(target_zone)] у [target]..."),
	)

	display_pain(target, "Ваш мозг словно пронзают мелкие осколки стекла!")

/datum/surgery_step/repair_skull
	name = "восстановите череп (костный гель/хирургическая лента)"
	implements = IMPLEMENTS_THAT_FIX_BONES
	time = 4 SECONDS

/datum/surgery_step/repair_skull/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	ASSERT(surgery.operated_wound, "Восстановление черепа без ран")

	display_results(
		user,
		target,
		span_notice("Вы приступаете к восстановлению черепа у [target], как только можете..."),
		span_notice("[user] приступает к восстановлению черепа у [target] при помощи [tool.name]."),
		span_notice("[user] приступает к восстановлению черепа у [target]."),
	)

	display_pain(target, "Вы чувствуете, как части черепа трутся о ваш мозг.!")

/datum/surgery_step/repair_skull/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	if (isnull(surgery.operated_wound))
		to_chat(user, span_warning("Череп [target] в порядке!"))
		return ..()


	if (isstack(tool))
		var/obj/item/stack/used_stack = tool
		used_stack.use(1)

	display_results(
		user,
		target,
		span_notice("Вы успешно восстановили череп у [target]."),
		span_notice("[user] успешно восстановил череп у [target] при помощи [tool.name]."),
		span_notice("[user] успешно восстановил череп у [target].")
	)

	qdel(surgery.operated_wound)

	return ..()

#undef IMPLEMENTS_THAT_FIX_BONES
