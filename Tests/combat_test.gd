extends SceneTree
var failures := 0
func _initialize() -> void:
	call_deferred("run_checks")
func check(value: bool, message: String) -> void:
	if not value:
		failures+=1
		push_error(message)
	else:
		print("PASS: ",message)
func frames(count: int) -> void:
	for i in range(count):
		await physics_frame
func run_checks() -> void:
	var game = load("res://Scenes/main.tscn").instantiate()
	game.focus_pause_enabled=false
	root.add_child(game)
	await process_frame
	game.selected_team=["pikachu","glurak","turtok"]
	game.start_fight(false)
	await frames(30)
	for rock in game.rocks.duplicate():
		rock.take_hit(1000)
	await frames(2)
	var player = game.get_active(0)
	var enemy = game.get_active(1)
	player.position=Vector2(250,380)
	enemy.position=Vector2(500,380)
	player.aim=Vector2.RIGHT
	player.target=enemy
	var before: float = enemy.hp
	game.spawn_attack(player,game.moves.thunder)
	await frames(30)
	check(enemy.hp==before,"Thunder warning deals no early damage")
	await frames(30)
	check(enemy.hp<before,"Thunder strikes after warning")
	enemy.hp=1000
	enemy.stun=0
	enemy.position=Vector2(500,380)
	before=enemy.hp
	game.spawn_attack(player,game.moves.thunder)
	await frames(20)
	enemy.position=Vector2(800,540)
	await frames(45)
	check(enemy.hp==before,"Leaving thunder target avoids damage")
	enemy.position=Vector2(500,380)
	enemy.statuses.clear()
	enemy.stun=0
	player.aim=Vector2.RIGHT
	game.spawn_attack(player,game.moves.water)
	await frames(35)
	check(enemy.statuses.has("wet"),"Water projectile applies wet")
	enemy.position=Vector2(500,380)
	enemy.stun=0
	enemy.hp=1000
	before=enemy.hp
	player.aim=Vector2.RIGHT
	game.spawn_attack(player,game.moves.thunderbolt)
	await frames(30)
	var wet_damage: float = before-enemy.hp
	enemy.statuses.clear()
	enemy.position=Vector2(500,380)
	enemy.stun=0
	enemy.hp=1000
	before=enemy.hp
	player.aim=Vector2.RIGHT
	game.spawn_attack(player,game.moves.thunderbolt)
	await frames(30)
	var dry_damage: float = before-enemy.hp
	check(is_equal_approx(wet_damage,dry_damage*1.25),"Wet increases electric damage by exactly 25 percent")
	game.switch_cooldown=0
	game.switch_team(0,1)
	var fire = game.get_active(0)
	fire.take_hit(1,Vector2.LEFT,"burn")
	check(not fire.statuses.has("burn"),"Glutkern prevents burn")
	game.switch_cooldown=0
	fire.stun=0
	game.switch_team(0,2)
	var turtle = game.get_active(0)
	before=turtle.hp
	turtle.take_hit(40,Vector2.LEFT)
	check(is_equal_approx(before-turtle.hp,36),"Panzer reduces incoming damage")
	# UI clicks must not accidentally fire the primary move.
	turtle.stun=0
	game.switch_cooldown=0
	game.switch_team(0,0)
	player.cooldowns=[0.0,0.0,0.0,0.0]
	var click := InputEventMouseButton.new()
	click.position=Vector2(100,150)
	click.button_index=MOUSE_BUTTON_LEFT
	click.pressed=true
	Input.parse_input_event(click)
	await frames(2)
	check(player.cooldowns[0]==0,"Clicking team rail does not fire attack")
	click.pressed=false
	Input.parse_input_event(click)
	game.selected_team=["pikachu","glurak","turtok"]
	game.save_settings()
	print("ATTACK TEST FAILURES: ",failures)
	quit(0 if failures==0 else 1)


