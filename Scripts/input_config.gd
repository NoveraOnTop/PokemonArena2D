extends RefCounted
## Configurable primary keys, permanent arrow alternatives and controller mappings.
const DEFAULTS = {"left":KEY_A,"right":KEY_D,"up":KEY_W,"down":KEY_S,"dodge":KEY_SPACE,"attack0":KEY_J,"attack1":KEY_K,"attack2":KEY_L,"attack3":KEY_I,"switch":KEY_R}
const NAMES = {"left":"Nach links","right":"Nach rechts","up":"Nach hinten","down":"Nach vorne","dodge":"Ausweichen","attack0":"Attacke 1","attack1":"Attacke 2","attack2":"Attacke 3","attack3":"Spezialattacke","switch":"Team wechseln"}
const ARROWS = {"left":KEY_LEFT,"right":KEY_RIGHT,"up":KEY_UP,"down":KEY_DOWN}
const RESERVED = [KEY_ESCAPE,KEY_F2,KEY_1,KEY_2,KEY_3,KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN]

static func primary(action: String, overrides: Dictionary) -> int:
	var value = overrides.get(action)
	return value if value is int and value>0 else int(DEFAULTS.get(action,0))

static func label(action: String, overrides: Dictionary) -> String:
	var code := primary(action,overrides)
	return "SPACE" if code==KEY_SPACE else OS.get_keycode_string(code).to_upper()

static func conflict(action: String, code: int, overrides: Dictionary) -> String:
	if code in RESERVED or code<=0:
		return "Diese Taste ist für Pause, Teamplätze oder Pfeilsteuerung reserviert."
	for other in DEFAULTS:
		if other!=action and primary(other,overrides)==code:
			return "Die Taste ist bereits belegt: "+NAMES[other]+"."
	# Q and E remain optional alternatives unless used as a configured primary key.
	return ""

static func apply(overrides: Dictionary) -> void:
	for action in DEFAULTS:
		if InputMap.has_action(action):
			InputMap.erase_action(action)
		InputMap.add_action(action,0.2)
		var event := InputEventKey.new()
		event.physical_keycode = primary(action,overrides)
		InputMap.action_add_event(action,event)
		if ARROWS.has(action):
			var alternate := InputEventKey.new()
			alternate.physical_keycode = ARROWS[action]
			InputMap.action_add_event(action,alternate)
	for pair in [["attack2",KEY_Q],["attack3",KEY_E]]:
		var available := true
		for action in DEFAULTS:
			if primary(action,overrides)==pair[1]:
				available = false
		if available:
			var event := InputEventKey.new()
			event.physical_keycode = pair[1]
			InputMap.action_add_event(pair[0],event)
	var buttons := {"dodge":JOY_BUTTON_A,"attack0":JOY_BUTTON_X,"attack1":JOY_BUTTON_Y,"attack2":JOY_BUTTON_LEFT_SHOULDER,"attack3":JOY_BUTTON_RIGHT_SHOULDER,"switch":JOY_BUTTON_B}
	for action in buttons:
		var event := InputEventJoypadButton.new()
		event.button_index = buttons[action]
		InputMap.action_add_event(action,event)
	for action in ARROWS:
		var event := InputEventJoypadMotion.new()
		event.axis = JOY_AXIS_LEFT_X if action in ["left","right"] else JOY_AXIS_LEFT_Y
		event.axis_value = -1 if action in ["left","up"] else 1
		InputMap.action_add_event(action,event)
