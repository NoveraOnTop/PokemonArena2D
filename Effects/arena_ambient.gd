extends Node2D
var variant := "volcano"
var time := 0.0
var timer := 0.0
func _process(dt: float) -> void:
	time+=dt
	timer+=dt
	if timer>=1.0/30.0:
		timer=0
		queue_redraw()
func _draw() -> void:
	if variant=="volcano":
		for i in range(20):
			var x:=fmod(i*179.0+sin(time+i)*10,1280)
			var y:=640-fmod(time*(16+i%5*5)+i*47,530)
			draw_rect(Rect2(x,y,2,3),Color(1,0.6,0.25,0.5))
	elif variant=="coast":
		for i in range(15):
			var y:=163+i*27.0
			var x:=20.0+sin(time*2+i)*3
			draw_line(Vector2(x,y),Vector2(x+13,y),Color(0.5,0.8,0.9,0.4),1)
	elif variant=="crystal":
		for i in range(12):
			var p:=Vector2(100+(i*137)%1080,180+(i*83)%360)
			draw_circle(p,2.0+sin(time*2+i),Color(0.65,0.75,1,0.55))
	elif variant=="storm":
		for i in range(7):
			var x:=120.0+i*175
			var alpha:=0.15+maxf(0,sin(time*3+i))*0.35
			draw_line(Vector2(x,145),Vector2(x+35,205),Color(0.55,0.88,1,alpha),2)
	elif variant=="haunted":
		for i in range(10):
			var p:=Vector2(90+(i*149)%1100,180+fmod(time*(12+i%3*3)+i*67,360))
			draw_circle(p,5+sin(time+i)*2,Color(0.72,0.48,0.9,0.22))
	elif variant=="jungle":
		for i in range(12):
			var p:=Vector2(80+(i*173)%1120,170+(i*91)%390)
			draw_line(p,p+Vector2(sin(time+i)*8,8),Color(0.72,1,0.55,0.25),2)
	elif variant=="factory":
		for i in range(8):
			var x:=120.0+i*145
			var pulse:=0.18+maxf(0,sin(time*4+i))*0.35
			draw_circle(Vector2(x,160+(i%2)*390),4,Color(0.45,1,0.9,pulse))
