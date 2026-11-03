extends SceneTree
var failures:=0
func _initialize() -> void:
	call_deferred("test")
func check(value: bool, message: String) -> void:
	if value:
		print("PASS: "+message)
	else:
		failures+=1
		push_error(message)
func test() -> void:
	var game=load("res://Scenes/main.tscn").instantiate()
	game.focus_pause_enabled=false
	root.add_child(game)
	await process_frame
	game.start_fight(false)
	for i in range(30):
		await physics_frame
	var p=game.get_active(0)
	var e=game.get_active(1)
	for rock in game.rocks.duplicate():
		rock.queue_free()
	game.rocks.clear()
	await process_frame
	var rock=game.Rock.new()
	rock.game=game
	rock.position=Vector2(500,400)
	game.world.add_child(rock)
	game.rocks.append(rock)
	p.position=Vector2(200,400)
	p.aim=Vector2.RIGHT
	e.position=Vector2(550,400)
	var hp:float=e.hp
	var beam=game.Attack.new()
	beam.configure(p,game.moves.hydro,e.position)
	game.world.add_child(beam)
	beam._physics_process(0.016)
	check(e.hp==hp,"Beam cannot hit fighter immediately behind a solid rock")
	check(beam.target_position.x<450,"Beam ends at front surface of expanded rock collision")
	beam.queue_free()
	rock.hp=100
	e.position=Vector2(450,400)
	var bolt=game.Attack.new()
	bolt.configure(p,game.moves.thunderbolt,e.position)
	bolt.position=Vector2(400,400)
	game.world.add_child(bolt)
	bolt._physics_process(0.1)
	check(e.hp<hp,"Fast projectile hits nearer fighter before farther rock")
	check(rock.hp==100,"Farther rock does not absorb nearer fighter's hit")
	check(is_equal_approx(game.Attack.swept_circle_fraction(Vector2.ZERO,Vector2(10,0),Vector2(5,0),1),0.4),"Swept circle computes first contact")
	check(is_inf(game.Attack.swept_circle_fraction(Vector2.ZERO,Vector2(10,0),Vector2(5,5),1)),"Swept circle rejects clear miss")
	game.queue_free()
	await process_frame
	await process_frame
	print("OCCLUSION FAILURES: ",failures)
	quit(0 if failures==0 else 1)

