/datum/component/wearertargeting/earprotection/Initialize(valid_slots, reduce_amount = 1)
	. = ..()
	src.valid_slots += list(ITEM_SLOT_EARS_LEFT, ITEM_SLOT_EARS_RIGHT)
