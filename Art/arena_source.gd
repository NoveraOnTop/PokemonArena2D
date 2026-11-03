extends Node2D

var variant := "volcano"
var time := 0.0

func _process(dt: float) -> void:
	time += dt
	queue_redraw()

func frame(edge: Color, floor: Color) -> void:
	draw_rect(Rect2(0,0,1280,720),Color("101827"))
	draw_rect(Rect2(25,122,1230,500),edge.darkened(0.55))
	draw_rect(Rect2(41,138,1198,468),edge)
	draw_rect(Rect2(57,154,1166,436),floor)
	for x in range(70,1220,96):
		draw_rect(Rect2(x,137,54,8),edge.lightened(0.2))
		draw_rect(Rect2(x,593,54,7),edge.darkened(0.25))

func emblem(color: Color, shape := "circle") -> void:
	draw_set_transform(Vector2(640,380),0,Vector2(1,0.62))
	if shape=="diamond":
		draw_polyline(PackedVector2Array([Vector2(0,-170),Vector2(210,0),Vector2(0,170),Vector2(-210,0),Vector2(0,-170)]),color,5)
		draw_polyline(PackedVector2Array([Vector2(0,-70),Vector2(85,0),Vector2(0,70),Vector2(-85,0),Vector2(0,-70)]),color,4)
	elif shape=="hex":
		var points := PackedVector2Array()
		for i in range(7):
			points.append(Vector2.from_angle(i*TAU/6.0)*175)
		draw_polyline(points,color,5)
		draw_arc(Vector2.ZERO,62,0,TAU,36,color,4)
	else:
		draw_arc(Vector2.ZERO,175,0,TAU,72,color,5)
		draw_arc(Vector2.ZERO,48,0,TAU,32,color,4)
		draw_line(Vector2(-175,0),Vector2(-48,0),color,4)
		draw_line(Vector2(48,0),Vector2(175,0),color,4)
	draw_set_transform(Vector2.ZERO)

func _draw() -> void:
	match variant:
		"meadow": draw_meadow()
		"coast": draw_coast()
		"crystal": draw_crystal()
		"ruins": draw_ruins()
		"storm": draw_storm()
		"haunted": draw_haunted()
		"jungle": draw_jungle()
		"factory": draw_factory()
		_: draw_volcano()

func draw_volcano() -> void:
	frame(Color("542f35"),Color("332f38"))
	draw_rect(Rect2(0,96,1280,40),Color("c4472f"))
	draw_rect(Rect2(0,606,1280,55),Color("a9342b"))
	for i in range(38):
		var x := float((i*157)%1240+20)
		var y := float(165+(i*83)%410)
		draw_polyline(PackedVector2Array([Vector2(x,y),Vector2(x+22,y+14),Vector2(x+9,y+37)]),Color("7c453f"),6)
		draw_polyline(PackedVector2Array([Vector2(x,y),Vector2(x+22,y+14),Vector2(x+9,y+37)]),Color("e66b3f"),2)
	for i in range(12):
		var p := Vector2(90+i*98,190+(i%3)*130)
		draw_colored_polygon(PackedVector2Array([p+Vector2(-20,18),p+Vector2(-8,-22),p+Vector2(17,-15),p+Vector2(25,17)]),Color("26232d"))
	emblem(Color(1,0.48,0.27,0.34),"circle")

