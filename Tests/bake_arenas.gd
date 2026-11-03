extends SceneTree
func _initialize() -> void:
	call_deferred("bake")
func bake() -> void:
	for variant in ["volcano","meadow","coast","crystal","ruins","storm","haunted","jungle","factory"]:
		var viewport:=SubViewport.new()
		viewport.size=Vector2i(1280,720)
		viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
		var source=load("res://Art/arena_source.gd").new()
		source.variant=variant
		viewport.add_child(source)
		source.set_process(false)
		for frame in range(3):
			await process_frame
		await RenderingServer.frame_post_draw
		viewport.get_texture().get_image().save_png("res://Art/Arenas/"+variant+".png")
		viewport.queue_free()
		await process_frame
		print("BAKED: ",variant)
	quit()

