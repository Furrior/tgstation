SUBSYSTEM_DEF(llm)
	name = "LLM Manager"
	wait = 10 SECONDS


	var/list/available_models = list(
		"deepseek/deepseek-chat-v3-0324:free",
		"meta-llama/llama-4-maverick:free",
		"google/gemini-2.5-flash-preview-05-20",
		"google/gemini-2.0-flash-001"
	)
	var/default_model = "google/gemini-2.5-flash-preview-05-20"

	var/list/datum/llm_tool/registered_llm_tools = list()

	var/list/mob/true_ai/true_ais = list()

/datum/controller/subsystem/llm/Initialize()
	if(!can_run())
		logger.Log(LOG_CATEGORY_CONFIG, "LLM Subsystem cannot run (missing endpoint/API key).")
		return SS_INIT_NO_NEED

	registered_llm_tools = list()
	for(var/tool_path as anything in subtypesof(/datum/llm_tool))
		var/datum/llm_tool/tool_instance = new tool_path()
		if(tool_instance)
			registered_llm_tools += tool_instance
			logger.Log(LOG_CATEGORY_DEBUG, "Registered LLM tool: [tool_instance.type] ([tool_instance.tool_name])")

	test()

	return SS_INIT_SUCCESS

/datum/controller/subsystem/llm/fire(resumed)
	for(var/mob/true_ai/true_ai in true_ais)
		true_ai.process_true_ai()


/datum/controller/subsystem/llm/proc/test()
	var/mob/true_ai/true_ai = new()

/datum/controller/subsystem/llm/proc/can_run()
	return CONFIG_GET(string/llm_endpoint) && CONFIG_GET(string/llm_api_key)

/datum/controller/subsystem/llm/proc/get_registered_tool(tool_identifier as anything)
	if(isnull(tool_identifier))
		return null
	for(var/datum/llm_tool/tool in registered_llm_tools)
		if(!tool) continue
		if(ispath(tool_identifier) && istype(tool, tool_identifier))
			return tool
		else if(istext(tool_identifier) && tool.tool_name == tool_identifier)
			return tool
	return null

/datum/controller/subsystem/llm/proc/get_tool_definitions_for_api(list/datum/llm_tool/tools_to_define)
	var/list/tool_definitions = list()
	if(!tools_to_define || !tools_to_define.len)
		return tool_definitions

	for(var/datum/llm_tool/tool in tools_to_define)
		if(!istype(tool, /datum/llm_tool))
			logger.Log(LOG_CATEGORY_RUNTIME, "Non-tool datum encountered in tools_to_define list.", list("datum_path" = "[tool]"))
			continue
		tool_definitions += list(list(
			"type" = "function",
			"function" = list(
				"name" = tool.tool_name,
				"description" = tool.tool_description,
				"parameters" = tool.parameter_schema
			)
		))
	return tool_definitions

/datum/controller/subsystem/llm/proc/format_request_payload(list/messages_history, list/datum/llm_tool/tools_for_this_call)
	var/list/body = list(
		"model" = default_model,
		"messages" = messages_history
	)

	if(tools_for_this_call && tools_for_this_call.len > 0)
		var/list/tool_defs = get_tool_definitions_for_api(tools_for_this_call)
		if(tool_defs && tool_defs.len > 0)
			body["tools"] = tool_defs
			body["tool_choice"] = "auto"
	return body

