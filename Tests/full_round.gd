extends SceneTree
## A complete automated playtest: sends normal actions, never changes HP, damage or AI stats.
var game
var frame := 0
var report: Array = []
var attempts := [0,0,0,0]
var dodges := 0
var switch_attempts := 0
var collided_frames := 0
var low_energy_frames := 0
var previous_ids := ["",""]
var previous_position := Vector2.ZERO
var minimum_fps := 1000.0
var fps_samples: Array = []
var capture_done := {}
var run_label := "playtest"
var run_seed := 27102026

func _initialize() -> void:
	call_deferred("play_round")

func log_line(line: String) -> void:
	report.append(line)
	print(line)

func release_inputs() -> void:
	for action in ["left","right","up","down","attack0","attack1","attack2","attack3","dodge","switch"]:
		Input.action_release(action)

func capture_image(name: String) -> void:
	if DisplayServer.get_name()=="headless":
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../"+run_label+"-"+name+".png"))

func snapshot() -> void:
	var line := "%.1fs" % game.elapsed
	for side in range(2):
		var active = game.get_active(side)
		line += " | %s HP=%.1f EN=%.1f pos=(%.0f,%.0f) hits=%d statuses=%s" % [active.id,active.hp,active.energy,active.position.x,active.position.y,active.hits,str(active.statuses.keys())]
	log_line(line)

func play_round() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("seed="):
			run_seed=int(arg.trim_prefix("seed="))
		elif arg.begins_with("label="):
			run_label=arg.trim_prefix("label=")
	seed(run_seed)
	game=load("res://Scenes/main.tscn").instantiate()
	game.focus_pause_enabled=false
	root.add_child(game)
	root.size=Vector2i(1280,720)
	await process_frame
	game.selected_team=["pikachu","glurak","turtok"]
	game.difficulty=1
	game.arena_id="volcano"
	game.start_fight(true)
	log_line("FULL ROUND: normal AI, unmodified combat stats, simulated keyboard actions with built-in automatic aim.")
	while game.screen=="fight" and game.elapsed<180:
		await physics_frame
		frame+=1
		if game.screen!="fight":
			break
		var player=game.get_active(0)
		var enemy=game.get_active(1)
		for side in range(2):
			var active=game.get_active(side)
			if active.id!=previous_ids[side]:
				log_line("%.1fs SIDE %d ACTIVE: %s" % [game.elapsed,side,active.id])
				previous_ids[side]=active.id
		if player.get_slide_collision_count()>0:
			collided_frames+=1
		if player.energy<10:
			low_energy_frames+=1
		if frame%60==0:
			var fps:=Performance.get_monitor(Performance.TIME_FPS)
			fps_samples.append(fps)
			if game.elapsed>3:
				minimum_fps=minf(minimum_fps,fps)
		if frame%300==0:
			snapshot()
		for second in [5,20,45]:
			if game.elapsed>=second and not capture_done.has(second):
				capture_done[second]=true
				await capture_image(str(second)+"s")
		if frame%10!=0:
			continue
		release_inputs()
		# Approach ranged distance, strafe, and turn away from the boundary.
		var delta: Vector2=enemy.position-player.position
		var aim:=delta.normalized()
		var distance:=delta.length()
		var desired:=Vector2.ZERO
		if distance>320:
			desired=aim
		elif distance<190:
			desired=-aim
		else:
			desired=aim.orthogonal()*(1 if int(game.elapsed/4)%2==0 else -1)
		if player.position.y<235:
			desired.y=1
		if player.position.y>530:
			desired.y=-1
		if player.position.x<120:
			desired.x=1
		if player.position.x>1150:
			desired.x=-1
		# Obvious obstacle avoidance, no knowledge of hidden cooldowns or projectiles.
		for rock in game.rocks:
			if is_instance_valid(rock) and player.position.distance_to(rock.position)<80:
				desired+=(player.position-rock.position).normalized()
		if desired.x>0.2:
			Input.action_press("right")
		elif desired.x< -0.2:
			Input.action_press("left")
		if desired.y>0.2:
			Input.action_press("down")
		elif desired.y< -0.2:
			Input.action_press("up")
		# Use all four moves when useful, while retaining some energy for a dodge.
		var preferred:=3
		if player.id=="turtok" and player.hp/float(player.data.hp)<0.4 and player.cooldowns[2]<=0:
			preferred=2
		elif player.cooldowns[3]<=0 and player.energy>=60:
			preferred=3
		elif player.cooldowns[2]<=0 and player.energy>=32 and player.id!="turtok":
			preferred=2
		elif distance<170 and player.id!="pikachu" and player.cooldowns[1]<=0 and player.energy>=30:
			preferred=1
		else:
			preferred=0
		Input.action_press("attack"+str(preferred))
		attempts[preferred]+=1
		if frame%180==0 and player.energy>=25:
			Input.action_press("dodge")
			dodges+=1
		# Exercise team changes at natural breaks without resetting any resources.
		if (frame==720 or frame==1440) or (player.hp<float(player.data.hp)*0.25 and game.switch_cooldown<=0):
			Input.action_press("switch")
			switch_attempts+=1
	release_inputs()
	await process_frame
	await capture_image("result")
	var hits:=0
	var damage:=0.0
	var remaining:=0
	for fighter in game.teams[0]:
		hits+=fighter.hits
		damage+=fighter.damage_done
		remaining+=ceili(fighter.hp)
	log_line("RESULT screen=%s duration=%.2fs player_hits=%d player_damage=%.1f player_total_remaining_hp=%d" % [game.screen,game.elapsed,hits,damage,remaining])
	log_line("attack_key_attempts=%s dodge_attempts=%d switch_attempts=%d slide_collision_frames=%d low_energy_frames=%d minimum_sampled_fps=%.0f" % [str(attempts),dodges,switch_attempts,collided_frames,low_energy_frames,minimum_fps])
	for side in range(2):
		for fighter in game.teams[side]:
			log_line("SIDE %d %s HP=%.1f hits=%d damage=%.1f" % [side,fighter.id,fighter.hp,fighter.hits,fighter.damage_done])
	var initial_hp:=0.0
	var final_hp:=0.0
	for fighter in game.teams[1]:
		initial_hp+=float(fighter.data.hp)
		final_hp+=fighter.hp
	var accurate:=is_equal_approx(damage,initial_hp-final_hp)
	log_line("DAMAGE_ACCOUNTING_EXACT="+str(accurate))
	var file:=FileAccess.open(ProjectSettings.globalize_path("res://../"+run_label+"-report.txt"),FileAccess.WRITE)
	file.store_string("\n".join(report))
	var exit_code := 0 if game.screen=="result" and accurate else 2
	game.stop_audio()
	game.queue_free()
	await create_timer(0.12).timeout
	quit(exit_code)

