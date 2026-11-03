extends Node2D
## Shared attack lifecycle; different geometries drive both visuals and hit detection.
var source
var game
var move: Dictionary
var direction := Vector2.RIGHT
var origin := Vector2.ZERO
var target_position := Vector2.ZERO
var age := 0.0
var travelled := 0.0
var hit_targets: Array = []
var activated := false
var tick := 0.0
var tint := Color.WHITE
var kind := "bolt"
var radius := 12.0
var delay := 0.0
var arena_power := 1.0
var arena_speed := 1.0
var arena_boosted := false
var move_id := ""

static func swept_circle_fraction(start: Vector2, end: Vector2, center: Vector2, expanded_radius: float) -> float:
	var offset := start-center
	if offset.length_squared()<=expanded_radius*expanded_radius:
		return 0.0
	var motion := end-start
	var a := motion.length_squared()
	if a<0.000001:
		return INF
	var b := 2.0*offset.dot(motion)
	var c := offset.length_squared()-expanded_radius*expanded_radius
	var discriminant := b*b-4*a*c
	if discriminant<0:
		return INF
	var t := (-b-sqrt(discriminant))/(2*a)
	return t if t>=0 and t<=1 else INF

func configure(owner_fighter, values: Dictionary, point: Vector2) -> void:
	source = owner_fighter
	game = source.game
	move = values
	move_id = str(move.get("id",""))
	kind = str(move.kind)
	tint = Color(move.color)
	arena_power = float(game.arena_move_modifier(str(move.type),"power"))
	arena_speed = float(game.arena_move_modifier(str(move.type),"speed"))
	arena_boosted = arena_power>1.0
	radius = float(move.radius) * float(game.arena_move_modifier(str(move.type),"size"))
	direction = source.aim.normalized()
	origin = source.position
	target_position = point
	delay = float(move.get("delay",0))
	position = origin + direction*(source.radius+12)
	if kind in ["thunder","burst","zone"]:
		position = point
	elif kind in ["melee","nova","shield","beam","dash"]:
		position = origin
	z_index = 850

func raw_damage() -> float:
	return float(move.damage)*arena_power

func hit_fighter(fighter) -> bool:
	if fighter.team == source.team or not fighter.active or fighter.hp<=0 or hit_targets.has(fighter):
		return false
	var effectiveness := 1.0
	for defense_type in fighter.data.get("types",[fighter.data.type]):
		effectiveness *= float(game.types.get(move.type,{}).get(defense_type,1.0))
	if move.type == "electric" and fighter.statuses.has("wet"):
		effectiveness *= 1.25
	var physical: bool = kind in ["dash","melee","nova"]
	var offense := float(source.data.attack if physical else source.data.special_attack)
	var defense := float(fighter.data.defense if physical else fighter.data.special_defense)
	var damage: float = raw_damage() * (0.65 + offense/(defense+70)) * effectiveness * source.ability_attack_multiplier(str(move.type)) * source.power_multiplier
	var opposing_active = game.get_active(1-source.team)
	if is_instance_valid(opposing_active) and str(opposing_active.data.ability)=="Bedroher":
		damage*=0.9
	var push_direction := direction
	if kind in ["thunder","burst","zone","nova"]:
		push_direction = (fighter.position-position).normalized()
		if push_direction.is_zero_approx():
			push_direction = direction
	if fighter.take_hit(damage,push_direction,str(move.get("status","")),source,str(move.type)):
		source.hits += 1
		hit_targets.append(fighter)
		game.effect(fighter.position+Vector2(0,-20),tint,"attack_hit",radius+20,str(move.type))
		return true
	return false

func area_hit() -> void:
	for fighter in game.fighters:
		if fighter.active and position.distance_to(fighter.position)<radius+fighter.radius:
			hit_fighter(fighter)
	for rock in game.rocks.duplicate():
		if is_instance_valid(rock) and position.distance_to(rock.position)<radius+rock.radius and not hit_targets.has(rock):
			hit_targets.append(rock)
			rock.take_hit(raw_damage())