func draw_meadow() -> void:
	frame(Color("355c49"),Color("4f7b55"))
	draw_rect(Rect2(0,90,1280,55),Color("173f36"))
	draw_rect(Rect2(0,606,1280,64),Color("193f36"))
	draw_colored_polygon(PackedVector2Array([Vector2(57,325),Vector2(300,280),Vector2(530,335),Vector2(760,310),Vector2(1223,360),Vector2(1223,455),Vector2(820,430),Vector2(560,475),Vector2(260,420),Vector2(57,468)]),Color("8a744c"))
	for i in range(95):
		var p := Vector2(70+(i*137)%1130,165+(i*71)%410)
		var c: Color = [Color("f1d36f"),Color("e9a5c5"),Color("9fd6ef")][i%3]
		draw_line(p,p+Vector2(0,-7),Color("274f39"),2)
		draw_circle(p+Vector2(0,-9),2.5,c)
	for p in [Vector2(170,235),Vector2(1080,245),Vector2(205,525),Vector2(1060,510)]:
		draw_circle(p,46,Color("244f3c"))
		draw_circle(p-Vector2(0,18),34,Color("477c4d"))
	emblem(Color(0.84,1,0.65,0.24),"diamond")

func draw_coast() -> void:
	draw_rect(Rect2(0,0,1280,720),Color("102c43"))
	for y in range(92,650,28):
		draw_line(Vector2(0,y),Vector2(1280,y+sin(y)*6),Color(0.35,0.75,0.87,0.28),3)
	draw_colored_polygon(PackedVector2Array([Vector2(35,260),Vector2(150,150),Vector2(1130,150),Vector2(1245,270),Vector2(1190,550),Vector2(1040,605),Vector2(210,605),Vector2(70,530)]),Color("d3b77d"))
	draw_colored_polygon(PackedVector2Array([Vector2(58,280),Vector2(170,170),Vector2(1110,170),Vector2(1220,290),Vector2(1170,530),Vector2(1020,585),Vector2(225,585),Vector2(92,515)]),Color("a88e62"))
	for i in range(45):
		var p := Vector2(100+(i*181)%1080,185+(i*67)%370)
		draw_circle(p,3+(i%3),Color("ead6a4"))
	for x in [250,980]:
		draw_rect(Rect2(x,145,34,150),Color("6a4935"))
		for y in range(150,290,28):
			draw_line(Vector2(x,y),Vector2(x+34,y),Color("b8834e"),3)
	emblem(Color(0.75,0.95,1,0.30),"circle")

func draw_crystal() -> void:
	frame(Color("342f63"),Color("25294b"))
	for i in range(44):
		var p := Vector2(75+(i*149)%1120,165+(i*97)%400)
		var s := 10.0+float(i%4)*5
		draw_colored_polygon(PackedVector2Array([p+Vector2(-s,12),p+Vector2(0,-s*2),p+Vector2(s,12),p+Vector2(0,22)]),Color("5b67a8").lightened((i%3)*0.08))
		draw_line(p+Vector2(0,-s*2),p+Vector2(0,18),Color(0.7,0.8,1,0.55),2)
	for r in [70.0,140.0,220.0]:
		draw_arc(Vector2(640,380),r,0,TAU,8,Color(0.45,0.55,1,0.16),3)
	emblem(Color(0.63,0.72,1,0.36),"hex")

func draw_ruins() -> void:
	frame(Color("735b3e"),Color("9a8058"))
	for y in range(170,580,54):
		for x in range(70,1210,74):
			var offset := 35 if (y/54 as int)%2 else 0
			draw_rect(Rect2(x+offset,y,65,45),Color("a98d60") if (x+y)%3 else Color("8d704d"),false,2)
	for p in [Vector2(130,210),Vector2(1150,210),Vector2(130,545),Vector2(1150,545)]:
		draw_circle(p,31,Color("5c4938"))
		draw_circle(p-Vector2(0,10),24,Color("b59b6b"))
		draw_circle(p-Vector2(0,10),9,Color("6f5a43"))
	draw_line(Vector2(180,560),Vector2(1100,190),Color(0.95,0.82,0.54,0.12),60)
	emblem(Color(1,0.89,0.59,0.28),"diamond")

