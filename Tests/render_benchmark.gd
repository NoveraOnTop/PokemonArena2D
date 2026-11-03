extends SceneTree
var samples: Array = []
func _initialize() -> void:
	call_deferred("run_benchmark")
func run_benchmark() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps=0
	var game=load("res://Scenes/main.tscn").instantiate()
	game.focus_pause_enabled=false
	root.add_child(game)
	Engine.max_fps=0
	await process_frame
	game.selected_team=["pikachu","glurak","turtok"]
	game.start_fight(false)
	var start:=Time.get_ticks_usec()
	var previous:=start
	var draws:=0.0
	while Time.get_ticks_usec()-start<8000000:
		await process_frame
		var now:=Time.get_ticks_usec()
		if now-start>2000000:
			samples.append((now-previous)/1000.0)
			draws+=Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		previous=now
	samples.sort()
	var sum:=0.0
	for value in samples:
		sum+=value
	var result="RENDER BENCHMARK samples=%d average_ms=%.2f median_ms=%.2f p95_ms=%.2f estimated_fps=%.1f draw_calls=%.0f" % [samples.size(),sum/samples.size(),samples[samples.size()/2],samples[int(samples.size()*0.95)],1000/(sum/samples.size()),draws/samples.size()]
	print(result)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("report="):
			var file=FileAccess.open(arg.trim_prefix("report="),FileAccess.WRITE)
			file.store_string(result)
	quit()

