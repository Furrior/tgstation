/datum/llm_tool
	var/tool_name = "override_me"
	var/tool_description = "override_me"
	var/list/parameter_schema = list( // JSON Schema as a DM list
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
	tool_description = "Gets the current in-round time."
	parameter_schema = list( // No parameters for this simple tool
		"type" = "object",
		"properties" = list(),
		"required" = list()
	)

/datum/llm_tool/get_round_time/execute(list/arguments)
	return list("round_time" = ROUND_TIME())