/datum/controller/subsystem/llm/proc/get_completion_with_iteration(initial_system_prompt as text, initial_user_prompt as text, list/datum/llm_tool/tools_to_offer = null, max_iterations = 8, user = null)
	if(!can_run())
		return "Error: LLM Subsystem not configured (endpoint/API key missing)."

	var/list/messages = list()
	if(initial_system_prompt && initial_system_prompt != "")
		messages += list(list("role" = "system", "content" = initial_system_prompt))
	messages += list(list("role" = "user", "content" = initial_user_prompt))

	var/list/headers = list(
		"Content-Type" = "application/json",
		"Authorization" = "Bearer [CONFIG_GET(string/llm_api_key)]"
	)

	var/list/datum/llm_tool/active_tools_for_interaction
	if(isnull(tools_to_offer))
		active_tools_for_interaction = registered_llm_tools
	else
		active_tools_for_interaction = tools_to_offer

	for(var/iteration = 1; iteration <= max_iterations; iteration++)
		var/list/request_body = format_request_payload(messages, active_tools_for_interaction)

		logger.Log(LOG_CATEGORY_GAME_INTERNET_REQUEST, "LLM Request (Iter [iteration])", list(
			"endpoint" = CONFIG_GET(string/llm_endpoint), // Good to log where it's going
			"model" = request_body["model"],
			"iteration" = iteration
			// "full_body_debug" = json_encode(request_body) // Enable this if very detailed debug is needed, can be verbose
		))
		// For very verbose debugging of the request body, you might use a separate DEBUG log:
		// logger.Log(LOG_CATEGORY_DEBUG, "LLM Request Body (Iter [iteration])", list("body" = json_encode(request_body)))


		var/datum/http_response/response = SShttp.make_sync_request(
			RUSTG_HTTP_METHOD_POST,
			CONFIG_GET(string/llm_endpoint),
			json_encode(request_body),
			headers
		)

		if(!response)
			stack_trace("LLM request critically failed (null HTTP response) on iteration [iteration].") // Keep stack_trace for critical failures
			return "Error: LLM request critically failed (null HTTP response)."

		if(response.errored || response.status_code != 200)
			// stack_trace for unexpected severe errors, logger for operational recording
			logger.Log(LOG_CATEGORY_GAME_INTERNET_REQUEST, "LLM request failed.", list(
				"iteration" = iteration,
				"status_code" = response.status_code,
				"error" = response.error,
				"body" = response.body
			 ))
			// stack_trace("LLM request failed on iteration [iteration]. Status: [response.status_code]. Error: [response.error]. Body: [response.body]")
			return "Error: LLM request failed (Status: [response.status_code]). Check server logs."

		var/list/response_data = json_decode(response.body)
		// logger.Log(LOG_CATEGORY_DEBUG, "LLM RAW Response (Iter [iteration])", list("body" = response.body)) // Uncomment for full response logging

		if(!response_data || !response_data["choices"] || !length(response_data["choices"]))
			logger.Log(LOG_CATEGORY_RUNTIME, "LLM response invalid or no choices.", list(
				"iteration" = iteration,
				"response_body" = response.body
			))
			// stack_trace("LLM response invalid or no choices on iteration [iteration]: [response.body]")
			return "Error: LLM response was invalid or had no choices."

		var/list/assistant_message = response_data["choices"][1]["message"]
		messages += list(assistant_message)

		if(assistant_message["tool_calls"])
			var/list/tool_calls_from_llm = assistant_message["tool_calls"]
			var/list/tool_response_messages_to_add = list()

			for(var/list/tool_call_item in tool_calls_from_llm)
				var/tool_call_id = tool_call_item["id"]
				var/list/function_data = tool_call_item["function"]
				var/function_name = function_data["name"]
				var/function_args_json = function_data["arguments"]
				var/list/function_args = json_decode(function_args_json)

				logger.Log(LOG_CATEGORY_DEBUG, "LLM requests tool execution.", list(
					"tool_name" = function_name,
					"tool_call_id" = tool_call_id,
					"arguments_json" = function_args_json
				))

				var/datum/llm_tool/tool_to_run
				for(var/datum/llm_tool/T in active_tools_for_interaction)
					if(T.tool_name == function_name)
						tool_to_run = T
						break

				var/tool_result_content_json_string = ""
				if(tool_to_run)
					var/tool_execution_result = tool_to_run.execute(function_args, user)
					if(islist(tool_execution_result))
						tool_result_content_json_string = json_encode(tool_execution_result)
					else if(istext(tool_execution_result))
						var/list/json_check = json_decode(tool_execution_result)
						if(json_check && isnull(json_check["error"]))
							tool_result_content_json_string = tool_execution_result
						else
							tool_result_content_json_string = json_encode(list("result" = tool_execution_result))
					else if(isnum(tool_execution_result))
						tool_result_content_json_string = json_encode(list("result" = tool_execution_result))
					else if(isnull(tool_execution_result))
						tool_result_content_json_string = json_encode(list("result" = null))
					else
						tool_result_content_json_string = json_encode(list("error" = "Tool returned an unserializable type: [tool_execution_result]"))
						logger.Log(LOG_CATEGORY_RUNTIME, "LLM Tool returned an unserializable type.", list(
							"tool_name" = function_name,
							"result_type" = "[tool_execution_result]"
						))
				else
					tool_result_content_json_string = json_encode(list("error" = "Tool '[function_name]' not found or not offered in the current context."))
					logger.Log(LOG_CATEGORY_RUNTIME, "LLM requested tool not found or not offered in current context.", list(
						"tool_name" = function_name,
						"offered_tools_count" = active_tools_for_interaction.len
					))

				tool_response_messages_to_add += list(list(
					"role" = "tool",
					"tool_call_id" = tool_call_id,
					"name" = function_name,
					"content" = tool_result_content_json_string
				))

			messages += tool_response_messages_to_add
			// logger.Log(LOG_CATEGORY_DEBUG, "Added tool result(s) to history.", list("count" = tool_response_messages_to_add.len, "iteration" = iteration))
			continue
		else
			if(!isnull(assistant_message["content"]))
				return assistant_message["content"]
			else if(assistant_message["content"] == "")
				return ""
			else
				var/finish_reason = response_data["choices"][1]["finish_reason"]
				logger.Log(LOG_CATEGORY_RUNTIME, "LLM provided no content and no tool calls.", list(
					"finish_reason" = finish_reason,
					"assistant_message" = json_encode(assistant_message)
				))
				return "Error: Assistant provided no usable content, and no further tool calls were requested. (Finish reason: [finish_reason])"

	logger.Log(LOG_CATEGORY_RUNTIME, "Exceeded maximum LLM tool processing iterations.", list(
		"max_iterations" = max_iterations,
		"conversation_history_preview" = json_encode(messages)
	))
	return "Error: Exceeded maximum tool processing iterations ([max_iterations]). The conversation might be stuck or too complex."