func _physics_process(dt: float) -> void:
	if game.screen != "fight":
		return
	age += dt
	match kind:
		"shield":
			queue_free()
		"thunder","burst","zone":
			if age >= delay and not activated:
				activated = true
				area_hit()
				game.mark_terrain(position,str(move.type),radius*0.72)
				game.effect(position,tint,"attack_hit",radius,str(move.type))
				game.play_sound("thunder" if kind=="thunder" else "impact")
				game.shake = 5 if kind=="thunder" else 3
			if kind == "zone" and activated:
				tick += dt
				if tick>=float(move.get("tick_interval",0.65)):
					tick = 0
					hit_targets.clear()
					area_hit()
			if age > delay + float(move.get("duration",0.45)):
				queue_free()
		"beam":
			if not activated:
				activated = true
				var end := position+direction*float(move.range)
				# Solid rocks stop the beam; the nearest blocker takes the hit.
				var nearest = null
				var beam_range := float(move.range)
				for rock in game.rocks:
					if is_instance_valid(rock):
						var fraction := swept_circle_fraction(position,end,rock.position,radius+rock.radius)
						var contact_distance := fraction*float(move.range)
						if contact_distance<beam_range:
							beam_range = contact_distance
							nearest = rock
				end = position+direction*beam_range
				target_position = end
				if nearest != null:
					nearest.take_hit(raw_damage())
				for fighter in game.fighters:
					if fighter.active and Geometry2D.get_closest_point_to_segment(fighter.position,position,end).distance_to(fighter.position)<radius+fighter.radius:
						hit_fighter(fighter)
			if age>0.32:
				queue_free()
		"melee","nova","dash":
			if not source.active or source.hp<=0:
				queue_free()
				return
			position = source.position
			var reach := float(move.range)
			for fighter in game.fighters:
				var delta: Vector2 = fighter.position-position
				if delta.length()<reach+fighter.radius and (kind=="nova" or delta.normalized().dot(direction)>0.35):
					hit_fighter(fighter)
			for rock in game.rocks.duplicate():
				if is_instance_valid(rock) and position.distance_to(rock.position)<reach+rock.radius and not hit_targets.has(rock) and (kind=="nova" or (rock.position-position).normalized().dot(direction)>0.35):
					hit_targets.append(rock)
					rock.take_hit(raw_damage())
			if age>0.23:
				queue_free()
		_:
			var previous := position
			var step := float(move.speed)*arena_speed*dt
			position += direction*step
			travelled += step
			var blocker = null
			var blocker_fraction := INF
			for rock in game.rocks.duplicate():
				if is_instance_valid(rock):
					var fraction := swept_circle_fraction(previous,position,rock.position,radius+rock.radius)
					if fraction<blocker_fraction:
						blocker=rock
						blocker_fraction=fraction
			var nearest_fighter = null
			var fighter_fraction := blocker_fraction
			for fighter in game.fighters:
				if not fighter.active or fighter.team==source.team or fighter.hp<=0 or fighter.dodge>0 or hit_targets.has(fighter):
					continue
				var fraction := swept_circle_fraction(previous,position,fighter.position,radius+fighter.radius)
				if fraction<fighter_fraction:
					nearest_fighter=fighter
					fighter_fraction=fraction
			if nearest_fighter!=null:
				if hit_fighter(nearest_fighter) and kind!="wave":
					position=previous.lerp(position,fighter_fraction)
					queue_free()
					return
			if blocker!=null:
				position=previous.lerp(position,blocker_fraction)
				blocker.take_hit(raw_damage())
				game.effect(position,tint,"attack_hit",radius+15,str(move.type))
				queue_free()
				return
			if travelled>float(move.range) or not game.bounds.grow(60).has_point(position):
				queue_free()
	queue_redraw()

