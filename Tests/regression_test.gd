extends SceneTree
const Art=preload("res://Art/pixel_art.gd")
var failures:=0
func _initialize() -> void:
	call_deferred("run_checks")
func check(value: bool, label: String) -> void:
	if not value:
		failures+=1
		push_error("FAIL: "+label)
	else:
		print("PASS: "+label)
func frames(count: int) -> void:
	for i in range(count):
		await physics_frame
func run_checks() -> void:
	var game=load("res://Scenes/main.tscn").instantiate()
	game.focus_pause_enabled=false
	root.add_child(game)
	await process_frame
	game.selected_team=["pikachu","glurak","turtok"]
	game.start_fight(false)
	await frames(30)
	var source=game.get_active(0)
	var victim=game.get_active(1)
	victim.shield=2
	victim.hp=100
	source.damage_done=0
	victim.take_hit(40,Vector2.RIGHT,"",source)
	check(is_equal_approx(source.damage_done,10),"Damage counter uses HP lost after shield")
	victim.shield=0
	victim.hp=3
	victim.take_hit(99,Vector2.RIGHT,"",source)
	check(is_equal_approx(source.damage_done,13),"Overkill capped at remaining HP")
	victim.hp=100
	source.damage_done=0
	victim.dodge=1
	check(not victim.take_hit(25,Vector2.RIGHT,"",source) and source.damage_done==0,"Dodged damage never counted")
	victim.dodge=0
	victim.take_hit(1,Vector2.RIGHT,"burn",source)
	await frames(30)
	check(is_equal_approx(source.damage_done,100-victim.hp),"Burn damage attributed and matches HP loss exactly")
	victim.statuses.clear()
	victim.hp=100
	victim.position=Vector2(600,400)
	source.position=Vector2(250,400)
	source.stun=0
	Input.action_press("up")
	await frames(10)
	Input.action_release("up")
	check(source.visual_direction=="back","Walking north uses back sprite")
	Input.action_press("down")
	await frames(10)
	Input.action_release("down")
	check(source.visual_direction=="front","Walking south uses front sprite")
	Input.action_press("left")
	await frames(10)
	Input.action_release("left")
	check(source.visual_direction=="left" and source.sprite.flip_h,"Walking west uses mirrored left sprite")
	for id in game.CREATURES:
		var front=Art.get_texture(id,0,"front").get_image().get_data()
		var back=Art.get_texture(id,0,"back").get_image().get_data()
		var side=Art.get_texture(id,0,"side").get_image().get_data()
		check(front!=back and front!=side and back!=side,id+" has distinct front, back and profile artwork")
		check(Art.get_texture(id,1,"back").get_image().get_data()!=back,id+" has animated back-view steps")
	game.get_active(0).hp=0
	await frames(2)
	var fire=game.get_active(0)
	fire.position=Vector2(300,400)
	var lapras=game.teams[1][2]
	victim.set_active(false)
	game.active_indices[1]=2
	lapras.set_active(true)
	lapras.position=Vector2(500,400)
	lapras.hp=240
	fire.aim=Vector2.RIGHT
	fire.target=lapras
	var shot=game.Attack.new()
	shot.configure(fire,game.moves.fire_blast,lapras.position)
	game.world.add_child(shot)
	shot.hit_fighter(lapras)
	var expected:float=38*game.arena_move_modifier("fire","power")*(0.65+float(fire.data.special_attack)/(float(lapras.data.special_defense)+70))*fire.ability_attack_multiplier("fire")*fire.power_multiplier
	check(is_equal_approx(240-lapras.hp,expected),"Fire is neutral against Water/Ice Lapras")
	check(game.moves.fire_spin.damage==7 and game.moves.fire_spin.tick_interval==0.8,"Fire zone damage and pulse interval rebalanced")
	check(game.style_cache.size()<100,"HUD uses a bounded reusable style cache")
	print("REGRESSION FAILURES: ",failures)
	quit(0 if failures==0 else 1)

