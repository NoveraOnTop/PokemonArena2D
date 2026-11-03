extends SceneTree
var game
var failures := 0

func _initialize() -> void:
	call_deferred("run_checks")

func check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error("FAIL: "+message)
	else:
		print("PASS: "+message)

func frames(count: int) -> void:
	for i in range(count):
		await physics_frame

func reset_positions() -> void:
	game.get_active(0).position = Vector2(200,380)
	game.get_active(1).position = Vector2(470,380)

func run_checks() -> void:
	game = load("res://Scenes/main.tscn").instantiate()
	game.focus_pause_enabled=false
	root.add_child(game)
	await process_frame
	check(game.screen=="menu","Menu loads")
	check(game.roster.size()==24,"Twenty-four selectable fighters")
	check(game.roster.has("katapuldra") and game.roster.has("despotar") and game.roster.has("ditto"),"Katapuldra, Despotar and Ditto are selectable")
	check(game.moves.size()>=46,"Expanded move set loaded")
	var rival_sample: Array = game.random_rival_team()
	var unique_rivals := {}
	for id in rival_sample:
		unique_rivals[id]=true
	check(rival_sample.size()==3 and unique_rivals.size()==3,"Random rival team has three unique fighters")
	for action in ["left","right","up","down"]:
		var key := InputEventKey.new()
		key.physical_keycode = {"left":KEY_LEFT,"right":KEY_RIGHT,"up":KEY_UP,"down":KEY_DOWN}[action]
		check(InputMap.event_is_action(key,action),"Arrow key bound: "+action)
	game.show_team()
	game.selected_team = ["pikachu","glurak","turtok"]
	game.selected_slot = 1
	game.choose_creature("pikachu")
	check(game.selected_team==["glurak","pikachu","turtok"],"Selection swaps occupied slots without duplicate")
	game.selected_team = ["pikachu","glurak","turtok"]
	game.start_fight(false)
	await frames(30)
	var player = game.get_active(0)
	var enemy = game.get_active(1)
	check(game.fighters.size()==6,"Three fighters per team")
	check(game.rocks.size()==game.arena_rock_positions().size(),"Random arena uses its own obstacle layout")
	check(game.arena_id in game.ARENAS,"Fight selects a valid random arena")
	var fight_arena: String = game.arena_id
	var seen_arenas := {}
	for i in range(12):
		seen_arenas[game.roll_random_arena()] = true
	check(seen_arenas.size()>1,"Arena draw changes across repeated fights")
	game.arena_id=fight_arena
	var affinity_fighter = game.fighters.filter(func(f): return game.has_arena_affinity(f)).front()
	check(game.arena_modifier(affinity_fighter,"energy")>1.0,"Matching Pokémon type receives arena advantage")
	var arena_type: String = game.ARENA_TYPES[game.arena_id][0]
	check(game.arena_move_modifier(arena_type,"power")>1.0,"Matching move type receives arena power advantage")
	check(game.arena_move_modifier("unknown","power")==1.0,"Unmatched move type stays neutral")
	var start: Vector2 = player.position
	Input.action_press("up")
	await frames(20)
	Input.action_release("up")
	check(player.position.y<start.y-35,"Vertical movement on arena floor")
	player.position = Vector2(200,400)
	Input.action_press("right")
	await frames(15)
	Input.action_release("right")
	var straight: float = player.position.distance_to(Vector2(200,400))
	player.position = Vector2(200,400)
	Input.action_press("right")
	Input.action_press("up")
	await frames(15)
	Input.action_release("right")
	Input.action_release("up")
	var diagonal: float = player.position.distance_to(Vector2(200,400))
	check(absf(straight-diagonal)<8,"Diagonal speed normalized")
	var test_rock = game.rocks[0]
	player.position = test_rock.position-Vector2(player.radius+test_rock.radius+5,0)
	Input.action_press("right")
	await frames(20)
	Input.action_release("right")
	check(player.position.x<test_rock.position.x,"Rocks block movement")
	# Select a clear horizontal lane for whichever random arena was drawn.
	var shot_y := 220.0
	for candidate in [220.0,330.0,430.0,550.0]:
		var blocked := false
		for rock in game.rocks:
			if rock.position.x>190.0 and rock.position.x<480.0 and absf(rock.position.y-candidate)<70.0:
				blocked=true
				break
		if not blocked:
			shot_y=candidate
			break
	player.position=Vector2(200,shot_y)
	enemy.position=Vector2(470,shot_y)
	player.aim = Vector2.RIGHT
	game.mouse_aim = false
	player.attack(0)
	check(player.energy<100,"Move consumes energy")
	check(player.cooldowns[0]>0,"Move sets cooldown")
	var enemy_hp: float = enemy.hp
	await frames(45)
	check(enemy.hp<enemy_hp,"Aimed projectile deals damage")
	check(player.try_dodge(Vector2.UP),"Directional dodge starts")
	check(not player.take_hit(20,Vector2.LEFT),"Dodge grants invulnerability")
	await frames(25)
	player.shield = 2
	player.hp = 150
	player.take_hit(40,Vector2.LEFT)
	check(is_equal_approx(player.hp,140),"Shield reduces damage by 75 percent")
	player.shield = 0
	player.stun = 0
	player.dodge = 0
	player.take_hit(1,Vector2.LEFT,"wet")
	check(player.statuses.has("wet"),"Water applies wet status")
	player.stun = 0
	player.statuses.clear()
	player.take_hit(1,Vector2.LEFT,"sleep")
	check(not player.attack(0),"Sleep blocks attacks")
	player.statuses.clear()
	player.stun = 0
	game.pause_game()
	var pause_position: Vector2 = player.position
	var pause_time: float = game.elapsed
	await frames(12)
	check(player.position==pause_position and game.elapsed==pause_time,"Pause freezes combat and timer")
	game.resume()
	var retained_hp: float = player.hp
	check(game.switch_team(0,1),"Switch active team member")
	check(game.get_active(0).id=="glurak" and not player.active,"Only selected creature active")
	check(player.hp==retained_hp,"Switch preserves HP")
	check(not game.switch_team(0,2),"Team switch cooldown enforced")
	game.get_active(0).hp = 0
	await process_frame
	await process_frame
	check(game.get_active(0).hp>0,"KO automatically sends next living teammate")
	for fighter in game.teams[1]:
		fighter.hp=0
	await process_frame
	await process_frame
	check(game.screen=="result","Entire opposing team KO ends match")
	game.start_fight(true)
	await frames(90)
	check(game.get_active(1).ai,"Rematch enables AI")
	var first_rival: Array=game.last_rival_team.duplicate()
	game.start_fight(true)
	await frames(2)
	var second_rival: Array=game.last_rival_team.duplicate()
	first_rival.sort()
	second_rival.sort()
	check(first_rival!=second_rival,"Normal rematch draws a different rival team")
	# Exercise every move lifecycle and draw-independent collision logic.
	game.ai_enabled = false
	for fighter in game.teams[1]:
		fighter.ai=false
	for side in game.teams:
		for fighter in side:
			fighter.hp=100000
	for id in game.moves:
		var source = game.get_active(0)
		source.position = Vector2(200,380)
		source.aim = Vector2.RIGHT
		source.target = game.get_active(1)
		game.get_active(1).position = Vector2(400,380)
		game.spawn_attack(source,game.moves[id])
		await frames(80)
	check(game.screen=="fight","Every move lifecycle executes without stopping match")
	var rock_count: int = game.rocks.size()
	if rock_count>0:
		game.rocks[0].take_hit(100)
		await frames(2)
		check(game.rocks.size()==rock_count-1,"Rock destruction removes obstacle")
	game.show_help()
	game.show_settings()
	game.show_menu()
	game.save_settings()
	check(game.screen=="menu","Help, settings, menu and saving execute")
	print("ARENA TESTS FINISHED. FAILURES: ",failures)
	game.stop_audio()
	await create_timer(0.12).timeout
	quit(0 if failures==0 else 1)