func _draw() -> void:
	var r := radius
	var visual_origin := Vector2(0,-23)
	var moving_effect: bool = kind not in ["thunder","burst","zone","beam","melee","nova","dash","shield"]
	if moving_effect:
		for i in range(1,5):
			var trail_point := visual_origin-direction*float(i)*(r*0.55+5)
			draw_circle(trail_point,maxf(2,r*(0.52-float(i)*0.08)),Color(tint,0.22-float(i)*0.035))
	if arena_boosted:
		draw_arc(visual_origin,r+6,0,TAU,20,Color(1,0.9,0.45,0.55),2)
	match kind:
		"thunder","burst","zone":
			if age < delay:
				var p := age/maxf(0.01,delay)
				draw_circle(Vector2.ZERO,r,Color(tint,0.08))
				draw_arc(Vector2.ZERO,r,0,TAU,48,Color(tint,0.6),2)
				draw_arc(Vector2.ZERO,r*p,-PI/2,-PI/2+TAU*p,48,tint,3)
				for i in range(4):
					var point := Vector2.from_angle(i*PI/2)*r
					draw_line(point*0.85,point*1.12,tint,2)
			else:
				var t := age-delay
				if kind=="thunder":
					var lightning := PackedVector2Array([Vector2(-20,-650),Vector2(25,-260),Vector2(-13,-190),Vector2(32,-125),Vector2(-12,-65),Vector2.ZERO])
					draw_polyline(lightning,Color(tint,0.2),28)
					draw_polyline(lightning,tint,9)
					draw_polyline(lightning,Color("fffde1"),3)
					draw_arc(Vector2.ZERO,r*minf(1,t*4),0,TAU,48,tint,4)
				elif kind=="zone":
					draw_circle(Vector2.ZERO,r,Color(tint,0.12))
					for i in range(14):
						var a := i*TAU/14+t*4
						var p := Vector2(cos(a)*r*0.7,sin(a)*r*0.4)
						draw_colored_polygon(PackedVector2Array([p+Vector2(-8,0),p+Vector2(sin(t*10+i)*7,-24-i%3*8),p+Vector2(8,0)]),tint)
				else:
					for i in range(12):
						var a := i*TAU/12+t
						var point := Vector2.from_angle(a)*r*minf(1,t*4)
						draw_line(Vector2.ZERO,point,Color(tint,0.8),5)
						draw_circle(point,7,tint)
		"beam":
			var end := target_position-position
			draw_line(visual_origin,end+visual_origin,Color(tint,0.13),r*3)
			draw_line(visual_origin,end+visual_origin,Color(tint,0.7),r*1.5)
			draw_line(visual_origin,end+visual_origin,Color("e7ffff"),r*0.45)
			for i in range(10):
				var p := end*(i/10.0)+visual_origin
				draw_arc(p,9+sin(age*40+i)*4,0,TAU,12,tint,2)
		"melee","nova","dash":
			var a := direction.angle()
			var sweep := age/0.23
			if kind=="nova":
				draw_arc(visual_origin,r*sweep,0,TAU,40,tint,5)
			else:
				for i in range(3):
					draw_arc(visual_origin,(float(move.range)-i*13)*0.8,a-0.9+sweep*0.5,a+0.5+sweep*0.5,18,Color(tint,1-i*0.25),4-i)
		_:
			draw_set_transform(visual_origin,direction.angle())
			match kind:
				"bolt":
					var points := PackedVector2Array([Vector2(-35,0),Vector2(-15,-8),Vector2(-8,7),Vector2(8,-7),Vector2(26,0)])
					draw_polyline(points,Color(tint,0.2),16)
					draw_polyline(points,tint,5)
					draw_polyline(points,Color.WHITE,2)
				"orb":
					draw_circle(Vector2.ZERO,r+9,Color(tint,0.12))
					draw_circle(Vector2.ZERO,r,Color(tint,0.65))
					draw_arc(Vector2.ZERO,r+3,age*5,age*5+PI*1.6,20,tint,3)
					draw_circle(Vector2(-4,-4),r*0.5,Color("fff7dc") if move.type=="electric" else Color("ece0ff"))
					for i in range(6):
						var p := Vector2.from_angle(age*9+i*TAU/6)*r*1.2
						draw_line(p,p*1.35,tint,2)
				"water":
					draw_colored_polygon(PackedVector2Array([Vector2(-30,0),Vector2(-8,-r),Vector2(r,-r*0.4),Vector2(r,r*0.4),Vector2(-8,r)]),tint)
					draw_line(Vector2(-20,0),Vector2(r,0),Color("e0ffff"),5)
					for i in range(4):
						draw_circle(Vector2(-15-i*9,sin(age*30+i)*10),3,tint)
				"flame":
					for i in range(6):
						var p := Vector2(-i*9,sin(age*20+i)*8)
						draw_circle(p,r*(1-i*0.11),Color("f56a43"))
						draw_circle(p+Vector2(4,0),r*(0.55-i*0.06),Color("ffda78"))
				"wave":
					draw_arc(Vector2(-30,0),r,-1.1,1.1,24,Color(tint,0.2),30)
					draw_arc(Vector2(-30,0),r,-1.1,1.1,24,tint,9)
					draw_arc(Vector2(-27,0),r-7,-1.0,1.0,24,Color("ddffff"),3)
				"pulse":
					for i in range(3):
						draw_arc(Vector2(-i*16,0),r-i*4,-1.5,1.5,24,Color(tint,1-i*0.2),2)
				"crescent":
					draw_arc(Vector2(-18,0),r,-1.3,1.3,20,tint,5)
					draw_arc(Vector2(-12,0),r-6,-1.2,1.2,20,Color.WHITE,2)
			draw_set_transform(Vector2.ZERO)
	var signature_origin := Vector2.ZERO if kind in ["thunder","burst","zone"] else visual_origin
	draw_type_signature(signature_origin,minf(r,26.0))
	draw_named_move_detail(signature_origin,minf(r,30.0))
	# Keep the expensive layered fingerprints concentrated around the projectile's
	# launch moment. Long-lived projectiles and zones retain their readable core
	# effect without rebuilding every decorative strand on every frame.
	if age < 0.55:
		draw_move_fingerprint(signature_origin,minf(r,28.0))
	if age < 0.42:
		draw_attack_language(signature_origin,minf(r,32.0))

