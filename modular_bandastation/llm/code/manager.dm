SUBSYSTEM_DEF(llm)
	name = "LLM Manager"

	var/list/available_models = list(
		"deepseek/deepseek-chat-v3-0324:free",
		"meta-llama/llama-4-maverick:free"
	)

/datum/controller/subsystem/llm/Initialize()
	if(!can_run())
		return SS_INIT_NO_NEED

	world.log << SSllm.get_simple_completition("Привет, ИИ. Готов к смене?")

	return SS_INIT_SUCCESS

/datum/controller/subsystem/llm/proc/can_run()
	return CONFIG_GET(string/llm_endpoint) && CONFIG_GET(string/llm_api_key)

/datum/controller/subsystem/llm/proc/run_request(list/additional_data) as /datum/http_response
	var/list/headers = list(
		"Content-Type" = "application/json",
		"Authorization" = "Bearer [CONFIG_GET(string/llm_api_key)]"
	)
	var/list/body = list(
		"model" = available_models[1]
	)
	body.Add(additional_data)

	world.log << json_encode(body)
	return SShttp.make_sync_request(RUSTG_HTTP_METHOD_POST, CONFIG_GET(string/llm_endpoint), json_encode(body), headers)


/datum/controller/subsystem/llm/proc/get_simple_completition(message) as text
	var/list/body = list(
		"messages" = list(
			list(
			"role" = "user",
			"content" = message
		)
		)
	)
	var/datum/http_response/response = run_request(body)

	if(response.errored || response.status_code != 200)
		stack_trace("LLM request failed with error:	[response.error ? response.error : response.body]")
		return

	var/list/data = json_decode(response.body)

	return data["choices"]["message"]["content"]

/client/verb/test_llm(msg as text)
	set name = "Test"
	set category = "LLM"

	var/result = SSllm.get_simple_completition(msg)
	to_chat(src, result)
