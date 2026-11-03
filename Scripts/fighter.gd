extends CharacterBody2D

const Art = preload("res://Art/pixel_art.gd")
var data: Dictionary
var id := "pikachu"
var hp := 150.0
var energy := 100.0
var team := 0
var active := false
var player := false
var ai := false
var game
var target
var aim := Vector2.RIGHT
var aim_mode := "auto"
var last_direction := Vector2.RIGHT
var cooldowns: Array = [0.0,0.0,0.0,0.0]
var dodge := 0.0
var dodge_cooldown := 0.0
var dash_time := 0.0
var dash_direction := Vector2.RIGHT
var stun := 0.0
var shield := 0.0
var statuses: Dictionary = {}
var status_sources: Dictionary = {}
var flash := 0.0
var attack_pose := 0.0
var animation_time := 0.0
var ai_timer := 0.8
var hits := 0
var damage_done := 0.0
var sprite: Sprite2D
var radius := 20.0
var trail_timer := 0.0
var visual_direction := "front"
var power_multiplier := 1.0
var p2_switch_latch := false

func setup(creature_id: String, values: Dictionary, owner_game, side: int) -> void:
	id = creature_id
	data = values
	game = owner_game
	team = side
	player = side == 0
	hp = float(data.hp)
	radius = float(data.radius)
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	collision_layer = 2
	collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = radius
	shape.shape = circle
	add_child(shape)
	sprite = Sprite2D.new()
	sprite.texture = Art.get_texture(id)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position.y = -29 * float(data.scale)
	sprite.scale = Vector2.ONE * float(data.scale) * 2.0
	add_child(sprite)
	set_active(false)

func set_active(value: bool) -> void:
	active = value
	visible = value
	collision_layer = 2 if value else 0
	velocity = Vector2.ZERO
	queue_redraw()

func _physics_process(dt: float) -> void:
	if game.screen != "fight":
		return
	energy = minf(100, energy + (16 if id=="pikachu" else 13) * game.arena_modifier(self,"energy") * dt)
	for i in range(4):
		cooldowns[i] = maxf(0,cooldowns[i]-dt)
	dodge_cooldown = maxf(0,dodge_cooldown-dt)
	if not active or hp <= 0:
		return
	animation_time += dt
	dodge = maxf(0,dodge-dt)
	dash_time = maxf(0,dash_time-dt)
	stun = maxf(0,stun-dt)
	shield = maxf(0,shield-dt)
	flash = maxf(0,flash-dt)
	attack_pose = maxf(0,attack_pose-dt)
	for key in statuses.keys():
		statuses[key] -= dt
		if statuses[key] <= 0:
			statuses.erase(key)
			status_sources.erase(key)
	if statuses.has("burn"):
		apply_damage(2.5 * dt,status_sources.get("burn"))
	if hp<=0:
		velocity=Vector2.ZERO
		return
	var direction := Vector2.ZERO
	target = game.get_opponent(team)
	if player:
		direction = Input.get_vector("left","right","up","down")
		if game.touch_move.length()>0.08:
			direction=game.touch_move
		var pads := Input.get_connected_joypads()
		var stick := Vector2(Input.get_joy_axis(pads[0],JOY_AXIS_RIGHT_X),Input.get_joy_axis(pads[0],JOY_AXIS_RIGHT_Y)) if not pads.is_empty() else Vector2.ZERO
		if stick.length() > 0.25:
			aim = stick.normalized()
			aim_mode = "stick"
			game.mouse_aim = false
		elif game.mouse_aim and position.distance_to(game.aim_point) > 8:
			aim = (game.aim_point-position).normalized()
			aim_mode = "mouse"
		elif aim_mode!="stick" and is_instance_valid(target):
			aim = (target.position-position).normalized()
			aim_mode = "auto"
		# Vollautomatisches Zielen: Der Spieler löst nur die Attacke aus.
		# Bewegliche Gegner können dem bereits abgefeuerten Angriff ausweichen.
		if is_instance_valid(target) and position.distance_to(target.position) > 1:
			aim = (target.position-position).normalized()
			aim_mode = "auto"
		if stun <= 0 and not statuses.has("sleep"):
			if Input.is_action_just_pressed("dodge"):
				try_dodge(direction)
			for i in range(4):
				if Input.is_action_just_pressed("attack"+str(i)):
					attack(i)
	elif ai and is_instance_valid(target) and stun <= 0 and not statuses.has("sleep"):
		var to_enemy: Vector2 = target.position-position
		var dist := to_enemy.length()
		aim = to_enemy.normalized()
		var preferred := 150.0 if id == "sichlor" else 300.0
		if dist > preferred + 40:
			direction = aim
		elif dist < preferred - 80:
			direction = -aim
		else:
			direction = aim.orthogonal() * sin(animation_time * 1.1) * 0.7
		# Steer around obstacles rather than getting stuck behind a rock.
		for rock in game.rocks:
			if is_instance_valid(rock) and position.distance_to(rock.position) < 90:
				direction += (position-rock.position).normalized()*1.2
		ai_timer -= dt
		if ai_timer <= 0:
			var slot := choose_ai_move(dist)
			if slot>=0:
				attack(slot)
			ai_timer = game.combat_rng.randf_range(0.45,0.9) * game.ai_reaction
			if game.combat_rng.randf() < 0.25 / game.ai_reaction:
				try_dodge(aim.orthogonal() * (-1 if game.combat_rng.randf()<0.5 else 1))
	if direction.length() > 0.1:
		last_direction = direction.normalized()
	if stun > 0:
		velocity = velocity.move_toward(Vector2.ZERO,dt*900)
	elif statuses.has("sleep"):
		velocity = Vector2.ZERO
	elif dodge > 0 or dash_time > 0:
		velocity = dash_direction * (790 if dash_time > 0 else 650)
	else:
		var hunting_bonus := 1.1 if id=="sichlor" and energy>70 else 1.0
		velocity = direction.limit_length() * float(data.speed) * hunting_bonus * ability_speed_multiplier() * game.arena_modifier(self,"speed") * (0.55 if statuses.has("slow") else 1.0)
	move_and_slide()
	position.x = clampf(position.x,game.bounds.position.x+radius,game.bounds.end.x-radius)
	position.y = clampf(position.y,game.bounds.position.y+radius,game.bounds.end.y-radius)
	z_index = int(position.y)
	var moving := velocity.length() > 20
	var frame := int(animation_time*12) % 4 if moving else 0
	var looking := velocity.normalized() if moving and attack_pose<=0 else aim
	visual_direction = eight_direction(looking)
	sprite.texture = Art.get_texture(id,frame,visual_direction)
	sprite.flip_h = visual_direction in ["left","front_left","back_left"]
	sprite.position.y = -29*float(data.scale) - (absf(sin(animation_time*12))*3 if moving else sin(animation_time*3)*1.3)
	var stretch := Vector2(1.12,0.9) if attack_pose > 0 else Vector2.ONE
	# Kompaktere Darstellung für die 56px-Pixelvorlagen; Nearest-Filter hält
	# die Kanten scharf und verhindert verwaschene Zwischenpixel.
	sprite.scale = stretch * float(data.scale) * 1.75
	sprite.modulate = Color(3,3,3,0.7) if flash > 0 else Color(1,1,1,0.45 if dodge>0 else 1)
	trail_timer -= dt
	if (dodge > 0 or dash_time > 0) and trail_timer <= 0:
		game.effect(position,Color(data.color),"dust",22)
		trail_timer = 0.045
	queue_redraw()

