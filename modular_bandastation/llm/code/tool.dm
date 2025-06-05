/datum/llm_tool
	var/tool_name = "override_me"
	var/tool_description = "override_me"
	var/list/parameter_schema = list(
		"type" = "object",
		"properties" = list(),
		"required" = list()
	)

// Arguments will be a DM list parsed from the LLM's JSON arguments
// Should return a value that can be json_encode'd, or a JSON string directly.
/datum/llm_tool/proc/execute(list/arguments)
	CRASH("Tool [type] does not implement execute()")

/datum/llm_tool/get_round_time
	tool_name = "get_round_time"
	tool_description = "Gets the current in-round time (time passed since the start of the round)."
	parameter_schema = list(
		"type" = "object",
		"properties" = list(),
		"required" = list()
	)

/datum/llm_tool/get_round_time/execute(list/arguments)
	return list("round_time" = STATION_TIME_PASSED())


/datum/llm_tool/output_to_world
	tool_name = "output_to_world_chat"
	tool_description = "Broadcasts a message to all players in the game world. Use this to make announcements or share information globally."

	parameter_schema = list(
		"type" = "object",
		"properties" = list(
			"message" = list(
				"type" = "string",
				"description" = "The text content of the message to be broadcast to everyone in the game world."
			),
		),
		"required" = list("message")
	)

/datum/llm_tool/output_to_world/execute(list/arguments)
		var/message_to_broadcast = arguments["message"]

		world.log << "AI Broadcasting message: [message_to_broadcast]"
		return list("broadcasted_message" = message_to_broadcast)
