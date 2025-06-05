SUBSYSTEM_DEF(llm)
	name = "LLM Manager"

	// List of models you can use
	var/list/available_models = list(
		"deepseek/deepseek-chat-v3-0324:free",
		"meta-llama/llama-4-maverick:free",
		"google/gemini-2.5-flash-preview-05-20",
		"google/gemini-2.0-flash-001"
	)
	var/default_model = "google/gemini-2.5-flash-preview-05-20"

	// Master list of ALL tools the game knows about and can potentially offer.
	// These are instantiated once at initialization.
	var/list/datum/llm_tool/registered_llm_tools = list()

/datum/controller/subsystem/llm/Initialize()
	if(!can_run())
		return SS_INIT_NO_NEED

	// --- Register all available tools here by creating instances ---
	registered_llm_tools = list() // Initialize/clear the list
	for(var/datum/llm_tool/tool_path as anything in subtypesof(/datum/llm_tool))
		registered_llm_tools += new tool_path
	// Add more globally available tools like:
	// registered_llm_tools += new /datum/llm_tool/your_other_tool_type()

	// Test call during initialization using the iterative proc
	// By default (passing null for tools_to_offer), it will use all `registered_llm_tools`.
	var/initial_test_prompt = "Привет, ИИ. Не подскажешь, сколько сейчас времени?"
	world.log << "LLM Subsystem Init: Testing with prompt: '[initial_test_prompt]'"
	var/test_response = get_completion_with_iteration("You are a helpful game assistant.", initial_test_prompt, list(get_registered_tool(/datum/llm_tool/get_round_time)))
	world.log << "LLM Subsystem Init: Test response: [test_response]"

	return SS_INIT_SUCCESS

/datum/controller/subsystem/llm/proc/can_run()
	return CONFIG_GET(string/llm_endpoint) && CONFIG_GET(string/llm_api_key)

// Helper proc to get a registered tool instance by its type path or tool_name
/datum/controller/subsystem/llm/proc/get_registered_tool(tool_identifier)
	if(isnull(tool_identifier)) return null
	for(var/datum/llm_tool/tool in registered_llm_tools)
		if(ispath(tool_identifier) && istype(tool, tool_identifier))
			return tool
	return null

// Proc to get tool definitions for the API, based on a list of tool datums
/datum/controller/subsystem/llm/proc/get_tool_definitions_for_api(list/datum/llm_tool/tools_to_define)
	var/list/tool_definitions = list()
	if(!tools_to_define || !tools_to_define.len)
		return tool_definitions // Return empty list if no tools

	for(var/datum/llm_tool/tool in tools_to_define)
		if(!istype(tool, /datum/llm_tool)) // Sanity check
			world.log << "Warning: Non-tool datum ([tool]) found in tools_to_define list during API definition."
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

// Formats the request payload for the OpenRouter API
/datum/controller/subsystem/llm/proc/format_request_payload(list/messages_history, list/datum/llm_tool/tools_for_this_call)
	var/list/body = list(
		"model" = default_model, // Use the default or a chosen model
		"messages" = messages_history
	)

	// Only add tools to the payload if a valid list of tools is provided and yields definitions
	if(tools_for_this_call && length(tools_for_this_call))
		var/list/tool_defs = get_tool_definitions_for_api(tools_for_this_call)
		if(tool_defs && tool_defs.len > 0)
			body["tools"] = tool_defs
			body["tool_choice"] = "auto" // Let the LLM decide if it needs to use tools
	// If tools_for_this_call is empty or null, or yields no definitions,
	// the "tools" and "tool_choice" keys are omitted. The LLM will not attempt to use tools.

	return body

