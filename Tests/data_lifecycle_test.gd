extends SceneTree
const Validator=preload("res://Scripts/data_validator.gd")
var failures:=0
func _initialize() -> void:
	call_deferred("run_checks")
func check(value: bool, message: String) -> void:
	if value:
		print("PASS: "+message)
	else:
		failures+=1
		push_error(message)
func run_checks() -> void:
	var game=load("res://Scenes/main.tscn").instantiate()
	game.focus_pause_enabled=false
	root.add_child(game)
	await process_frame
	check(game.data_errors.is_empty(),"Shipped JSON passes validation")
	var bad:Dictionary=game.roster.duplicate(true)
	bad.pikachu.hp="wrong"
	check(not Validator.validate(bad,game.moves,game.types,game.CREATURES).is_empty(),"Invalid numeric creature value rejected")
	bad=game.roster.duplicate(true)
	bad.lapras.moves=["missing"]
	check(not Validator.validate(bad,game.moves,game.types,game.CREATURES).is_empty(),"Missing move references rejected")
	var bad_moves:Dictionary=game.moves.duplicate(true)
	bad_moves.thunder.cooldown=0
	check(not Validator.validate(game.roster,bad_moves,game.types,game.CREATURES).is_empty(),"Zero cooldown rejected")
	var config:=ConfigFile.new()
	config.set_value("game","difficulty",{"broken":true})
	check(game.setting_number(config,"game","difficulty",1)==1,"Broken numeric settings fall back safely")
	config.set_value("audio","volume",NAN)
	check(game.setting_number(config,"audio","volume",0.35)==0.35,"Nonfinite volume rejected")
	game.start_fight(false)
	for i in range(30):
		await physics_frame
	game.focus_pause_enabled=true
	game._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	check(game.screen=="pause" and paused,"Losing window focus pauses combat")
	var count: int=game.modal.get_child_count()
	game.pause_game()
	check(game.modal.get_child_count()==count,"Repeated pause does not stack menus")
	game.show_menu()
	check(not paused and game.screen=="menu","Returning to menu clears tree pause")
	game.data_errors=PackedStringArray(["Test: ungültiger Wert"])
	game.show_data_error()
	check(game.screen=="data_error" and game.ui.get_child_count()>0,"Invalid data produces readable error page")
	game.stop_audio()
	game.queue_free()
	await process_frame
	await process_frame
	print("DATA/LIFECYCLE FAILURES: ",failures)
	quit(0 if failures==0 else 1)
