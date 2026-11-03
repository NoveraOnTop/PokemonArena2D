extends Node2D
var tint:=Color("342b38")
var size:=28.0
var life:=18.0
func _ready() -> void:
	z_index=-20
	queue_redraw()
func _process(dt: float) -> void:
	life-=dt
	if life<3.0: modulate.a=maxf(0,life/3.0)
	if life<=0: queue_free()
func _draw() -> void:
	draw_set_transform(Vector2.ZERO,0,Vector2(1.0,0.45))
	draw_circle(Vector2.ZERO,size,Color(tint,0.28))
	draw_arc(Vector2.ZERO,size*0.72,0,TAU,18,Color(tint.lightened(0.22),0.38),2)
	for i in range(7):
		var angle:=float(i)*TAU/7.0
		draw_line(Vector2.from_angle(angle)*size*0.55,Vector2.from_angle(angle)*size,Color(tint,0.3),2)