func draw_attack_language(center: Vector2, size: float) -> void:
	# Layered timing language: readable charge, travel shape, then a compact accent.
	var phase:=age*8.0
	var alpha:=0.45+0.25*sin(phase)
	var type:=str(move.get("type","normal"))
	draw_set_transform(center,direction.angle())
	match type:
		"water":
			for i in range(3):
				var x:=-size*0.9+float(i)*size*0.42
				var pts:=PackedVector2Array()
				for k in range(7):
					var t:=float(k)/6.0
					pts.append(Vector2(x+t*size*1.5,sin(phase*0.7+i+t*PI)*size*0.18))
				draw_polyline(pts,Color(0.74,0.96,1,alpha*(1.0-float(i)*0.16)),2.5)
		"fire":
			var core:=size*(0.34+0.08*sin(phase))
			draw_circle(Vector2.ZERO,core,Color(1,0.92,0.55,0.45))
			for i in range(5):
				var a:=-0.8+float(i)*0.4+sin(phase)*0.08
				var tip:=Vector2.from_angle(a)*size*(0.9+0.12*sin(phase+i))
				draw_colored_polygon(PackedVector2Array([Vector2(-core*0.35,0),Vector2(0,-core*0.55),tip,Vector2(0,core*0.55)]),Color(1,0.45+float(i)*0.05,0.12,alpha*0.78))
		"electric":
			var center_line:=PackedVector2Array([Vector2(-size,0),Vector2(-size*0.35,sin(phase)*size*0.24),Vector2(size*0.1,-sin(phase*1.3)*size*0.3),Vector2(size,0)])
			draw_polyline(center_line,Color(1,0.96,0.45,0.35),size*0.28)
			draw_polyline(center_line,Color("fff6a8"),2.5)
			for branch in [-1,1]:
				draw_polyline(PackedVector2Array([Vector2(-size*0.1,0),Vector2(size*0.25,branch*size*0.38),Vector2(size*0.55,branch*size*0.24)]),Color(1,0.88,0.25,0.75),2)
		"psychic","fairy":
			for ring in range(2):
				var pts:=PackedVector2Array()
				for i in range(17):
					var t:=float(i)/16.0
					pts.append(Vector2(-size*0.85+t*size*1.7,sin(phase*0.8+t*TAU+ring*PI)*size*(0.3+ring*0.08)))
				draw_polyline(pts,Color(1,0.72,1,0.78-float(ring)*0.25),2.5)
		"grass","bug":
			for i in range(4):
				var p:=Vector2(-size*0.65+float(i)*size*0.4,sin(phase+i)*size*0.4)
				draw_colored_polygon(PackedVector2Array([p+Vector2(-size*0.22,0),p+Vector2(0,-size*0.42),p+Vector2(size*0.22,0),p+Vector2(0,size*0.16)]),Color(0.72,1,0.48,0.8))
		"dragon":
			for i in range(4):
				var p:=Vector2(-size*0.65+float(i)*size*0.38,0)
				draw_colored_polygon(PackedVector2Array([p+Vector2(-size*0.18,0),p+Vector2(0,-size*0.34),p+Vector2(size*0.18,0),p+Vector2(0,size*0.34)]),Color(0.76,0.62,1,0.72))
		"ice":
			for i in range(3):
				var p:=Vector2(-size*0.5+float(i)*size*0.5,sin(phase+i)*size*0.2)
				draw_line(p-Vector2(0,size*0.4),p+Vector2(0,size*0.4),Color("d8ffff"),2)
				draw_line(p-Vector2(size*0.28,0),p+Vector2(size*0.28,0),Color("d8ffff"),2)
				draw_line(p-Vector2(size*0.18,size*0.25),p+Vector2(size*0.18,size*0.25),Color("d8ffff"),1.5)
		"ghost","dark":
			draw_arc(Vector2(-size*0.15,0),size*0.62,phase,phase+PI*1.6,24,Color(0.8,0.58,1,0.7),3)
			draw_circle(Vector2(size*0.28,0),size*0.18,Color(0.12,0.04,0.2,0.65))
		"fighting","steel","rock","ground":
			draw_arc(Vector2.ZERO,size*0.7,phase,phase+PI*1.2,18,Color(1,0.85,0.62,0.7),3)
			for i in range(3):
				draw_line(Vector2(-size*0.45+i*size*0.35,-size*0.25),Vector2(size*0.35+i*size*0.18,size*0.2),Color(1,0.92,0.78,0.5),2)
	draw_set_transform(Vector2.ZERO)

