extends Node

enum LANGUAGE {ENGLISH, DANISH}
enum PLAYABLE_CHARACTER {GAWAIN}
enum SELECTABLE_OBJECT {GIRDLE}

func get_language_name(language: LANGUAGE) -> String:
	match language:
		LANGUAGE.ENGLISH:
			return "english"
		LANGUAGE.DANISH:
			return "danish"
		_:
			return "english"

func get_playable_character_name(playable_character: PLAYABLE_CHARACTER) -> String:
	match playable_character:
		PLAYABLE_CHARACTER.GAWAIN:
			return "gawain"
		_:
			return "gawain"

func get_selectable_object(selectable_object_name: String) -> SELECTABLE_OBJECT:
	match selectable_object_name:
		"girdle":
			return SELECTABLE_OBJECT.GIRDLE
		_:
			return SELECTABLE_OBJECT.GIRDLE

func get_selectable_object_name(selectable_object: SELECTABLE_OBJECT) -> String:
	match selectable_object:
		SELECTABLE_OBJECT.GIRDLE:
			return "girdle"
		_:
			return "girdle"
