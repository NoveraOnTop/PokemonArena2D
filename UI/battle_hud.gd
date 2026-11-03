extends Control

const Art = preload("res://Art/pixel_art.gd")
var game
var text_font: Font
var mono: Font
var displayed_hp := [1.0,1.0]
var update_timer := 0.0

func _ready() -> void:
	text_font = game.font
	mono = game.mono
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(dt: float) -> void:
	update_timer += dt
	if update_timer<1.0/30.0:
		return
	var step := update_timer
	update_timer = 0
	for side in range(2):
		var fighter = game.get_active(side)
		if fighter != null:
			displayed_hp[side] = lerpf(displayed_hp[side],fighter.hp/float(fighter.data.hp),minf(1,step*9))
	queue_redraw()

func text(value: String, p: Vector2, size := 16, color := Color.WHITE, use_mono := false) -> void:
	draw_string(mono if use_mono else text_font,p,value,HORIZONTAL_ALIGNMENT_LEFT,-1,maxi(size,14),color)

func box(rect: Rect2, tint := Color("172637"), edge := Color("354959")) -> void:
	draw_style_box(game.style(tint,edge,8),rect)

func _draw() -> void:
	if game.screen not in ["fight","pause"]:
		return
	for side in range(2):
		var fighter = game.get_active(side)
		if fighter == null:
			continue
		var x := 24.0 if side==0 else 876.0
		var color := Color("6be4c4") if side==0 else Color("f194a5")
		box(Rect2(x,18,380,102))
		draw_rect(Rect2(x+1,35,3,62),color)
		box(Rect2(x+12,29,78,78),Color("24364b"),Color("46566b"))
		draw_texture_rect(Art.get_texture(fighter.id),Rect2(x+17,31,68,68),false)
		text("DEIN TEAM" if side==0 else ("GEGNER · KI" if game.ai_enabled else "TRAININGS-DUMMY"),Vector2(x+104,40),11,color,true)
		if side==1 and game.game_mode=="boss":
			text("★ BOSS · PHASE %d/4" % game.boss_round,Vector2(x+104,27),11,Color("ffd36e"),true)
		text(str(fighter.data.name).to_upper(),Vector2(x+104,63),22)
		text(game.fighter_types(fighter.data),Vector2(x+270,60),10,Color(fighter.data.color),true)
		draw_rect(Rect2(x+104,73,256,8),Color("0b1626"))
		draw_rect(Rect2(x+104,73,256*displayed_hp[side],8),color)
		text("%d / %d KP" % [ceili(fighter.hp),int(fighter.data.hp)],Vector2(x+104,101),13,Color("b7c7d8"),true)
		var status_text := ""
		for status in fighter.statuses:
			status_text += {"wet":"NASS ","slow":"FROST ","sleep":"SCHLAF ","burn":"BRAND "}.get(status,"")
		if fighter.shield>0:
			status_text += "SCHUTZ"
		text(status_text,Vector2(x+235,101),11,Color("ffe1a2"),true)
	box(Rect2(520,18,240,104),Color("172637"))
	text("ARENA / " + game.arena_title().to_upper(),Vector2(539,40),11,Color("91a7b9"),true)
	text(game.arena_rule_text(),Vector2(539,58),9,Color("f0ce91"),true)
	text("%02d:%02d" % [int(game.elapsed)/60,int(game.elapsed)%60],Vector2(585,88),29)
	var mode_text: String = str({"boss":"BOSS-RUNDE %d/4" % game.boss_round,"tournament":"TURNIER %d/3" % game.tournament_round,"survival":"WELLE %d/5" % game.survival_wave,"story":"CHRONIK %d/5" % (game.story_chapter+1)}.get(game.game_mode,"3 GEGEN 3" if game.ai_enabled else "FREIES TRAINING"))
	text(mode_text,Vector2(570,109),11,Color("6be4c4"),true)
	if game.elapsed<game.feedback_until and not game.feedback_text.is_empty():
		var width := text_font.get_string_size(game.feedback_text,HORIZONTAL_ALIGNMENT_LEFT,-1,15).x
		text(game.feedback_text,Vector2(640-width/2,133),15,Color("f2d39a"))
	# Team rail: each card is also a mouse target handled by main.gd.
	for side in range(2):
		var lineup: Array = game.teams[side]
		for i in range(lineup.size()):
			var fighter = lineup[i]
			var x := 24.0+i*70 if side==0 else 1056.0+i*70
			var selected: bool = fighter.active
			box(Rect2(x,128,62,59),Color("26384a") if selected else Color("172637"),Color("f1d17d") if selected else Color("3a4b5d"))
			draw_texture_rect(Art.get_texture(fighter.id),Rect2(x+8,128,46,46),false,Color(1,1,1,1 if fighter.hp>0 else 0.22))
			draw_rect(Rect2(x+7,178,48,3),Color("0c1725"))
			draw_rect(Rect2(x+7,178,48*maxf(0,fighter.hp/float(fighter.data.hp)),3),Color("70d9bb") if side==0 else Color("ef95a5"))
			if side==0:
				text(str(i+1),Vector2(x+4,142),10,Color("e9d4a0"),true)
	var player = game.get_active(0)
	if player == null:
		return
	box(Rect2(24,614,1232,83),Color("131f30"))
	var energy: float = player.energy
	text("ENERGIE",Vector2(40,636),10,Color("93a6ba"),true)
	text(str(int(energy)),Vector2(40,667),24,Color("72c9e8"))
	draw_rect(Rect2(40,680,84,4),Color("293d50"))
	draw_rect(Rect2(40,680,84*energy/100,4),Color("72c9e8"))
	for slot in range(5):
		var x := 143.0+slot*219
		var is_dash := slot==0
		var move: Dictionary = {} if is_dash else game.moves[player.data.moves[slot-1]]
		var tint := Color("9ecbbd") if is_dash else Color(move.color)
		var cooldown: float = player.dodge_cooldown if is_dash else player.cooldowns[slot-1]
		var cost := 14 if is_dash else int(move.cost)
		box(Rect2(x,626,208,59),Color("243449"),tint.darkened(0.5))
		draw_rect(Rect2(x+1,627,3,56),tint)
		var binding: String = game.key_label("dodge") if is_dash else game.key_label("attack"+str(slot-1))
		if slot==1:
			binding+=" / LMB"
		elif slot==2:
			binding+=" / RMB"
		text(binding,Vector2(x+13,643),10,tint,true)
		text("Ausweichen" if is_dash else str(move.name),Vector2(x+13,665),16)
		# Status stays in the upper-right corner, away from the move title.
		if cooldown>0:
			var total: float = 1.15 if is_dash else float(move.cooldown)
			draw_rect(Rect2(x+12,676,184,3),Color("132135"))
			draw_rect(Rect2(x+12,676,184*clampf(1-cooldown/total,0,1),3),tint)
			text("%.1f s" % cooldown,Vector2(x+150,643),12,Color("e7e9f0"),true)
		elif energy<cost:
			text("%d EN!" % cost,Vector2(x+153,643),11,Color("ecb67e"),true)
		elif not is_dash and game.arena_move_modifier(str(move.type),"power")>1.0:
			text("ARENA+",Vector2(x+151,643),10,Color("f2d477"),true)
		else:
			text("%d EN" % cost,Vector2(x+155,643),10,Color("a5b6c8"),true)
	text("PFEILE / EIGENE TASTEN  BEWEGEN     AUTO-ZIELEN     %s / 1–3  WECHSEL     ESC  PAUSE     F2  KI" % game.key_label("switch"),Vector2(150,715),11,Color("9baebd"),true)
	if game.switch_cooldown>0:
		text("WECHSEL %.1f" % game.switch_cooldown,Vector2(240,150),11,Color("efcf8d"),true)
