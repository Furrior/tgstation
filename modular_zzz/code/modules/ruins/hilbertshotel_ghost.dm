/obj/item/hilbertshotel/ghostdojo/ui_interact(mob/user, list/modifiers)
	if((SSgamemode.storyteller != /datum/storyteller/extended_low_chaos && user.mind?.antag_datums) || (SSgamemode.storyteller != /datum/storyteller/extended_low_chaos && (HAS_MIND_TRAIT(user, TRAIT_MINDSHIELD))))
		to_chat(user, span_warning("Вы не можете войти в Бесконечные Дормитории из-за своей специальной роли!"))
		return FALSE
	. = ..()