func draw_named_move_detail(center: Vector2, size: float) -> void:
	var move_id := str(move.get("id",""))
	var phase := age*9.0
	match move_id:
		"quick","extreme_speed":
			for i in range(4):
				var y := (float(i)-1.5)*size*0.35
				draw_line(center+Vector2(-size*1.4,y),center+Vector2(size*(0.2+i*0.1),y),Color(1,1,0.85,0.72-float(i)*0.1),3-i/2)
		"electroball":
			for i in range(3):
				var p := center+Vector2.from_angle(phase*(1.0+i*0.18)+i*TAU/3)*size
				draw_circle(p,4,Color("fff6a0"))
				draw_line(center,p,Color(1,0.9,0.25,0.35),2)
		"fire_spin":
			for i in range(14):
				var t := float(i)/13.0
				var p := center+Vector2.from_angle(phase+t*TAU*2.2)*size*t
				draw_circle(p,2+t*4,Color(1,0.35+t*0.45,0.12,0.8))
		"air_slash":
			draw_arc(center+Vector2(-size*0.25,0),size*1.1,-1.15,1.15,20,Color("eaffff"),4)
			draw_arc(center+Vector2(size*0.1,0),size*0.7,-1.05,1.05,18,Color(0.65,0.95,1,0.65),2)
		"fire_blast":
			for i in range(5):
				var p := center+Vector2.from_angle(i*TAU/5-PI/2)*size
				draw_line(center,p,Color("ffd27a"),5)
				draw_circle(p,4,Color("fff1b5"))
		"hydro":
			for i in range(3):
				draw_arc(center,size*(0.55+i*0.27),phase+i,phase+i+PI*1.35,24,Color(0.7,0.95,1,0.78-float(i)*0.16),3)
		"shell","rest_shield":
			var shield_points := PackedVector2Array()
			for i in range(7):
				shield_points.append(center+Vector2.from_angle(i*TAU/6-PI/2)*size)
			draw_polyline(shield_points,Color("e9ffff"),4)
		"shadowball":
			for i in range(5):
				var p := center+Vector2.from_angle(-phase+i*TAU/5)*size*0.9
				draw_circle(p,3,Color("d9b1ff"))
		"hypnosis":
			for i in range(3):
				draw_arc(center,size*(0.45+i*0.3),phase+i*0.7,phase+i*0.7+PI*1.55,24,Color(0.9,0.7,1,0.8-float(i)*0.18),3)
		"ice","blizzard":
			for i in range(3):
				var a := phase*0.2+i*PI/3
				draw_line(center+Vector2.from_angle(a)*size,center+Vector2.from_angle(a+PI)*size,Color("e7ffff"),2)
		"slash","metal_claw":
			for i in range(3):
				var y := (float(i)-1.0)*size*0.4
				draw_line(center+Vector2(-size,y+size*0.35),center+Vector2(size,y-size*0.35),Color("f5ffff"),3)
		"poison_powder":
			for i in range(8):
				var p := center+Vector2.from_angle(phase*0.35+i*TAU/8)*size*(0.45+float(i%3)*0.22)
				draw_circle(p,2+float(i%2)*2,Color(0.82,0.45,0.9,0.75))
		"future_sight":
			draw_arc(center,size,0,TAU,28,Color("ffd8ff"),3)
			draw_arc(center,size*0.62,0,PI,18,Color("fff4ff"),3)
			draw_circle(center,size*0.18,Color("fff8ff"))
		"earth_burst","rock_wave":
			for i in range(5):
				var a := i*TAU/5
				draw_line(center+Vector2.from_angle(a)*size*0.25,center+Vector2.from_angle(a+0.18)*size,Color("ffe0ad"),3)
		"water_shuriken":
			draw_set_transform(center,phase)
			for i in range(4):
				var a := i*PI/2
				var tip := Vector2.from_angle(a)*size*1.25
				var left := Vector2.from_angle(a+0.5)*size*0.42
				var right := Vector2.from_angle(a-0.5)*size*0.42
				draw_colored_polygon(PackedVector2Array([Vector2.ZERO,left,tip,right]),Color("8de8ff"))
			draw_circle(Vector2.ZERO,size*0.22,Color("efffff"))
			draw_set_transform(Vector2.ZERO)
		"thunderbolt","thunder":
			for branch in [-1,1]:
				var points := PackedVector2Array([center,center+Vector2(size*0.4,-size*0.35*branch),center+Vector2(size*0.7,size*0.05*branch),center+Vector2(size,size*0.5*branch)])
				draw_polyline(points,Color("fffbd1"),2)
		"razor_leaf":
			for i in range(3):
				var p := center+Vector2(0,(i-1)*size*0.55)
				draw_colored_polygon(PackedVector2Array([p+Vector2(-size,0),p+Vector2(0,-size*0.38),p+Vector2(size,0),p+Vector2(0,size*0.38)]),Color("b7f27c"))
				draw_line(p+Vector2(-size*0.8,0),p+Vector2(size*0.8,0),Color("efffcf"),2)
		"solar_beam":
			for i in range(6):
				var p := center+Vector2.from_angle(phase*0.35+i*TAU/6)*size*1.15
				draw_circle(p,3,Color("eaff8a"))
		"aura_sphere":
			draw_circle(center,size*0.72,Color(0.25,0.68,1,0.3))
			draw_arc(center,size,phase,phase+PI*1.4,24,Color("d8f5ff"),3)
			draw_arc(center,size*0.58,-phase,-phase+PI*1.4,20,Color("79cfff"),2)
		"psybeam","psychic_wave":
			for i in range(2):
				var offset := Vector2(0,sin(phase+i*PI)*size*0.7)
				draw_circle(center+offset,4,Color("ffd7ff"))
				draw_line(center,center+offset,Color(0.9,0.45,1,0.4),2)
		"dark_pulse","night":
			for i in range(3):
				draw_arc(center,size*(0.55+i*0.28),phase+i,phase+i+PI*1.25,20,Color(0.75,0.55,0.95,0.65-float(i)*0.12),3)
		"moon_blast","moonlight":
			draw_arc(center,size,phase,phase+PI*1.55,24,Color("fff1cf"),4)
			for i in range(4):
				var p := center+Vector2.from_angle(i*TAU/4-phase*0.25)*size*1.15
				draw_line(p-Vector2(3,0),p+Vector2(3,0),Color("ffd7f3"),2)
				draw_line(p-Vector2(0,3),p+Vector2(0,3),Color("ffd7f3"),2)
		"dragon_rush","dragon_claw","dragon_breath":
			var head := PackedVector2Array([center+Vector2(size,0),center+Vector2(size*0.15,-size*0.75),center+Vector2(-size*0.55,-size*0.45),center+Vector2(-size*0.25,0),center+Vector2(-size*0.55,size*0.45),center+Vector2(size*0.15,size*0.75),center+Vector2(size,0)])
			draw_polyline(head,Color("e3d4ff"),3)
		"flame","fire_fang":
			for i in range(3):
				var p := center+Vector2(-i*size*0.38,sin(phase+i)*size*0.25)
				draw_colored_polygon(PackedVector2Array([p+Vector2(-size*0.35,0),p+Vector2(0,-size*0.65),p+Vector2(size*0.35,0),p+Vector2(0,size*0.35)]),Color("ffe08a"))

