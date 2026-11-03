extends StaticBody2D

var hp := 45.0
var game
var radius := 27.0

func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = radius
	col.shape = shape
	add_child(col)
	z_index = int(position.y)

func take_hit(damage: float) -> void:
	hp -= damage
	game.effect(position,Color("b0a6a3"),"hit",25)
	if hp<=0:
		game.rocks.erase(self)
		game.effect(position,Color("c6b7a6"),"hit",60)
		queue_free()
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2.ZERO,0,Vector2(1,0.45))
	draw_circle(Vector2(5,5),34,Color(0,0,0,0.3))
	draw_set_transform(Vector2.ZERO)
	draw_colored_polygon(PackedVector2Array([Vector2(-30,2),Vector2(-23,-28),Vector2(-7,-42),Vector2(19,-34),Vector2(30,-6),Vector2(21,10),Vector2(-15,12)]),Color("252b3a"))
	draw_colored_polygon(PackedVector2Array([Vector2(-26,0),Vector2(-20,-27),Vector2(-6,-37),Vector2(16,-30),Vector2(25,-5),Vector2(18,6),Vector2(-12,8)]),Color("696571"))
	draw_colored_polygon(PackedVector2Array([Vector2(-20,-25),Vector2(-5,-36),Vector2(16,-29),Vector2(3,-17)]),Color("929095"))
	draw_colored_polygon(PackedVector2Array([Vector2(3,-17),Vector2(16,-29),Vector2(25,-5),Vector2(18,6),Vector2(5,5)]),Color("514d5c"))
	if hp<30:
		draw_polyline(PackedVector2Array([Vector2(-5,-36),Vector2(2,-23),Vector2(-6,-12),Vector2(3,3)]),Color("272e3c"),3)