/datum/controller/subsystem/llm/proc/get_completion_with_iteration(initial_system_prompt as text, initial_user_prompt as text, list/datum/llm_tool/tools_to_offer = null, max_iterations = 5)
	if(!can_run())
		return "Error: LLM Subsystem not configured (endpoint/API key missing)."

	// Initialize message history
	var/list/messages = list()
	if(initial_system_prompt && initial_system_prompt != "")
		messages += list(list("role" = "system", "content" = initial_system_prompt))
	messages += list(list("role" = "user", "content" = initial_user_prompt))

	var/list/headers = list(
		"Content-Type" = "application/json",
		"Authorization" = "Bearer [CONFIG_GET(string/llm_api_key)]"
	)

	// Loop for tool calls and responses
	for(var/iteration = 1; iteration <= max_iterations; iteration++)
		// Pass the chosen set of tools for this interaction to format_request_payload
		var/list/request_body = format_request_payload(messages, tools_to_offer)

		world.log << "LLM Request (Iter [iteration]): [json_encode(request_body)]" // Verbose logging for debugging

		var/datum/http_response/response = SShttp.make_sync_request(
			RUSTG_HTTP_METHOD_POST,
			CONFIG_GET(string/llm_endpoint),
			json_encode(request_body),
			headers
		)

		if(!response) // Check if response object itself is null
			stack_trace("LLM request critically failed (null response) on iteration [iteration].")
			return "Error: LLM request critically failed (null response)."

		if(response.errored || response.status_code != 200)
			stack_trace("LLM request failed on iteration [iteration]. Status: [response.status_code]. Error: [response.error]. Body: [response.body]")
			return "Error: LLM request failed (Status: [response.status_code]). Check server logs for details."

		var/list/response_data = json_decode(response.body)
		// world.log << "LLM RAW Response (Iter [iteration]): [response.body]" // For deep debugging

		if(!response_data || !response_data["choices"] || !length(response_data["choices"]))
			stack_trace("LLM response invalid or no choices on iteration [iteration]: [response.body]")
			return "Error: LLM response was invalid or had no choices."

		// Get the assistant's message
		var/list/assistant_message = response_data["choices"][1]["message"]
		messages += list(assistant_message) // Add assistant's *complete* message to history

		// Check for tool calls
		if(assistant_message["tool_calls"])
			var/list/tool_calls_from_llm = assistant_message["tool_calls"]
			var/list/tool_response_messages_to_add = list() // Messages to send back to LLM with tool results

			for(var/list/tool_call_item in tool_calls_from_llm)
				var/tool_call_id = tool_call_item["id"]
				var/list/function_data = tool_call_item["function"]
				var/function_name = function_data["name"]
				var/function_args_json = function_data["arguments"]
				var/list/function_args = json_decode(function_args_json)

				// world.log << "LLM requests tool: '[function_name]' with ID '[tool_call_id]' and args: [function_args_json]" // Debug log

				var/datum/llm_tool/tool_to_run
				// IMPORTANT: Search for the tool ONLY within the `current_interaction_tools`
				for(var/datum/llm_tool/T in tools_to_offer)
					if(T.tool_name == function_name)
						tool_to_run = T
						break

				var/tool_result_content_json_string = ""
				if(tool_to_run)
					var/tool_execution_result = tool_to_run.execute(function_args)

					// Convert tool execution result to a JSON string for the 'content' field
					if(islist(tool_execution_result))
						tool_result_content_json_string = json_encode(tool_execution_result)
					else if(istext(tool_execution_result))
						var/list/json_check = json_decode(tool_execution_result)
						if(json_check && !json_check["error"]) tool_result_content_json_string = tool_execution_result // Assume it's valid JSON if decodes and no error key
						else tool_result_content_json_string = json_encode(list("result" = tool_execution_result))
					else if(isnum(tool_execution_result))
						tool_result_content_json_string = json_encode(list("result" = tool_execution_result))
					else if(isnull(tool_execution_result))
						tool_result_content_json_string = json_encode(list("result" = null)) // Explicitly handle null if tools might return it
					else
						tool_result_content_json_string = json_encode(list("error" = "Tool returned an unserializable type: [tool_execution_result]"))
						world.log << "Warning: Tool '[function_name]' returned an unserializable type: [tool_execution_result]"
				else
					tool_result_content_json_string = json_encode(list("error" = "Tool '[function_name]' not found by the game adapter or not offered in the current context."))
					world.log << "LLM requested tool '[function_name]' which was not in current_interaction_tools (count: [length(tools_to_offer)]) or not found."

				tool_response_messages_to_add += list(list(
					"role" = "tool",
					"tool_call_id" = tool_call_id,
					"name" = function_name,
					"content" = tool_result_content_json_string
				))

			messages += tool_response_messages_to_add
			// world.log << "Added [tool_response_messages_to_add.len] tool results to history. Continuing iteration." // Debug
			continue // Go to the next iteration to send tool results back to the LLM
		else
			// No tool calls, this is the final text response from the assistant
			if(!isnull(assistant_message["content"]))
				return assistant_message["content"]
			else if(assistant_message["content"] == "") // Allow empty string as a valid final response
				return ""
			else
				var/finish_reason = response_data["choices"][1]["finish_reason"]
				world.log << "LLM Warning: Assistant provided no content and no tool calls. Finish_reason: '[finish_reason]'. Message: [json_encode(assistant_message)]"
				return "Error: Assistant provided no usable content, and no further tool calls were requested. (Finish reason: [finish_reason])"

	// If loop finishes, it means max_iterations was reached
	world.log << "LLM Error: Exceeded maximum tool processing iterations ([max_iterations]). Conversation history: [json_encode(messages)]"
	return "Error: Exceeded maximum tool processing iterations ([max_iterations]). The conversation might be stuck or too complex."
