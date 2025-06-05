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
		"crew_monitor_static_data" = manifest_static_data)


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

	return list("message" = message)
