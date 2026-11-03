extends SceneTree
var game
var failures:=0
func _initialize() -> void:
	call_deferred("run_checks")
func check(value: bool, text: String) -> void:
	if not value:
		failures+=1
		push_error(text)
	else:
		print("PASS: "+text)
func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
func run_checks() -> void:
	game=load("res://Scenes/main.tscn").instantiate()
	game.focus_pause_enabled=false
	root.add_child(game)
	await process_frame
	game.selected_team=["pikachu","glurak","turtok"]
	game.start_fight(false)
	await frames(30)
	var p=game.get_active(0)
	var enemy=game.get_active(1)
	p.position=Vector2(300,450)
	enemy.position=Vector2(950,400)
	p.aim=Vector2.UP
	p.aim_mode="stick"
	game.mouse_aim=false
	game.spawn_attack(p,game.moves.thunder)
	var shot=game.world.get_child(game.world.get_child_count()-1)
	check(is_equal_approx(shot.position.x,p.position.x) and shot.position.y<p.position.y,"Manual stick area aim respected")
	p.attack(1)
	check(not game.switch_team(0,1),"Switch blocked during attack dash")
	p.hp=0
	check(not p.try_dodge(),"KO fighter cannot dodge")
	check(not p.attack(0),"KO fighter cannot attack")
	game.start_fight(false)
	await frames(30)
	p=game.get_active(0)
	enemy=game.get_active(1)
	p.position=Vector2(300,400)
	p.aim=Vector2.RIGHT
	game.mouse_aim=true
	game.aim_point=Vector2(800,400)
	game.spawn_attack(p,game.moves.thunder)
	shot=game.world.get_child(game.world.get_child_count()-1)
	enemy.position=shot.position+Vector2(-20,0)
	shot.area_hit()
	check(enemy.velocity.x<0,"Explosion pushes away from its center")
	game.pause_game()
	check(not p.try_dodge() and not p.attack(0),"Public actions respect pause")
	game.resume()
	p.set_active(false)
	check(not p.attack(0) and not p.try_dodge(),"Benched fighter cannot perform actions")
	game.queue_free()
	await process_frame
	await process_frame
	print("AUDIT REGRESSION FAILURES: ",failures)
	quit(0 if failures==0 else 1)

