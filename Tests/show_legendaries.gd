extends SceneTree
const Art=preload("res://Art/pixel_art.gd")
func _initialize() -> void:
	call_deferred("capture")
func capture() -> void:
	var game=load("res://Scenes/main.tscn").instantiate()
	game.focus_pause_enabled=false
	root.add_child(game)
	root.size=Vector2i(900,260)
	await process_frame
	game.clear(game.ui)
	game.panel(Rect2(0,0,900,260),Color("101e2d"))
	var ids=["kyogre","kyurem","zekrom","reshiram","rayquaza"]
	for i in range(ids.size()):
		var id=ids[i]
		var x=20+i*176
		game.label_at(str(game.roster[id].name),Vector2(x+18,22),17,Color(game.roster[id].color))
		var image=game.portrait(id,Rect2(x+16,55,144,144))
		image.texture=Art.get_texture(id,0,"front")
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../legendary-preview.png"))
	quit()
