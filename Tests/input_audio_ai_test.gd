extends SceneTree
var game
var failures:=0
func _initialize() -> void:
	call_deferred("run_checks")
func check(condition: bool, text: String) -> void:
	if condition:
		print("PASS: "+text)
	else:
		failures+=1
		push_error(text)
func press_key(code: int) -> void:
	var event:=InputEventKey.new()
	event.pressed=true
	event.physical_keycode=code
	event.keycode=code
	game._input(event)
func run_checks() -> void:
	game=load("res://Scenes/main.tscn").instantiate()
	game.focus_pause_enabled=false
	root.add_child(game)
	await process_frame
	game.key_bindings.clear()
	game.configure_input()
	game.show_settings()
	game.pending_rebind="attack0"
	press_key(KEY_H)
	check(game.key_label("attack0")=="H" and game.pending_rebind.is_empty(),"New primary key accepted and shown")
	var h:=InputEventKey.new()
	h.physical_keycode=KEY_H
	check(InputMap.event_is_action(h,"attack0"),"Rebound key actually controls attack")
	var j:=InputEventKey.new()
	j.physical_keycode=KEY_J
	check(not InputMap.event_is_action(j,"attack0"),"Old primary binding removed")
	game.pending_rebind="attack1"
	press_key(KEY_H)
	check(game.pending_rebind=="attack1" and game.key_label("attack1")=="K","Duplicate key rejected without losing old binding")
	press_key(KEY_ESCAPE)
	check(game.screen=="settings" and game.pending_rebind.is_empty(),"Esc cancels rebinding without leaving settings")
	game.pending_rebind="attack1"
	press_key(KEY_LEFT)
	check(game.pending_rebind=="attack1","Arrow keys protected")
	press_key(KEY_ESCAPE)
	game.save_settings()
	game.key_bindings.clear()
	game.load_settings()
	game.configure_input()
	check(game.key_label("attack0")=="H","Rebinding survives save and load")
	var left:=InputEventKey.new()
	left.physical_keycode=KEY_LEFT
	check(InputMap.event_is_action(left,"left"),"Permanent arrows survive rebind")
	game.sound_volume=0.5
	game.play_sound("attack")
	game.play_sound("hit")
	var active_voices:=0
	for voice in game.audio_pool:
		if voice.playing:
			active_voices+=1
	check(active_voices>=2,"Different sound effects overlap on independent voices")
	game.sound_volume=0
	game.update_audio_volume()
	check(game.audio_pool[0].volume_db< -70,"Muting affects sounds already playing")
	game.key_bindings.clear()
	game.configure_input()
	game.sound_volume=0.35
	game.save_settings()
	game.selected_team=["pikachu","glurak","turtok"]
	game.start_fight(false)
	for i in range(30):
		await physics_frame
	var ai=game.get_active(1)
	ai.target=game.get_active(0)
	ai.energy=0
	check(ai.choose_ai_move(200)== -1,"AI never chooses unaffordable attack")
	ai.energy=100
	check(ai.choose_ai_move(2000)== -1,"AI holds fire outside every attack range")
	ai.cooldowns=[10.0,0.0,10.0,10.0]
	check(ai.choose_ai_move(200)==1,"AI respects cooldowns when selecting moves")
	ai.cooldowns=[0.0,0.0,0.0,0.0]
	game.combat_rng.seed=551
	var selected:int=ai.choose_ai_move(150)
	game.combat_rng.seed=551
	for i in range(100):
		game.visual_rng.randf()
	check(ai.choose_ai_move(150)==selected,"Visual randomness does not change AI decision")
	game.queue_free()
	await process_frame
	await process_frame
	print("INPUT/AUDIO/AI FAILURES: ",failures)
	quit(0 if failures==0 else 1)

