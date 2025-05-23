GLOBAL_DATUM_INIT(llm_manager, /datum/llm_manager, new)

/datum/llm_manager
	var/list/available_models = list(
		"deepseek/deepseek-chat-v3-0324:free",
		"meta-llama/llama-4-maverick:free"
	)

/datum/llm_manager/proc/run_request(list/additional_data)
	RETURN_TYPE(/datum/http_request)
	var/list/headers = list(
		"Content-Type" = "application/json",
		"Authorization" = "Bearer [CONFIG_GET(string/llm_api_key)]"
	)
	var/list/body = list(
		"model" = available_models[1]
	)
	body.Add(additional_data)

	return SShttp.make_sync_request(RUSTG_HTTP_METHOD_POST, CONFIG_GET(string/llm_endpoint), json_encode(body), headers)


/datum/llm_manager/proc/get_simple_completition(message)
	var/list/body = list(
		"messages" = list(
			"role" = "user",
			"content" = message
		)
	)
	var/datum/http_response/response = run_request(body)

	if(response.errored || response.status_code != 200)
		stack_trace("Huh")

	var/list/data = json_decode(response.body)

	return data["choices"]["message"]["content"]

/client/verb/test_llm(msg as text)
	set name = "Test"
	set category = "LLM"

	var/result = GLOB.llm_manager.get_simple_completition(msg)
	to_chat(src, result)
