extends SceneTree
var game
var failure_messages: Array = []
var rounds:=0
var frames:=0
var pauses:=0
var switches:=0
var timeouts:=0
var samples: Array = []
var duration_seconds:=600
func _initialize() -> void:
	call_deferred("soak")
func flag(text: String) -> void:
	if not failure_messages.has(text):
		failure_messages.append(text)
		push_error(text)
func start_round() -> void:
	game.selected_team=[]
	for i in range(3):
		game.selected_team.append(game.CREATURES[(rounds+i)%game.CREATURES.size()])
	game.arena_id=game.ARENAS[rounds%3]
	game.difficulty=rounds%3
	game.start_fight(true)
	for f in game.teams[0]:
		f.player=false
		f.ai=true
func soak() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("duration="):
			duration_seconds=int(arg.trim_prefix("duration="))
	seed(20261027)
	game=load("res://Scenes/main.tscn").instantiate()
	game.focus_pause_enabled=false
	root.add_child(game)
	await process_frame
	start_round()
	var started:=Time.get_ticks_usec()
	var next_sample:=started+60000000
	var paused_in_round:=false
	while Time.get_ticks_usec()-started<duration_seconds*1000000:
		await physics_frame
		frames+=1
		if game.screen=="result":
			rounds+=1
			game.show_menu()
			for i in range(3):
				await process_frame
			if Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)>0:
				flag("Orphan nodes remain after returning to menu")
			start_round()
			paused_in_round=false
		if game.screen!="fight":
			continue
		for side in range(2):
			var active_count:=0
			for f in game.teams[side]:
				if not is_finite(f.hp) or not is_finite(f.energy) or f.hp<0 or f.energy<0 or f.energy>100.1:
					flag("Invalid HP or energy during soak")
				if f.active:
					active_count+=1
				if not game.bounds.grow(1).has_point(f.position) and f.active:
					flag("Active fighter escaped arena")
			if active_count!=1:
				flag("Team has wrong active fighter count")
		if game.elapsed>4 and not paused_in_round:
			var p=game.get_active(0)
			var before:Vector2=p.position
			var clock_before:float=game.elapsed
			game.pause_game()
			for i in range(5):
				await physics_frame
			if p.position!=before or game.elapsed!=clock_before:
				flag("Pause changed position or combat timer")
			game.resume()
			pauses+=1
			paused_in_round=true
		if frames%300==0 and game.switch_team(0):
			switches+=1
		if game.elapsed>100:
			timeouts+=1
			rounds+=1
			start_round()
			paused_in_round=false
		if Time.get_ticks_usec()>=next_sample:
			var sample={"wall_seconds":(Time.get_ticks_usec()-started)/1000000.0,"rounds":rounds,"nodes":Performance.get_monitor(Performance.OBJECT_NODE_COUNT),"orphans":Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT),"static_memory_mb":Performance.get_monitor(Performance.MEMORY_STATIC)/1048576.0}
			samples.append(sample)
			print("SOAK ",JSON.stringify(sample))
			next_sample+=60000000
	var result={"duration_seconds":(Time.get_ticks_usec()-started)/1000000.0,"rounds":rounds,"physics_frames":frames,"pauses":pauses,"switches":switches,"timeouts":timeouts,"failures":failure_messages,"samples":samples}
	var file:=FileAccess.open("res://../review-soak.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(result,"  "))
	print("SOAK FINISHED ",JSON.stringify(result))
	game.stop_audio()
	game.queue_free()
	await process_frame
	await process_frame
	quit(0 if failure_messages.is_empty() else 1)
