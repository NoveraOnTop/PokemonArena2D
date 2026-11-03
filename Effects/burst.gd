extends Node2D

var tint := Color.WHITE
var kind := "hit"
var radius := 28.0
var age := 0.0
var life := 0.5
var seeds: Array = []
var game
var element := "normal"

func _ready() -> void:
	z_index = 900
	if kind=="cast":
		life=0.28
	elif kind=="attack_hit":
		life=0.42
	elif kind=="switch":
		life=0.6
	for i in range(12):
		seeds.append(Vector2.from_angle(i*TAU/12+game.visual_rng.randf()*0.3)*game.visual_rng.randf_range(0.5,1.2))

func _process(dt: float) -> void:
	if game.screen != "fight":
		return
	age += dt
	if age>life:
		queue_free()
	queue_redraw()

func _draw() -> void:
	var progress := age/life
	var c := tint
	c.a = (1-progress)*0.8
	if kind != "dust":
		var flash := Color(1,1,1,(1-progress)*0.75)
		draw_circle(Vector2.ZERO,radius*0.32*(1-progress),flash)
		draw_arc(Vector2.ZERO,radius*progress,0,TAU,32,c,4*(1-progress)+1)
		draw_arc(Vector2.ZERO,radius*progress*0.68,0,TAU,24,Color(tint,(1-progress)*0.45),2)
		for i in range(8):
			var ray := Vector2.from_angle(i*TAU/8)*radius*(0.35+progress*0.9)
			draw_line(ray*0.45,ray,Color(tint,(1-progress)*0.7),3*(1-progress)+1)
	if kind=="switch":
		var ball_radius:=radius*(1-progress)*0.48
		draw_circle(Vector2.ZERO,ball_radius,Color(0.95,0.96,1,(1-progress)*0.9))
		draw_arc(Vector2.ZERO,ball_radius,PI,TAU,24,Color(0.95,0.22,0.28,(1-progress)*0.95),ball_radius*0.75)
		draw_line(Vector2(-ball_radius,0),Vector2(ball_radius,0),Color(0.12,0.16,0.22,1-progress),3)
		draw_circle(Vector2.ZERO,maxf(2,ball_radius*0.22),Color(1,1,1,1-progress))
	for seed in seeds:
		var p: Vector2 = seed*radius*progress*1.8
		p.y += progress*progress*20
		var s := 6*(1-progress)+1
		draw_colored_polygon(PackedVector2Array([p+Vector2(0,-s),p+Vector2(s,0),p+Vector2(0,s),p+Vector2(-s,0)]),c)
	if kind in ["cast","attack_hit"]:
		draw_element_mark(progress)
	draw_timing_layer(progress)

func draw_timing_layer(progress: float) -> void:
	var alpha: float=(1.0-progress)*0.75
	var p:=Vector2.ZERO
	if kind=="cast":
		# A short readable charge: tightening ring plus launch notch.
		draw_arc(p,radius*(1.15-progress*0.55),-PI*0.75,PI*0.75,20,Color(tint,alpha*0.65),3)
		draw_arc(p,radius*(0.65+progress*0.2),PI*0.2,PI*1.5,18,Color(1,1,1,alpha*0.55),2)
		for i in range(3):
			var a:=-0.5+float(i)*0.5
			draw_line(Vector2.from_angle(a)*radius*0.2,Vector2.from_angle(a)*radius*(0.8-progress*0.25),Color(tint,alpha),2)
	elif kind=="attack_hit":
		# Impact is layered separately from the projectile: flash, ring, shards.
		draw_circle(p,radius*(0.22+progress*0.35),Color(1,1,1,alpha*0.45))
		for i in range(6):
			var a:=float(i)*TAU/6.0+progress*0.7
			var start:=Vector2.from_angle(a)*radius*0.35
			var end:=Vector2.from_angle(a)*radius*(0.8+progress*0.35)
			draw_line(start,end,Color(tint,alpha),2)

func draw_element_mark(progress: float) -> void:
	var alpha := (1-progress)*0.9
	var size := radius*(0.35+progress*0.45)
	var bright := Color(1,1,1,alpha)
	match element:
		"electric":
			draw_polyline(PackedVector2Array([Vector2(-size*0.3,-size),Vector2(size*0.1,-size*0.15),Vector2(-size*0.05,-size*0.15),Vector2(size*0.35,size)]),bright,4)
		"fire":
			draw_colored_polygon(PackedVector2Array([Vector2(0,-size),Vector2(size*0.65,size*0.35),Vector2(0,size),Vector2(-size*0.65,size*0.35)]),Color(1,0.75,0.28,alpha))
		"water","ice":
			draw_arc(Vector2.ZERO,size,0,TAU,16,bright,3)
			draw_line(Vector2(-size,0),Vector2(size,0),bright,2)
			draw_line(Vector2(0,-size),Vector2(0,size),bright,2)
		"grass","bug","poison":
			draw_colored_polygon(PackedVector2Array([Vector2(-size,0),Vector2(0,-size),Vector2(size,0),Vector2(0,size*0.45)]),Color(0.82,1,0.55,alpha))
		"ghost","dark","psychic":
			draw_arc(Vector2.ZERO,size,-PI*0.7,PI*0.7,20,bright,4)
			draw_circle(Vector2(size*0.15,0),size*0.48,Color(0.2,0.08,0.35,alpha*0.55))
		"fairy":
			for i in range(4):
				var p := Vector2.from_angle(i*TAU/4)*size
				draw_line(p-Vector2(5,0),p+Vector2(5,0),bright,3)
				draw_line(p-Vector2(0,5),p+Vector2(0,5),bright,3)
		"dragon","fighting","steel","rock","ground":
			draw_polyline(PackedVector2Array([Vector2(0,-size),Vector2(size,0),Vector2(0,size),Vector2(-size,0),Vector2(0,-size)]),bright,3)
		_:
			draw_arc(Vector2.ZERO,size,0,TAU,20,bright,3)
