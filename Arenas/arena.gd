extends Node2D
## The detailed static floor is rendered once offline; only embers redraw at runtime.
var variant := "volcano"
var time := 0.0
var update_timer := 0.0
func _ready() -> void:
	var background:=Sprite2D.new()
	background.texture=load("res://Art/Arenas/"+variant+".png")
	background.centered=false
	background.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(background)
	var ambient:=Node2D.new()
	ambient.set_script(load("res://Effects/arena_ambient.gd"))
	ambient.variant=variant
	add_child(ambient)
