/datum/llm_tool/get_manifest
	tool_name = "get_active_crew_member_list"
	tool_description = "Get a list of all known active crew members on the station, their current locations, roles, health status, etc. Some of data may be missing if the crew member doesnt share it."
	parameter_schema = list(
		"type" = "object",
		"properties" = list(),
		"required" = list()
	)

/datum/llm_tool/get_manifest/execute(list/arguments, mob/user = null)
	var/list/manifest_data = GLOB.manifest.get_manifest()
	var/list/crew_monitor_data = GLOB.crewmonitor.ui_data(user)
	var/list/manifest_static_data = GLOB.crewmonitor.ui_static_data()
	return list(
		"manifest" = manifest_data,
		"crew_monitor_data" = crew_monitor_data,
		"crew_monitor_static_data" = manifest_static_data
	)


/datum/llm_tool/say_message
	tool_name = "say_message"
	tool_description = "Send a message to the station radio system."
	parameter_schema = list(
		"type" = "object",
		"properties" = list(
			"message" = list(
				"type" = "string",
				"description" = "The message to say."
			)
			// TODO: radio channel
		),
		"required" = list(
			"message"
		)
	)

/datum/llm_tool/say_message/execute(list/arguments, mob/user = null)
	var/message = arguments["message"]

	user.say("test say: [message]") // TODO: radio

	return list("said_message" = message)

/datum/llm_tool/get_crew_member_position
	tool_name = "get_crew_member_position"
	tool_description = "Get a crew member's position by their name. If the name is ambiguous or not found, an error will be returned."
	parameter_schema = list(
		"type" = "object",
		"properties" = list(
			"crew_member_name" = list(
				"type" = "string",
				"description" = "The full name of the crew member to find."
			)
			// TODO: radio channel
		),
		"required" = list(
			"crew_member_name"
		)
	)

/datum/llm_tool/get_crew_member_position/execute(list/arguments, mob/user)
	var/name = arguments["crew_member_name"]
	for(var/mob/living/carbon/human/crew_member in GLOB.suit_sensors_list)
		var/potential_name = crew_member.GetVoice()
		if(potential_name != name)
			continue
		var/obj/item/clothing/under/uniform = crew_member.w_uniform
		var/sensor_mode = uniform.sensor_mode
		if(sensor_mode < SENSOR_COORDS)
			return list("error" = "The crew member has tracking disabled")
		return list(
				"area" = get_area_name(crew_member, format_text = TRUE),
				"x" = crew_member.x,
				"y" = crew_member.y,
				"z" = crew_member.z,
			)
	return list("error" = "Cant find such a crew member")


/datum/llm_tool/get_machinery_list
	tool_name = "get_machinery_list"
	tool_description = "Get a list of available machinery in a radius around given coordinates."
	parameter_schema = list(
		"type" = "object",
		"properties" = list(
			"x" = list(
				"type" = "number",
				"description" = "The x coordinate to center the search on."
			),
			"y" = list(
				"type" = "number",
				"description" = "The y coordinate to center the search on."
			),
			"z" = list(
				"type" = "number",
				"description" = "The z coordinate to center the search on."
			),
			"radius" = list(
				"type" = "number",
				"description" = "The radius to search in."
			)
		),
		"required" = list(
			"x",
			"y",
			"z",
			"radius"
		)
	)

/datum/llm_tool/get_machinery_list/execute(list/arguments, mob/user = null)
	// Looks heavy af tbh
	var/list/result = list()
	for(var/obj/machinery/machinery in range(arguments["radius"], locate(arguments["x"], arguments["y"], arguments["z"])))
		result += list(list(
			"name" = machinery.name,
			"class" = machinery.type,
			"x" = machinery.x,
			"y" = machinery.y,
			"z" = machinery.z,
			"reference" = ref(machinery),
			"is_operational" = machinery.is_operational
		))
	return result


/datum/llm_tool/get_machinery_actions_list
	tool_name = "get_machinery_actions_list"
	tool_description = "Get a list of available actions for a given machinery class."
	parameter_schema = list(
		"type" = "object",
		"properties" = list(
			"reference" = list(
				"type" = "string",
				"description" = "Reference that points to the machinery."
			)
		),
		"required" = list(
			"reference"
		)
	)

/obj/machinery/proc/get_ai_actions()
	return list()

/obj/machinery/door/get_ai_actions()
	return list(
		"open" = TYPE_PROC_REF(/obj/machinery/door, open),
		"close" = TYPE_PROC_REF(/obj/machinery/door, close),
		"lock" = TYPE_PROC_REF(/obj/machinery/door, lock),
		"unlock" = TYPE_PROC_REF(/obj/machinery/door, unlock),
	)

/datum/llm_tool/get_machinery_actions_list/execute(list/arguments, mob/user = null)
	var/obj/machinery/machinery = locate(arguments["reference"])
	if(!istype(machinery))
		return list("error" = "Machinery not found")
	return machinery.get_ai_actions()

/datum/llm_tool/perform_machinery_action
	tool_name = "perform_machinery_action"
	tool_description = "Perform an action on a given machinery."
	parameter_schema = list(
		"type" = "object",
		"properties" = list(
			"reference" = list(
				"type" = "string",
				"description" = "The reference of the machinery to perform the action on."
			),
			"action" = list(
				"type" = "string",
				"description" = "The action to perform on the machinery."
			)
		),
		"required" = list(
			"reference",
			"action"
		)
	)

/datum/llm_tool/perform_machinery_action/execute(list/arguments, mob/user = null)
	var/obj/machinery/machinery = locate(arguments["reference"])
	if(!machinery)
		return list("error" = "Machinery not found.")

	var/action = machinery.get_ai_actions()[arguments["action"]]
	if(!action)
		return list("error" = "Action not found.")

	var/action_result = call(machinery, action)()
	return list("result" = action_result)