func draw_move_fingerprint(center: Vector2, size: float) -> void:
	var move_id := str(move.get("id","normal"))
	var code := absi(move_id.hash())
	var count := 2+code%5
	var orbit := size*(0.72+float((code/7)%5)*0.08)
	var spin := age*(2.0+float((code/13)%5))* (-1.0 if code%2 else 1.0)
	var shape := (code/31)%4
	for i in range(count):
		var p := center+Vector2.from_angle(spin+i*TAU/float(count))*orbit
		match shape:
			0:
				draw_circle(p,2.0+float(code%3),Color(tint,0.72))
			1:
				draw_colored_polygon(PackedVector2Array([p+Vector2(0,-4),p+Vector2(4,0),p+Vector2(0,4),p+Vector2(-4,0)]),Color(tint,0.74))
			2:
				draw_line(p-Vector2(4,0),p+Vector2(4,0),Color(tint,0.8),2)
				draw_line(p-Vector2(0,4),p+Vector2(0,4),Color(tint,0.8),2)
			_:
				draw_arc(p,4,spin,spin+PI*1.35,8,Color(tint,0.8),2)

func draw_type_signature(center: Vector2, size: float) -> void:
	var phase := age*7.0
	var type := str(move.get("type","normal"))
	match type:
		"electric":
			var bolt := PackedVector2Array([center+Vector2(-size*0.35,-size*0.7),center+Vector2(size*0.08,-size*0.12),center+Vector2(-size*0.12,-size*0.12),center+Vector2(size*0.38,size*0.72)])
			draw_polyline(bolt,Color("fff5a8"),3)
		"fire":
			for i in range(3):
				var p := center+Vector2.from_angle(phase+i*TAU/3)*size*0.8
				draw_circle(p,3.5,Color("ffd06a"))
		"water","ice":
			for i in range(3):
				var p := center+Vector2.from_angle(phase*0.55+i*TAU/3)*size*0.85
				draw_arc(p,4,0,TAU,8,Color("e5ffff"),2)
		"grass","bug":
			for i in range(2):
				var p := center+Vector2.from_angle(phase+i*PI)*size*0.75
				draw_colored_polygon(PackedVector2Array([p+Vector2(-5,0),p+Vector2(0,-7),p+Vector2(5,0),p+Vector2(0,3)]),Color("d8ff9a"))
		"ghost","dark":
			draw_arc(center,size*0.7,phase,phase+PI*1.35,16,Color("e7c9ff"),3)
			draw_circle(center+Vector2(size*0.18,-size*0.08),size*0.36,Color(0.25,0.12,0.38,0.35))
		"psychic","fairy":
			for i in range(4):
				var p := center+Vector2.from_angle(-phase*0.7+i*TAU/4)*size*0.9
				draw_line(p-Vector2(3,0),p+Vector2(3,0),Color("fff1ff"),2)
				draw_line(p-Vector2(0,3),p+Vector2(0,3),Color("fff1ff"),2)
		"dragon","fighting":
			draw_polyline(PackedVector2Array([center+Vector2(0,-size*0.75),center+Vector2(size*0.55,0),center+Vector2(0,size*0.75),center+Vector2(-size*0.55,0),center+Vector2(0,-size*0.75)]),Color("f4eaff"),2)
		"steel","rock","ground":
			draw_polyline(PackedVector2Array([center+Vector2(-size*0.6,size*0.35),center+Vector2(-size*0.25,-size*0.55),center+Vector2(size*0.45,-size*0.35),center+Vector2(size*0.6,size*0.45)]),Color("fff0cf"),3)
		_:
			draw_arc(center,size*0.65,phase,phase+PI,12,Color(1,1,1,0.65),2)
