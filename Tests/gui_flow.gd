extends SceneTree
var game
var failures:=0
func _initialize() -> void:
	call_deferred("run_flow")
func check(value: bool, message: String) -> void:
	if value:
		print("PASS: "+message)
	else:
		failures+=1
		push_error(message)
func click_at(pos: Vector2) -> void:
	var motion:=InputEventMouseMotion.new()
	motion.position=pos
	motion.global_position=pos
	Input.parse_input_event(motion)
	var event:=InputEventMouseButton.new()
	event.position=pos
	event.global_position=pos
	event.button_index=MOUSE_BUTTON_LEFT
	event.pressed=true
	Input.parse_input_event(event)
	await process_frame
	event=event.duplicate()
	event.pressed=false
	Input.parse_input_event(event)
	await process_frame
func key(code: int) -> void:
	var event:=InputEventKey.new()
	event.keycode=code
	event.physical_keycode=code
	event.pressed=true
	Input.parse_input_event(event)
	await process_frame
	event=event.duplicate()
	event.pressed=false
	Input.parse_input_event(event)
	await process_frame
func run_flow() -> void:
	game=load("res://Scenes/main.tscn").instantiate()
	game.focus_pause_enabled=false
	root.add_child(game)
	root.size=Vector2i(1280,720)
	await process_frame
	await click_at(Vector2(200,435))
	check(game.screen=="team","Real GUI click opens team workshop")
	await click_at(Vector2(610,165))
	await click_at(Vector2(160,480))
	check(game.selected_team[2]=="gengar","Real GUI card click changes selected team slot")
	check(game.ARENAS.size()==9,"Team screen shows nine random arena possibilities")
	await click_at(Vector2(150,650))
	await click_at(Vector2(150,550))
	check(game.screen=="settings","Settings button is wired")
	await click_at(Vector2(1100,246))
	check(game.pending_rebind=="attack0","Binding button enters capture mode")
	await key(KEY_H)
	check(game.key_label("attack0")=="H","Actual key event completes rebinding")
	await click_at(Vector2(150,625))
	await click_at(Vector2(220,365))
	check(game.screen=="fight","Start button launches playable combat")
	for i in range(40):
		await physics_frame
	await click_at(Vector2(650,400))
	check(game.get_active(0).cooldowns[0]>0,"Clicking arena fires primary attack through GUI pipeline")
	await key(KEY_ESCAPE)
	check(game.screen=="pause","Esc opens pause during fight")
	await click_at(Vector2(640,415))
	check(game.screen=="menu" and not paused,"Pause menu returns to active main menu")
	game.key_bindings.clear()
	game.selected_team=["pikachu","glurak","turtok"]
	game.arena_id="volcano"
	game.save_settings()
	game.stop_audio()
	game.queue_free()
	await create_timer(0.12).timeout
	print("GUI FLOW FAILURES: ",failures)
	quit(0 if failures==0 else 1)
