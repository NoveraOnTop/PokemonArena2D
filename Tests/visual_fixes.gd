extends SceneTree
const Art=preload("res://Art/pixel_art.gd")
func _initialize() -> void:
	call_deferred("capture")
func shot(name: String) -> void:
	for i in range(5):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../"+name+".png")
func capture() -> void:
	var game=load("res://Scenes/main.tscn").instantiate()
	game.focus_pause_enabled=false
	root.add_child(game)
	root.size=Vector2i(1280,720)
	await process_frame
	game.clear(game.ui)
	game.screen="gallery"
	game.panel(Rect2(0,0,1280,720),Color("101e2d"))
	game.label_at("NEUE BLICKRICHTUNGEN",Vector2(37,22),29)
	game.label_at("Vorne, Profil und Rücken · je vier Schrittphasen pro Richtung",Vector2(39,65),16,Color("a6c7d1"))
	for col in range(6):
		var id: String=game.CREATURES[col]
		var x:=42+col*204
		game.label_at(game.roster[id].name,Vector2(x+35,110),22,Color(game.roster[id].color))
		for row in range(3):
			var direction: String=["front","side","back"][row]
			var y:=148+row*171
			game.panel(Rect2(x,y,178,153),Color("1d3043"))
			var image=game.portrait(id,Rect2(x+37,y+6,104,104))
			image.texture=Art.get_texture(id,1,direction)
			game.label_at(["VORNE","PROFIL","RÜCKEN"][row],Vector2(x+53,y+121),13,Color("93b9c5"),null,true)
	await shot("animation-directions")
	game.start_fight(false)
	game.get_active(0).position=Vector2(450,410)
	game.get_active(1).position=Vector2(825,360)
	game.get_active(0).cooldowns=[0.5,1.8,2.5,6.5]
	game.get_active(0).energy=12
	await shot("cooldown-fixed")
	game.get_active(0).velocity=Vector2.UP*100
	await shot("arena-battle")
	quit()

