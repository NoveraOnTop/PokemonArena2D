extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func capture() -> void:
	var game = load("res://Scenes/main.tscn").instantiate()
	game.focus_pause_enabled=false
	root.add_child(game)
	root.size=Vector2i(1280,720)
	for i in range(8):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../arena-menu.png"))
	game.show_team()
	for i in range(5):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../arena-team.png"))
	game.selected_team=["pikachu","glurak","turtok"]
	game.start_fight(false)
	game.get_active(0).position=Vector2(465,399)
	game.get_active(1).position=Vector2(830,345)
	game.get_active(0).aim=Vector2(1,-0.15).normalized()
	for i in range(65):
		await process_frame
	game.spawn_attack(game.get_active(0),game.moves.thunder)
	game.spawn_attack(game.get_active(0),game.moves.electroball)
	for i in range(20):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../arena-battle.png"))
	game.show_menu()
	game.selected_team=["pikachu","glurak","turtok"]
	game.show_menu()
	for i in range(3):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../arena-menu.png"))
	game.selected_slot=0
	game.show_team()
	for i in range(3):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../arena-team.png"))
	print("VISUAL CAPTURES SAVED")
	quit()

