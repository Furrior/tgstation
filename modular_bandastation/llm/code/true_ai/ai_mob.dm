// TODO?: Make actual ai mob component?

/mob/true_ai
	name = "True AI"
	icon = 'icons/mob/silicon/ai.dmi'
	icon_state = "ai"

	var/list/static/tools

	var/static/os
	var/datum/ai_laws/lawset

	var/list/messages_to_process = list()

/mob/true_ai/Initialize(mapload)
	. = ..()
	SSllm.true_ais += src
	if(!os)
		os = file2text('modular_bandastation/llm/code/true_ai/default_os.md')

	var/default_lawset_path = get_round_default_lawset()
	lawset = new default_lawset_path

	tools = list(
		SSllm.get_registered_tool(/datum/llm_tool/get_manifest)
	)

/mob/true_ai/Destroy()
	. = ..()
	SSllm.true_ais -= src

/mob/true_ai/proc/get_laws()
	var/list/printable_laws = lawset.get_law_list(include_zeroth = TRUE, render_html = FALSE)
	return jointext(printable_laws, "\n")

/mob/true_ai/proc/get_system_instrustions()
	return "[os]\nТвои законы:\n[get_laws()]"

/mob/true_ai/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods, message_range)
	. = ..()
	if(speaker == src)
		return
	messages_to_process += list(list(raw_message, speaker, radio_freq))

/mob/true_ai/proc/process_true_ai()
	se
	if(!length(messages_to_process))
		return

	var/list/formatted_messages = list()
	for(var/list/message in messages_to_process)
		var/message_text = message[1]
		var/atom/movable/speaker = message[2]
		var/radio_freq = message[3]

		var/formatted_message = radio_freq ? "\[[get_radio_name(radio_freq)]\] " : ""
		formatted_message += "[speaker.GetVoice()]: "
		formatted_message += message_text
		formatted_messages += formatted_message

	var/prompt = jointext(formatted_messages, "\n")

	var/response = SSllm.get_completion_with_iteration(get_system_instrustions(), prompt, tools, user = src)
	messages_to_process = list()

	say(response)
