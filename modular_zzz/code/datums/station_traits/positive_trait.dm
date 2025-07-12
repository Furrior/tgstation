/datum/station_trait/assistants_as_expeditioners
	name = "All assistants expeditioners now"
	report_message = "Мы решили записать абсолютно всех ассистентов в Экспедиционные Войска. Теперь у них есть доступ к ЕВА и к Гейту."
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	cost = STATION_TRAIT_COST_LOW
	show_in_report = TRUE

/datum/station_trait/assistants_as_expeditioners/on_round_start()
	. = ..()

	var/datum/id_trim/job/assistant/assistant_trim = SSid_access.trim_singletons_by_path[/datum/id_trim/job/assistant]
	if(assistant_trim)
		assistant_trim.access |= list(
			ACCESS_GATEWAY,
			ACCESS_EVA,
			ACCESS_MAINT_TUNNELS,
			ACCESS_EXTERNAL_AIRLOCKS,
			ACCESS_WEAPONS
		)
		assistant_trim.minimal_access |= list(
			ACCESS_GATEWAY,
			ACCESS_EVA,
			ACCESS_MAINT_TUNNELS,
			ACCESS_EXTERNAL_AIRLOCKS,
			ACCESS_WEAPONS
		)
		assistant_trim.extra_access |= list(
			ACCESS_GATEWAY,
			ACCESS_EVA,
			ACCESS_MAINT_TUNNELS,
			ACCESS_EXTERNAL_AIRLOCKS,
			ACCESS_WEAPONS
		)

	for(var/obj/item/card/id/advanced/id_card in world)
		if(istype(id_card.trim, /datum/id_trim/job/assistant))
			SSid_access.apply_trim_to_card(id_card, /datum/id_trim/job/assistant)
			id_card.registered_account.adjust_money(5000, "Expedition Corps Bonus")

	addtimer(CALLBACK(src, PROC_REF(send_expedition_announcement)), 5 MINUTES)

/datum/station_trait/assistants_as_expeditioners/proc/send_expedition_announcement()
	priority_announce(
		"ВНИМАНИЕ! Все ассистенты станции [station_name()] официально записаны в Экспедиционный Корпус Nanotrasen. \
		Вам выданы расширенные доступы к EVA и к Гейту, а также бонус в размере 5000 кредитов на ваши банковские счета. \
		Ваша новая миссия: поиск и исследование артефактов в космическом пространстве и через Гейт. \
		Используйте предоставленное оборудование ответственно и соблюдайте протоколы безопасности. \
		Удачи в ваших экспедициях!",
		"Экспедиционный Корпус Nanotrasen",
		'sound/announcer/announcement/announce_syndi.ogg'
	)
