extends SceneTree
var game
var failures := 0
func check(value: bool, text: String) -> void:
	if value: print("PASS: ",text)
	else: failures+=1; push_error("FAIL: "+text)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	game=load("res://Scenes/main.tscn").instantiate()
	game.focus_pause_enabled=false
	root.add_child(game)
	await process_frame
	game.selected_team=["bisaflor","relaxo","psiana"]
	game.start_mode("boss")
	await process_frame
	check(game.last_rival_team==["dragoran","knakrack","relaxo"],"Boss uses its champion team")
	check(game.teams[1][0].power_multiplier>1.2,"Boss receives combat power")
	game.show_menu()
	game.start_mode("tournament")
	check(game.tournament_round==1,"Tournament begins at round one")
	game.continue_tournament()
	check(game.tournament_round==2 and game.game_mode=="tournament","Tournament advances rounds")
	game.show_menu()
	game.start_mode("survival")
	var survivor=game.teams[0][0]
	survivor.hp=77
	for fighter in game.teams[0]: game.survival_hp[fighter.id]=fighter.hp
	game.continue_survival()
	check(game.survival_wave==2 and is_equal_approx(game.teams[0][0].hp,77),"Survival carries remaining HP")
	var bisaflor=game.teams[0][0]
	bisaflor.hp=float(bisaflor.data.hp)*0.3
	check(bisaflor.ability_attack_multiplier("grass")>1.2,"Overgrowth activates at low HP")
	var relaxo=game.teams[0][1]
	check(relaxo.ability_defense_multiplier("fire")<0.7,"Thick Fat resists fire")
	game.arena_id="meadow"
	bisaflor.hp=50
	game.trigger_arena_event()
	check(bisaflor.hp>50,"Meadow event heals matching types")
	var old_level: int=game.trainer_level
	game.trainer_xp=game.trainer_level*150-1
	game.award_progress()
	check(game.trainer_level>old_level,"Victories advance trainer level")
	check(game.music_streams.size()==game.ARENAS.size(),"Every arena has a music loop")
	game.story_chapter=0
	game.start_story_battle()
	check(game.game_mode=="story" and game.arena_id=="meadow","Story chapter selects its authored arena")
	check(game.last_rival_team==["bisaflor","sichlor","arkani"],"Story chapter selects its authored rival team")
	var active=game.get_active(0)
	check(active.eight_direction(Vector2(1,1))=="front_right" and active.eight_direction(Vector2(-1,-1))=="back_left","Fighters expose eight directional states")
	game.arena_id="coast"
	active.position.y=500
	check(game.arena_modifier(active,"speed")<1.0,"Deep coast water slows non-water fighters")
	var water_fighter=game.teams[1][0]
	water_fighter.data=game.roster["turtok"]
	water_fighter.position.y=500
	check(game.arena_modifier(water_fighter,"speed")>1.0,"Water fighters swim faster in coast water")
	game.stop_audio()
	game.queue_free()
	await process_frame
	print("MODES/ABILITIES FINISHED. FAILURES: ",failures)
	quit(0 if failures==0 else 1)