func eight_direction(vector: Vector2) -> String:
	if vector.length()<0.05: return visual_direction
	var octant:=posmod(int(round(vector.angle()/(PI/4.0))),8)
	return ["right","front_right","front","front_left","left","back_left","back","back_right"][octant]

func try_dodge(direction := Vector2.ZERO) -> bool:
	if not active or hp<=0 or game.screen!="fight" or dodge_cooldown > 0 or energy < 14 or stun > 0 or statuses.has("sleep"):
		if player and active and game.screen=="fight" and energy<14:
			game.feedback("Ausweichen braucht 14 Energie.")
		return false
	energy -= 14
	dodge = 0.28 if id=="gengar" else 0.22
	dodge_cooldown = 1.15
	dash_direction = direction.normalized() if direction.length()>0.1 else last_direction
	statuses.erase("burn")
	status_sources.erase("burn")
	game.play_sound("dodge")
	return true

func choose_ai_move(distance: float) -> int:
	var best := -1
	var best_score := -1.0
	for slot in range(data.moves.size()):
		var move: Dictionary = game.moves[data.moves[slot]]
		if cooldowns[slot]>0 or energy<float(move.cost):
			continue
		if move.kind=="shield":
			if shield<=0 and hp<float(data.hp)*0.55 and distance<400:
				return slot
			continue
		if distance>float(move.range)+40:
			continue
		var multiplier := 1.0
		if is_instance_valid(target):
			for defense_type in target.data.get("types",[target.data.type]):
				multiplier*=float(game.types.get(move.type,{}).get(defense_type,1.0))
		if multiplier<=0:
			continue
		var score: float = game.combat_rng.randf_range(0.45,1.3)
		if game.difficulty>0:
			score+=minf(multiplier,2)*0.3
			if energy<35 and float(move.cost)<15:
				score+=0.5
			if move.has("status") and is_instance_valid(target) and not target.statuses.has(move.status):
				score+=0.3
			if move.kind in ["melee","nova","dash"] and distance>float(move.range):
				score-=0.4
		if score>best_score:
			best=slot
			best_score=score
	return best