func draw_storm() -> void:
	frame(Color("35475c"),Color("354153"))
	for y in range(170,580,52):
		draw_line(Vector2(60,y),Vector2(1220,y),Color("526579"),2)
	for x in range(80,1220,110):
		draw_line(Vector2(x,155),Vector2(x,590),Color("283544"),3)
	for i in range(16):
		var p := Vector2(105+(i*173)%1080,185+(i*113)%360)
		draw_polyline(PackedVector2Array([p,p+Vector2(18,22),p+Vector2(6,45),p+Vector2(31,72)]),Color(0.55,0.86,1,0.45),4)
	for p in [Vector2(85,175),Vector2(1195,175),Vector2(85,560),Vector2(1195,560)]:
		draw_circle(p,24,Color("172536"))
		draw_arc(p,18,0,TAU,20,Color("75ccea"),3)
	emblem(Color(0.55,0.88,1,0.35),"hex")

func draw_haunted() -> void:
	frame(Color("3b2948"),Color("272638"))
	for i in range(18):
		var p := Vector2(90+(i*191)%1100,175+(i*107)%385)
		draw_circle(p,18+float(i%4)*5,Color(0.42,0.25,0.55,0.16))
		draw_arc(p,25+float(i%3)*7,0,PI,20,Color(0.72,0.55,0.82,0.28),2)
	for x in [105,1175]:
		draw_rect(Rect2(x-25,180,50,350),Color("171724"))
		for y in range(205,520,65):
			draw_arc(Vector2(x,y),18,PI,TAU,16,Color("76578b"),3)
	for i in range(10):
		var p := Vector2(170+i*104,545-(i%2)*25)
		draw_line(p,p+Vector2(-8,-35),Color("171724"),5)
		draw_line(p+Vector2(-8,-35),p+Vector2(-20,-52),Color("171724"),3)
		draw_line(p+Vector2(-8,-35),p+Vector2(7,-55),Color("171724"),3)
	emblem(Color(0.72,0.48,0.9,0.34),"diamond")

func draw_jungle() -> void:
	frame(Color("244b35"),Color("315d3e"))
	draw_colored_polygon(PackedVector2Array([Vector2(57,220),Vector2(330,155),Vector2(610,235),Vector2(920,165),Vector2(1223,230),Vector2(1223,520),Vector2(980,590),Vector2(690,520),Vector2(390,585),Vector2(57,515)]),Color("376d45"))
	for i in range(70):
		var p := Vector2(70+(i*163)%1130,165+(i*89)%410)
		var leaf := Color("6ea94f") if i%2 else Color("4b873d")
		draw_colored_polygon(PackedVector2Array([p+Vector2(-9,0),p+Vector2(0,-15),p+Vector2(10,0),p+Vector2(0,6)]),leaf)
	for p in [Vector2(170,225),Vector2(1110,230),Vector2(190,525),Vector2(1090,520)]:
		draw_circle(p,55,Color("183d2b"))
		draw_circle(p-Vector2(0,25),38,Color("427a3c"))
	draw_line(Vector2(120,380),Vector2(1160,380),Color(0.78,0.62,0.34,0.18),80)
	emblem(Color(0.73,1,0.55,0.3),"circle")

func draw_factory() -> void:
	frame(Color("3b4852"),Color("303c46"))
	for y in range(170,580,58):
		for x in range(70,1210,92):
			draw_rect(Rect2(x,y,78,45),Color("42515c"),false,2)
			draw_circle(Vector2(x+9,y+9),3,Color("92a5ad"))
			draw_circle(Vector2(x+69,y+36),3,Color("92a5ad"))
	for p in [Vector2(150,215),Vector2(1130,215),Vector2(150,540),Vector2(1130,540)]:
		draw_circle(p,35,Color("172630"))
		draw_arc(p,25,0,TAU,24,Color("67d8d2"),5)
		draw_circle(p,8,Color("d7fff0"))
	for i in range(7):
		var x := 250.0+i*130
		draw_line(Vector2(x,155),Vector2(x+55,590),Color(0.2,0.9,0.78,0.12),18)
	emblem(Color(0.45,1,0.9,0.32),"hex")
