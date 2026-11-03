extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func save(name: String) -> void:
	for i in range(5):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../review-"+name+".png")
func capture() -> void:
	var game=load("res://Scenes/main.tscn").instantiate()
	game.focus_pause_enabled=false
	root.add_child(game)
	await process_frame
	game.show_settings()
	await save("settings")
	game.pending_rebind="attack0"
	game.binding_message="Jetzt neue Taste drücken. Esc bricht ab."
	game.show_settings()
	await save("rebind")
	game.pending_rebind=""
	game.show_help()
	await save("help")
	for arena in game.ARENAS:
		game.arena_id=arena
		game.start_fight(false)
		await save(arena)
	game.pause_game()
	await save("pause")
	game.resume()
	for fighter in game.teams[0]:
		fighter.hp=0
	game.finish(false)
	await save("defeat")
	game.stop_audio()
	game.queue_free()
	await process_frame
	await process_frame
	quit()