func attack(index: int) -> bool:
	if index<0 or index>=data.moves.size() or not active or game.screen!="fight":
		return false
	var move: Dictionary = game.moves[data.moves[index]]
	if game.elapsed < 0.35 or cooldowns[index] > 0 or energy < float(move.cost) or hp <= 0 or stun > 0 or statuses.has("sleep"):
		if player and hp>0 and game.elapsed>=0.35:
			if statuses.has("sleep"):
				game.feedback("Du schläfst kurz. Ein Treffer weckt dich.")
			elif cooldowns[index]>0:
				game.feedback("%s · noch %.1f s" % [move.name,cooldowns[index]])
			elif energy<float(move.cost):
				game.feedback("%s braucht %d Energie." % [move.name,int(move.cost)])
		return false
	if player and is_instance_valid(target) and position.distance_to(target.position)>1:
		aim=(target.position-position).normalized()
	if move.kind in ["melee","nova"] and not player and is_instance_valid(target) and position.distance_to(target.position)>float(move.range)+30:
		return false
	energy -= float(move.cost)
	cooldowns[index] = float(move.cooldown)
	attack_pose = 0.25
	if move.kind == "dash":
		dash_time = 0.19
		dash_direction = aim
	if move.kind == "shield":
		shield = float(move.duration)
		statuses.erase("burn")
		status_sources.erase("burn")
	game.spawn_attack(self,move)
	return true

func apply_damage(amount: float, instigator = null) -> float:
	var lost := minf(hp,maxf(0,amount))
	hp = maxf(0,hp-lost)
	if is_instance_valid(instigator):
		instigator.damage_done += lost
	return lost

func ability_attack_multiplier(move_type: String) -> float:
	match str(data.ability):
		"Überwuchs": return 1.28 if hp<float(data.hp)*0.34 and move_type=="grass" else 1.0
		"Glutkern": return 1.24 if hp<float(data.hp)*0.4 and move_type=="fire" else 1.0
		"Statische Energie": return 1.08 if move_type=="electric" else 1.0
		"Wandlungskunst": return 1.08
		"Jägerinstinkt": return 1.12 if energy>70 else 1.0
		"Fährte": return 1.05
		_: return 1.0

func ability_speed_multiplier() -> float:
	match str(data.ability):
		"Sandschleier": return 1.14 if game.arena_id in ["volcano","ruins"] else 1.0
		"Schattenhülle": return 1.06
		_: return 1.0

func ability_defense_multiplier(move_type: String) -> float:
	match str(data.ability):
		"Multischuppe": return 0.55 if hp>=float(data.hp)*0.99 else 1.0
		"Dickes Fett": return 0.65 if move_type in ["fire","ice"] else 1.0
		"Frostschild": return 0.82 if move_type in ["water","ice"] else 1.0
		"Panzer": return 0.9
		_: return 1.0

func take_hit(amount: float, direction: Vector2, status := "", instigator = null, move_type := "normal") -> bool:
	if dodge > 0 or hp <= 0 or not active or amount<=0:
		return false
	var actual := amount * (0.25 if shield>0 else 1.0) * ability_defense_multiplier(move_type)
	actual = apply_damage(actual,instigator)
	flash = 0.1
	stun = 0.0 if str(data.ability)=="Konzentrator" else 0.11
	velocity = direction.normalized() * 225
	statuses.erase("sleep")
	var immune := (id=="glurak" and status=="burn") or (id=="lapras" and status=="slow")
	if shield<=0 and not status.is_empty() and not immune and str(data.ability)=="Magiespiegel" and is_instance_valid(instigator):
		instigator.statuses[status]={"wet":2.0,"burn":2.0,"slow":1.5,"sleep":0.55}.get(status,1.0)
		instigator.status_sources[status]=self
	elif shield<=0 and not status.is_empty() and not immune:
		statuses[status] = {"wet":4.0,"burn":3.5,"slow":2.2,"sleep":0.85}.get(status,1.0)
		status_sources[status] = instigator
		if str(data.ability)=="Synchro" and is_instance_valid(instigator):
			instigator.statuses[status]=minf(1.5,float(statuses[status]))
			instigator.status_sources[status]=self
	game.show_damage(position+Vector2(0,-85),int(actual),Color(data.color))
	game.effect(position+Vector2(0,-20),Color(data.color),"hit",28)
	game.play_sound("hit")
	return true

func _draw() -> void:
	if not active:
		return
	draw_set_transform(Vector2.ZERO,0,Vector2(1,0.38))
	draw_circle(Vector2.ZERO,radius+7,Color(0.01,0.02,0.04,0.45))
	draw_arc(Vector2.ZERO,radius+9,0,TAU,40,Color("77dfd0") if team==0 else Color("f38d9b"),2.5)
	if shield>0:
		draw_arc(Vector2.ZERO,radius+18,0,TAU,40,Color("a7e8ff"),3)
	draw_set_transform(Vector2.ZERO)
	if shield>0:
		draw_circle(Vector2(0,-32),radius+26,Color(0.6,0.9,1,0.07))
		draw_arc(Vector2(0,-32),radius+26,0,TAU,48,Color(0.65,0.9,1,0.7),2)
	if statuses.has("sleep"):
		draw_circle(Vector2(8,-90),4,Color("e4c6ff"))
	if statuses.has("slow"):
		draw_arc(Vector2(0,-20),radius+5,0,TAU,8,Color("b5f7ff"),2)

