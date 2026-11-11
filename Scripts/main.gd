extends Node2D

const Fighter = preload("res://Scripts/fighter.gd")
const Attack = preload("res://Scripts/projectile.gd")
const Arena = preload("res://Arenas/arena.gd")
const Rock = preload("res://Arenas/rock.gd")
const Burst = preload("res://Effects/burst.gd")
const TerrainMark = preload("res://Effects/terrain_mark.gd")
const BattleHUD = preload("res://UI/battle_hud.gd")
const Art = preload("res://Art/pixel_art.gd")
const Controls = preload("res://Scripts/input_config.gd")
const DataValidator = preload("res://Scripts/data_validator.gd")
const SAVE_PATH = "user://arena_settings.cfg"
const ARENAS = ["volcano","meadow","coast","crystal","ruins","storm","haunted","jungle","factory"]
const ARENA_TYPES = {
	"volcano": ["fire","rock","ground"],
	"meadow": ["grass","bug","fairy"],
	"coast": ["water","ice","electric"],
	"crystal": ["ice","psychic","steel"],
	"ruins": ["fighting","ghost","normal"],
	"storm": ["electric","flying","dragon"],
	"haunted": ["ghost","dark","psychic"],
	"jungle": ["grass","poison","bug"],
	"factory": ["steel","electric","fighting"]
}
const CREATURES = ["pikachu","glurak","turtok","gengar","lapras","sichlor","bisaflor","lucario","relaxo","arkani","dragoran","psiana","nachtara","knakrack","guardevoir","greninja"]
const UNLOCK_ORDER = ["gengar","lapras","sichlor","bisaflor","lucario","relaxo","arkani","dragoran","psiana","nachtara","knakrack","guardevoir","greninja","accelgor","admurai","alomomola","amoonguss","apoquallyp","archen","archeops","audino","axew","basculin","beartic","beheeyem","bisharp","blitzle","boldore","bouffalant","branawarz","braviary","carracosta","chandelure","cinccino","conkeldurr","cottonee","crustle","cryogonal","cubchoo","darmanitan","darumaka","deerling","deino","dewott","drilbur","druddigon","ducklett","duosion","durant","dwebble","echnatoll","eelektrik","eelektross","elgyem","emboar","emolga","escavalier","excadrill","ferroseed","ferrothorn","flunschlik","foongus","fraxure","frillish","galvantula","garbodor","genesect","gigalith","golett","golurk","gothita","gothitelle","gothorita","grypheldis","gurdurr","haxorus","heatmor","herdier","joltik","karrablast","keldeo","klang","klink","klinklang","kobalium","krokorok","krookodile","lampent","landorus","larvesta","leavanny","liepard","lilligant","lillipup","litwick","maractus","meloetta","mienfoo","mienshao","minccino","munna","musharna","oshawott","palpitoad","panpour","pansage","pansear","patrat","pawniard","petilil","pidove","pignite","purrloin","reuniclus","roggenrola","rufflet","sandile","sawk","sawsbuck","scolipede","scrafty","scraggy","serperior","servine","sewaddle","shelmet","sigilyph","simipour","simisage","simisear","snivy","solosis","stoutland","swadloon","swanna","swoobat","tepig","terrakion","throh","thundurus","timburr","tirtouga","tornadus","tranquill","trikephalo","trubbish","tympole","tynamo","unfezant","vanillish","vanillite","vanilluxe","venipede","victini","viridium","volcarona","vullaby","watchog","whimsicott","whirlipede","woobat","yamask","zebstrika","zoroark","zorua","zweilous"]
const WINS_PER_UNLOCK := 5
const STORY = [
	{"title":"Der erste Ruf","arena":"meadow","rival":["bisaflor","sichlor","arkani"],"trainer":"Mira, Hüterin des Blütenpfads","scene":"Morgendämmerung am Blütenpfad","text":"Als der Resonanzkern erwacht, verstummen die Käfer und selbst die Blätter zittern. Mira stellt sich dir in den Weg: Sie glaubt, dass nur ein entschlossener Trainer den Ruf hören darf. Hinter ihr flackert ein grünes Licht zwischen den Wurzeln.","lore":"Du erinnerst dich an die Warnung deines ersten Mentors: Resonanz wird nicht durch Stärke geweckt, sondern durch Entscheidungen. Zum ersten Mal spürst du, dass dein Team nicht zufällig zusammengefunden hat.","line":"Mira: Wenn du den Kern suchst, musst du zuerst beweisen, dass du seine Wächter nicht fürchtest.","objective":"Besiege Miras Wächterteam und sichere das erste Resonanzfragment.","reward":"Resonanzfragment: Grün"},
	{"title":"Wellen aus Stahl","arena":"coast","rival":["turtok","lapras","lucario"],"trainer":"Kian, Kapitän der Küstenwache","scene":"Sturmflut am Korallenstrand","text":"Das Fragment zieht eine Spur aus Licht über das Meer. Im Hafen von Korallhafen schlagen Maschinen unkontrolliert Funken. Kian hält die Evakuierung aufrecht, bis du den Störsender erreichst. Zwischen den Wellen findest du Zeichen, die älter sind als jede Arena.","lore":"Ein Signal aus der Tiefe antwortet auf das Fragment. Die Maschine will nicht nur Energie sammeln — sie sucht etwas, das unter dem Meer schläft. Kian gibt dir seine alte Seekarte und bittet dich, niemanden zurückzulassen.","line":"Kian: Das Meer verzeiht keinen Leichtsinn. Zeig mir, dass dein Team auch unter Druck zusammensteht.","objective":"Stoppe die Störung und bringe das zweite Fragment aus der Brandungszone.","reward":"Resonanzfragment: Blau"},
	{"title":"Stimmen im Schloss","arena":"haunted","rival":["gengar","nachtara","psiana"],"trainer":"Noctis, der Flüsterer","scene":"Die Uhr schlägt dreizehn","text":"Hinter den Mauern des Spukschlosses antwortet der Kern mit Stimmen. Noctis kennt den Weg, doch er fordert einen Kampf, bevor er dir die Tür zum Archiv öffnet. Jeder Korridor zeigt eine Erinnerung, die nicht deine sein kann.","lore":"Im Archiv liest du von vier legendären Wächtern, die den Kern einst versiegelten. Eine Seite wurde herausgerissen. Auf dem Boden glimmt das Zeichen eines schwarzen Blitzes — jemand ist dir bereits voraus.","line":"Noctis: Manche Erinnerungen wollen nicht geweckt werden. Deine Pokémon müssen stärker sein als ihre eigenen Schatten.","objective":"Durchquere das Archiv und löse das dritte Fragment aus der Dunkelresonanz.","reward":"Resonanzfragment: Violett"},
	{"title":"Herz des Sturms","arena":"storm","rival":["pikachu","dragoran","knakrack"],"trainer":"Ayla, Reiterin der Sturmspitze","scene":"Blitze über dem Wolkenmeer","text":"Die drei Fragmente bilden eine Karte zum Gipfel. Ayla wartet zwischen den Gewittertürmen: Der Kern sammelt dort genug Energie, um alle Arenen zu verschlingen. Über den Wolken kreist ein Schatten, zu groß für jeden bekannten Pokédex-Eintrag.","lore":"Ayla enthüllt, dass der Kern ursprünglich als Friedensmaschine gebaut wurde. Direktor Vale hat ihn umprogrammiert, nachdem er ein legendäres Pokémon am Himmel gesehen hatte. Der Sturm ist kein Naturereignis — er ist ein Ruf.","line":"Ayla: Ein Sturm ist kein Feind, den man besiegt. Du musst lernen, seinen Rhythmus zu lesen.","objective":"Erreiche den Gipfel und überstehe Aylas Sturmprüfung.","reward":"Zugang zum Resonanzkern"},
	{"title":"Finale im Kraftwerk","arena":"factory","rival":["lucario","guardevoir","greninja"],"trainer":"Direktor Vale, Architekt des Kerns","scene":"Das Herz der Arena","text":"Im Kraftwerk treffen alle Resonanzen zusammen. Direktor Vale hat den Kern gebaut, um Kämpfe vorherzusagen — und dabei vergessen, dass Vertrauen nicht berechenbar ist. Nur dein Team kann die Maschine noch abschalten. Hinter dem Reaktor öffnet sich ein Riss aus grünem Licht.","lore":"Vale gesteht, dass er die legendären Pokémon nicht kontrollieren wollte, sondern ihre Kraft nutzen, um jede Niederlage zu verhindern. Als der Kern außer Kontrolle gerät, musst du dich entscheiden: die Maschine zerstören oder sie für immer versiegeln. Dein Team wartet auf dein Zeichen.","line":"Vale: Ich habe jeden möglichen Ausgang berechnet. Zeig mir den einen, den ich übersehen habe.","objective":"Besiege Vale, zerbrich die Resonanzschleife und rette die Arenen.","reward":"Die Arenen sind wieder frei"}
]
const BOSS_ROUTES = [
	{"name":"Himmelssturm","boss":"rayquaza","arena":"storm","teams":[["arkani","bisaflor","lucario"],["gengar","nachtara","guardevoir"],["knakrack","dragoran","greninja"]],"text":"Bezwinge den Sturm und erreiche Rayquaza."},
	{"name":"Urmeer","boss":"kyogre","arena":"coast","teams":[["turtok","lapras","greninja"],["sichlor","lucario","guardevoir"],["lapras","turtok","greninja"]],"text":"Überlebe die Flut und wecke Kyogre aus der Tiefsee."},
	{"name":"Eisnull","boss":"kyurem","arena":"crystal","teams":[["lapras","nachtara","dragoran"],["glurak","knakrack","lucario"],["glurak","dragoran","knakrack"]],"text":"Durchquere den gefrorenen Kern und stelle dich Kyurem."},
	{"name":"Drachenblitz","boss":"zekrom","arena":"factory","teams":[["pikachu","lucario","sichlor"],["guardevoir","arkani","gengar"],["lucario","pikachu","bisaflor"]],"text":"Stoppe die Maschinen und überlebe Zekroms Donner."},
	{"name":"Weiße Flamme","boss":"reshiram","arena":"volcano","teams":[["turtok","lapras","greninja"],["glurak","gengar","guardevoir"],["glurak","arkani","dragoran"]],"text":"Steige durch den Vulkan und bezwinge Reshirams Feuer."}
]
var roster: Dictionary
var moves: Dictionary
var types: Dictionary
var screen := "menu"
var world: Node2D
var arena_node: Node2D
var arena_id := "volcano"
var bounds := Rect2(68,192,1144,382)
var fighters: Array = []
var teams: Array = [[],[]]
var rocks: Array = []
var selected_team: Array = ["pikachu","glurak","turtok"]
var team_presets: Array = [["pikachu","glurak","turtok"],["bisaflor","lucario","greninja"],["gengar","lapras","arkani"]]
var active_preset := 0
var selected_slot := 0
var active_indices := [0,0]
var last_rival_team: Array = []
var ui: Control
var modal: Control
var hud
var camera: Camera2D
var font: Font
var mono: Font
var elapsed := 0.0
var world_time := 0.0
var ai_enabled := true
var difficulty := 1
var ai_reaction := 1.0
var switch_cooldown := 0.0
var mouse_aim := false
var aim_point := Vector2(950,380)
var shake := 0.0
var sound_volume := 0.35
var audio_player: AudioStreamPlayer
var sounds: Dictionary = {}
var total_hits := 0
var total_damage := 0.0
var style_cache: Dictionary = {}
var intro: Label
var key_bindings: Dictionary = {}
var pending_rebind := ""
var binding_message := ""
var audio_pool: Array = []
var audio_cursor := 0
var music_player: AudioStreamPlayer
var music_streams: Dictionary = {}
var combat_rng := RandomNumberGenerator.new()
var visual_rng := RandomNumberGenerator.new()
var is_quitting := false
var focus_pause_enabled := true
var data_errors := PackedStringArray()
var feedback_text := ""
var feedback_until := 0.0
var hazard_timer := 6.0
var game_mode := "arena"
var tournament_round := 0
var survival_wave := 0
var boss_round := 0
var selected_boss := 0
var team_search := ""
var team_scroll := 0
var survival_hp: Dictionary = {}
var trainer_level := 1
var trainer_xp := 0
var wins := 0
var losses := 0
var total_matches := 0
var best_streak := 0
var current_streak := 0
var story_chapter := 0
var story_completed := 0
var unlocked_creatures: Array = ["pikachu","glurak","turtok"]
var touch_move := Vector2.ZERO
var touch_origin := Vector2.ZERO
var touch_finger := -1
var touch_aim_finger := -1

func _ready() -> void:
	Engine.max_fps = 60
	get_tree().auto_accept_quit=false
	combat_rng.seed = randi()
	visual_rng.randomize()
	roster = read_json("fighters")
	# Bossdaten bleiben spielbar, auch wenn der Boss nicht zur normalen Auswahl gehört.
	var boss_template: Dictionary = roster.get("dragoran", {})
	for boss_id in ["rayquaza","kyogre","kyurem","zekrom","reshiram"]:
		if not roster.has(boss_id) and not boss_template.is_empty():
			var boss_data: Dictionary = boss_template.duplicate(true)
			boss_data["name"] = boss_id.capitalize()
			boss_data["hp"] = int(boss_data.get("hp",170)) + 120
			boss_data["attack"] = int(boss_data.get("attack",65)) + 25
			boss_data["color"] = "d8a7e8"
			roster[boss_id] = boss_data
	# Neue Sprite-Pokémon erhalten sichere Basisdaten, falls ältere Datendateien geladen werden.
	var new_template: Dictionary = roster.get("pikachu", {})
	for new_id in ["bisasam","glumanda","schiggy","tauboss","rattikarl","arbok","raichu","nidoqueen","nidoking","vulnona","machomei","geowaz","starmie","garados","aquana","blitza","flamara","mewtu","hooh","lugia"]:
		if not roster.has(new_id) and not new_template.is_empty():
			var new_data: Dictionary = new_template.duplicate(true)
			new_data["name"] = new_id.capitalize()
			new_data["description"] = "Ein neuer Kämpfer für die Arena."
			roster[new_id] = new_data
	moves = read_json("moves")
	for move_id in moves:
		moves[move_id]["id"] = str(move_id)
	types = read_json("types")
	data_errors=DataValidator.validate(roster,moves,types,CREATURES)
	font = SystemFont.new()
	font.font_names = PackedStringArray(["Bahnschrift","Arial"])
	mono = SystemFont.new()
	mono.font_names = PackedStringArray(["Consolas","Courier New"])
	load_settings()
	configure_input()
	prepare_sounds()
	camera = Camera2D.new()
	camera.position = Vector2(640,360)
	add_child(camera)
	var layer := CanvasLayer.new()
	add_child(layer)
	ui = Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var theme := Theme.new()
	theme.default_font = font
	theme.default_font_size = 18
	ui.theme = theme
	layer.add_child(ui)
	modal = Control.new()
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(modal)
	if not data_errors.is_empty():
		show_data_error()
		return
	for id in CREATURES:
		for direction in ["front","front_right","right","back_right","back","back_left","left","front_left"]:
			for frame in range(4):
				Art.get_texture(id,frame,direction)
	show_menu()

func show_data_error() -> void:
	screen="data_error"
	clear(ui)
	panel(Rect2(60,60,1160,600),Color("18283b"))
	label_at("SPIELDATEN PRÜFEN",Vector2(95,87),34,Color("efb5a0"))
	label_at("Eine bearbeitete Datendatei enthält ungültige Werte. Bitte korrigiere diese Einträge:",Vector2(95,146),18)
	var details := RichTextLabel.new()
	details.position=Vector2(95,195)
	details.size=Vector2(1060,340)
	details.text="\n".join(data_errors)
	details.add_theme_font_override("normal_font",mono)
	details.add_theme_font_size_override("normal_font_size",17)
	ui.add_child(details)
	button_at("Beenden",Rect2(95,570,230,50),quit_game)

func read_json(file: String) -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://Data/"+file+".json"))
	if not parsed is Dictionary:
		push_error("Ungültige Datendatei: " + file)
		return {}
	return parsed

func configure_input() -> void:
	Controls.apply(key_bindings)

func key_label(action: String) -> String:
	return Controls.label(action,key_bindings)

func style(bg: Color, border := Color("344b60"), corner := 10) -> StyleBoxFlat:
	var key := bg.to_html()+border.to_html()+str(corner)
	if style_cache.has(key):
		return style_cache[key]
	var result := StyleBoxFlat.new()
	result.bg_color = bg
	result.border_color = border
	result.set_border_width_all(1)
	result.set_corner_radius_all(corner)
	result.content_margin_left = 16
	result.content_margin_right = 16
	style_cache[key] = result
	return result

func clear(container: Control) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func panel(rect: Rect2, bg := Color("152336"), edge := Color("344b60"), parent: Control = null) -> Panel:
	var p := Panel.new()
	p.position = rect.position
	p.size = rect.size
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_theme_stylebox_override("panel",style(bg,edge))
	(parent if parent!=null else ui).add_child(p)
	return p

func label_at(value: String, pos: Vector2, size := 18, color := Color("e9eef5"), parent: Control = null, use_mono := false) -> Label:
	var l := Label.new()
	l.text = value
	l.position = pos
	l.add_theme_font_override("font",mono if use_mono else font)
	l.add_theme_font_size_override("font_size",maxi(size,14))
	l.add_theme_color_override("font_color",color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	(parent if parent!=null else ui).add_child(l)
	return l

func button_at(value: String, rect: Rect2, callback: Callable, accent := false, parent: Control = null) -> Button:
	var b := Button.new()
	b.text = value
	b.position = rect.position
	b.size = rect.size
	b.focus_mode = Control.FOCUS_NONE
	b.clip_text=true
	b.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
	b.add_theme_font_override("font",font)
	b.add_theme_font_size_override("font_size",19)
	b.add_theme_color_override("font_color",Color("122b30") if accent else Color("e8eff6"))
	b.add_theme_color_override("font_hover_color",Color("122b30") if accent else Color.WHITE)
	b.add_theme_stylebox_override("normal",style(Color("78dfc0") if accent else Color("22374b"),Color("78dfc0") if accent else Color("456077")))
	b.add_theme_stylebox_override("hover",style(Color("a3f4d7") if accent else Color("34516a"),Color("8ce6cf")))
	b.add_theme_stylebox_override("pressed",style(Color("52b99f") if accent else Color("172d42"),Color("8ce6cf")))
	b.pressed.connect(callback)
	(parent if parent!=null else ui).add_child(b)
	return b

func portrait(id: String, rect: Rect2, parent: Control = null) -> TextureRect:
	var image := TextureRect.new()
	image.texture = Art.get_texture(id)
	image.position = rect.position
	image.size = rect.size
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	(parent if parent!=null else ui).add_child(image)
	return image

func set_backdrop() -> void:
	if is_instance_valid(arena_node):
		arena_node.queue_free()
	arena_node = Arena.new()
	arena_node.variant = arena_id
	arena_node.z_index = -100
	add_child(arena_node)
	update_music()

func reset_world() -> void:
	if is_instance_valid(world):
		if world.get_parent()==self:
			remove_child(world)
		world.queue_free()
	world = null
	fighters.clear()
	rocks.clear()
	teams = [[],[]]
	clear(ui)
	clear(modal)
	set_backdrop()

func show_menu() -> void:
	get_tree().paused=false
	process_mode=Node.PROCESS_MODE_INHERIT
	pending_rebind=""
	screen = "menu"
	reset_world()
	panel(Rect2(0,0,1280,720),Color(0.025,0.055,0.1,0.76),Color.TRANSPARENT)
	label_at("ARENA LAB    /    ECHTZEIT-KAMPF",Vector2(68,58),14,Color("8cddc9"),null,true)
	label_at("POKÉMON",Vector2(63,110),68)
	label_at("ARENA 2D",Vector2(63,181),68,Color("f5d287"))
	label_at("Freie Bewegung. Drei im Team. Dein nächster Zug.",Vector2(69,279),19,Color("b6c9d8"))
	label_at("TRAINER-LEVEL %d   ·   %d / %d EP" % [trainer_level,trainer_xp,trainer_level*150],Vector2(70,316),11,Color("8cddc9"),null,true)
	label_at("SIEGE %d  ·  KÄMPFE %d  ·  BESTSERIE %d" % [wins,total_matches,best_streak],Vector2(70,332),10,Color("a3b8c4"),null,true)
	button_at("KAMPF STARTEN   →",Rect2(70,341,350,56),func(): start_mode("arena"),true)
	button_at("Team & Arena",Rect2(70,410,350,49),show_team)
	button_at("Training",Rect2(70,471,105,47),func(): start_mode("training"))
	button_at("Steuerung",Rect2(183,471,112,47),show_help)
	button_at("Statistik",Rect2(303,471,117,47),show_stats)
	button_at("Einstellungen",Rect2(70,530,169,47),show_settings)
	button_at("Beenden",Rect2(251,530,169,47),quit_game)
	button_at("Boss-Archiv",Rect2(430,530,190,47),show_boss_select)
	panel(Rect2(650,169,548,377),Color(0.05,0.09,0.15,0.86),Color("4c626b"))
	label_at("DEIN STARTTEAM",Vector2(680,191),13,Color("98b5bf"),null,true)
	portrait(selected_team[0],Rect2(678,276,170,170))
	portrait(selected_team[2],Rect2(1000,276,170,170))
	portrait(selected_team[1],Rect2(822,231,206,206))
	for i in range(3):
		var id: String = selected_team[i]
		label_at(str(roster[id].name).to_upper(),Vector2(693+i*164,469),18,Color(roster[id].color))
		label_at(fighter_types(roster[id]),Vector2(693+i*164,494),13,Color("a6bbc8"),null,true)
	label_at("01 / " + arena_title().to_upper() + "    ·    3 GEGEN 3",Vector2(681,568),13,Color("a9c3cb"),null,true)
	label_at("EIGENSTÄNDIGER FAN-PROTOTYP  ·  8 RICHTUNGSZUSTÄNDE  ·  GODOT 4",Vector2(70,668),12,Color("8296a9"),null,true)

func show_story() -> void:
	game_mode="story"
	story_chapter=mini(story_completed,STORY.size()-1)
	screen="story"
	reset_world()
	var chapter: Dictionary=STORY[story_chapter]
	panel(Rect2(0,0,1280,720),Color(0.025,0.045,0.085,0.93),Color.TRANSPARENT)
	label_at("ARENA-CHRONIK",Vector2(85,68),16,Color("8cddc9"),null,true)
	label_at("KAPITEL %d / %d" % [story_chapter+1,STORY.size()],Vector2(85,116),14,Color("f5d287"),null,true)
	label_at(str(chapter.title).to_upper(),Vector2(82,150),43,Color.WHITE)
	label_at(str(chapter.scene).to_upper(),Vector2(85,208),13,Color("e0a86c"),null,true)
	var story_text:=label_at(str(chapter.text)+"\n\n"+str(chapter.lore),Vector2(85,240),17,Color("bfd0dc"))
	story_text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	story_text.custom_minimum_size=Vector2(600,132)
	panel(Rect2(85,386,600,112),Color("182d3d"),Color("456878"))
	label_at(str(chapter.trainer),Vector2(108,402),14,Color("8cddc9"),null,true)
	var line:=label_at(str(chapter.line),Vector2(108,428),16,Color("f4dfb0"))
	line.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	line.custom_minimum_size=Vector2(550,54)
	label_at("ZIEL  ·  "+str(chapter.objective),Vector2(85,523),14,Color("a9c9d1"),null,true)
	panel(Rect2(760,105,420,430),Color("13283a"),Color("54717d"))
	label_at("TRAINERBEGEGNUNG",Vector2(790,134),13,Color("8cddc9"),null,true)
	label_at(str(chapter.trainer),Vector2(790,160),18,Color("f5d287"))
	label_at("GEGNERTEAM",Vector2(790,185),11,Color("9fb4c2"),null,true)
	for i in range(3):
		var enemy_id: String=chapter.rival[i]
		portrait(enemy_id,Rect2(790+i*118,215,100,100))
		label_at(str(roster[enemy_id].name),Vector2(790+i*118,328),14,Color(roster[enemy_id].color))
	label_at(arena_display_name(str(chapter.arena)),Vector2(790,386),24,Color("f5d287"))
	label_at(str(chapter.reward),Vector2(790,425),14,Color("8cddc9"))
	label_at("Fortschritt wird nach jedem Kapitel gespeichert.",Vector2(790,468),13,Color("9fb4c2"))
	button_at("KAPITEL STARTEN  →",Rect2(85,570,510,58),start_story_battle,true)
	button_at("← Hauptmenü",Rect2(85,640,240,48),show_menu)

func show_boss_select() -> void:
	screen="boss_select"
	reset_world()
	panel(Rect2(0,0,1280,720),Color(0.025,0.045,0.085,0.94),Color.TRANSPARENT)
	label_at("BOSS-ARCHIV",Vector2(82,78),40,Color.WHITE)
	label_at("Wähle deinen Bossweg. Jede Route hat drei Prüfungen und einen eigenen Endgegner.",Vector2(85,130),17,Color("a9c4d0"))
	for i in range(BOSS_ROUTES.size()):
		var route: Dictionary=BOSS_ROUTES[i]
		var y:=188+i*82
		button_at("%s   ·   ENDGEGNER: %s" % [route.name,str(roster[route.boss].name).to_upper()],Rect2(85,y,670,60),func(): selected_boss=i; start_mode("boss"),i==selected_boss)
		label_at(str(route.text),Vector2(785,y+12),15,Color("bfd0dc"))
		label_at("ARENA  ·  "+arena_display_name(str(route.arena)),Vector2(785,y+38),12,Color("8cddc9"),null,true)
	button_at("← Hauptmenü",Rect2(85,590,240,48),show_menu)

func show_stats() -> void:
	screen="stats"
	reset_world()
	panel(Rect2(0,0,1280,720),Color(0.025,0.045,0.085,0.94),Color.TRANSPARENT)
	label_at("TRAINER-STATISTIK",Vector2(82,80),38,Color.WHITE)
	label_at("Deine gespeicherten Fortschritte",Vector2(85,132),17,Color("a9c4d0"))
	var rows:= [
		["SIEGE",str(wins)], ["NIEDERLAGEN",str(losses)], ["KÄMPFE GESAMT",str(total_matches)],
		["BESTE SERIE",str(best_streak)], ["TRAINER-LEVEL",str(trainer_level)], ["CHRONIK", "%d / %d KAPITEL" % [story_completed,STORY.size()]], ["POKÉMON FREI", "%d / %d" % [unlocked_creatures.size(),CREATURES.size()]]
	]
	for i in range(rows.size()):
		var y:=210+i*55
		panel(Rect2(85,y,480,43),Color("172b3c"),Color("315366"))
		label_at(rows[i][0],Vector2(105,y+10),14,Color("85dcc5"),null,true)
		label_at(rows[i][1],Vector2(390,y+7),22,Color("f5d287"))
	panel(Rect2(685,180,500,390),Color("13283a"),Color("54717d"))
	label_at("DEINE TEAMS",Vector2(720,215),15,Color("8cddc9"),null,true)
	for slot in range(team_presets.size()):
		label_at("TEAM %d%s" % [slot+1,"  · AKTIV" if slot==active_preset else ""],Vector2(720,270+slot*82),16,Color("f5d287") if slot==active_preset else Color("b5c9d8"))
		var names:=PackedStringArray()
		for id in team_presets[slot]: names.append(str(roster[id].name))
		label_at(" · ".join(names),Vector2(720,298+slot*82),15,Color("d4e0e5"))
	button_at("← Hauptmenü",Rect2(85,600,240,48),show_menu)

func start_story_battle() -> void:
	game_mode="story"
	start_fight(true)

func show_team() -> void:
	screen = "team"
	clear(ui)
	panel(Rect2(0,0,1280,720),Color(0.03,0.06,0.11,0.94),Color.TRANSPARENT)
	label_at("TEAMWERKSTATT",Vector2(48,30),36)
	label_at("Wähle einen Teamplatz, dann eine Kreatur. Drei verschiedene Kämpfer pro Team.",Vector2(50,80),17,Color("aabfce"))
	var search := LineEdit.new()
	search.position=Vector2(50,220)
	search.size=Vector2(430,38)
	search.placeholder_text="Pokémon suchen …"
	search.text=team_search
	search.add_theme_font_size_override("font_size",16)
	search.text_changed.connect(func(v): team_search=v; team_scroll=0; show_team())
	ui.add_child(search)
	button_at("▲",Rect2(492,220,42,38),func(): team_scroll=maxi(0,team_scroll-1); show_team())
	var max_team_page := maxi(0,ceili(float(CREATURES.size())/8.0)-1)
	button_at("▼",Rect2(538,220,42,38),func(): team_scroll=min(team_scroll+1,max_team_page); show_team())
	for i in range(3):
		var id: String = selected_team[i]
		var x := 50+i*255
		button_at("",Rect2(x,119,239,97),func(): selected_slot=i; show_team(),i==selected_slot)
		portrait(id,Rect2(x+5,126,83,83))
		label_at("TEAM %d" % (i+1),Vector2(x+94,134),11,Color("1d534b") if i==selected_slot else Color("94bac0"),null,true)
		label_at(roster[id].name,Vector2(x+94,157),24,Color("142d33") if i==selected_slot else Color.WHITE)
		label_at(fighter_types(roster[id]),Vector2(x+94,187),11,Color("325f57") if i==selected_slot else Color("b1c5d4"),null,true)
	var filtered: Array=[]
	for id in CREATURES:
		if fuzzy_match(str(roster[id].name),team_search): filtered.append(id)
	label_at("%d Treffer" % filtered.size(),Vector2(592,231),14,Color("9db5c5"),null,true)
	label_at("Freischaltung: %d Siege pro Pokémon · neue Pokémon einfach an UNLOCK_ORDER anhängen.",Vector2(50,258),14,Color("8fbaa9"))
	var page_start:=team_scroll*8
	for i in range(page_start,mini(page_start+8,filtered.size())):
		var id: String = filtered[i]
		var d: Dictionary = roster[id]
		var local_i:=i-page_start
		var x := 50+(local_i%4)*193
		var y := 270+(local_i/4)*94
		var unlocked:=is_unlocked(id)
		# Dunkle Karten behalten den Kontrast auch bei ausgewählten Pokémon.
		button_at("",Rect2(x,y,181,84),func(): choose_creature(id),false)
		var portrait_view:=portrait(id,Rect2(x+6,y+7,66,66))
		if not unlocked: portrait_view.modulate=Color("101820")
		label_at(d.name if unlocked else "???",Vector2(x+78,y+8),17,Color(d.color) if unlocked else Color("718394"))
		label_at(fighter_types(d) if unlocked else "GESPERRT",Vector2(x+78,y+34),12,Color("abc0d4") if unlocked else Color("718394"),null,true)
		label_at("IM TEAM" if selected_team.has(id) else ("WÄHLEN +" if unlocked else "🔒 FREISCHALTEN"),Vector2(x+78,y+56),11,Color("8ce2c5") if unlocked else Color("e7b56e"),null,true)
	panel(Rect2(842,119,386,461))
	label_at("ZUFÄLLIGE KAMPFUMGEBUNG",Vector2(866,140),13,Color("89d9c5"),null,true)
	label_at("9 komplett verschiedene Arenen werden",Vector2(866,173),15,Color("c5d3df"))
	label_at("vor jedem Kampf automatisch ausgelost.",Vector2(866,196),15,Color("c5d3df"))
	label_at("Vulkan · Wiese · Küste",Vector2(866,229),13,Color("f2c68f"),null,true)
	label_at("Kristallhöhle · Ruinen · Sturmspitze",Vector2(866,253),13,Color("9dcff1"),null,true)
	label_at("Spukschloss · Dschungel · Kraftwerk",Vector2(866,277),13,Color("c5a5e8"),null,true)
	label_at("Jede Arena hat eigene Wege und Boni.",Vector2(866,306),13,Color("8fdda0"),null,true)
	var chosen: Dictionary = roster[selected_team[selected_slot]]
	label_at(chosen.name + " / " + chosen.ability,Vector2(865,357),18,Color(chosen.color))
	label_at("KP %d   ANG %d   VERT %d   TEMPO %d" % [chosen.hp,chosen.attack,chosen.defense,chosen.speed],Vector2(865,382),11,Color("91a9b9"),null,true)
	var description := RichTextLabel.new()
	description.position = Vector2(865,404)
	description.size = Vector2(332,40)
	description.text = str(chosen.description)
	description.add_theme_font_override("normal_font",font)
	description.add_theme_font_size_override("normal_font_size",16)
	description.add_theme_color_override("default_color",Color("b6c9d7"))
	description.scroll_active = false
	description.mouse_filter = Control.MOUSE_FILTER_IGNORE
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui.add_child(description)
	for j in range(4):
		label_at("%d  %s" % [j+1,moves[chosen.moves[j]].name],Vector2(866,458+j*25),16,Color("d9e3ea"))
	button_at("← Hauptmenü",Rect2(50,633,239,48),show_menu)
	label_at("TEAM-SLOTS · ÄNDERUNGEN AUTO-GESPEICHERT",Vector2(842,592),11,Color("8cddc9"),null,true)
	for slot in range(3):
		button_at("TEAM %d%s" % [slot+1,"  ✓" if slot==active_preset else ""],Rect2(925+slot*101,582,96,38),func(): load_team_preset(slot),slot==active_preset)
	button_at("MIT DIESEM TEAM SPIELEN  →",Rect2(842,620,386,60),func(): start_mode("arena"),true)

func fuzzy_match(name: String, query: String) -> bool:
	if query.strip_edges().is_empty(): return true
	var n:=name.to_lower()
	var q:=query.strip_edges().to_lower()
	if n.contains(q): return true
	var at:=0
	for ch in q:
		at=n.find(ch,at)
		if at<0: return false
		at+=1
	return true

func choose_creature(id: String) -> void:
	if not is_unlocked(id): return
	var other := selected_team.find(id)
	if other>=0:
		selected_team[other] = selected_team[selected_slot]
	selected_team[selected_slot] = id
	team_presets[active_preset]=selected_team.duplicate()
	save_settings()
	show_team()

func is_unlocked(id: String) -> bool:
	return id in unlocked_creatures

func update_unlocks() -> void:
	# Langfristiger Fortschritt: neue Einträge können einfach an UNLOCK_ORDER angehängt werden.
	var target:=mini(UNLOCK_ORDER.size(),int(floor(float(wins)/float(WINS_PER_UNLOCK))))
	var rebuilt: Array=["pikachu","glurak","turtok"]
	for i in range(target):
		rebuilt.append(UNLOCK_ORDER[i])
	# Alte Spielstände werden auf die neue, langsamere Progression migriert.
	unlocked_creatures=rebuilt

func save_team_preset(slot: int) -> void:
	if slot<0 or slot>=team_presets.size(): return
	team_presets[slot]=selected_team.duplicate()
	active_preset=slot
	save_settings()
	show_team()

func load_team_preset(slot: int) -> void:
	if slot<0 or slot>=team_presets.size(): return
	var lineup: Array=team_presets[slot]
	if lineup.size()==3 and lineup.all(func(id): return id in CREATURES):
		selected_team=lineup.duplicate()
		active_preset=slot
		save_settings()
	show_team()

func show_help() -> void:
	screen = "help"
	clear(ui)
	panel(Rect2(70,55,1140,610),Color(0.05,0.09,0.15,0.97))
	label_at("BEWEGEN. ZIELEN. WECHSELN.",Vector2(106,84),34)
	label_at("TASTATUR & MAUS",Vector2(110,153),13,Color("78dfbf"),null,true)
	var rows := [["Bewegen","Pfeile / eigene Tasten"],["Zielen","automatisch"],["Attacke 1",key_label("attack0")+" / linke Maustaste"],["Attacke 2",key_label("attack1")+" / rechte Maustaste"],["Attacke 3",key_label("attack2")],["Spezialattacke",key_label("attack3")],["Ausweichen",key_label("dodge")],["Team wechseln",key_label("switch")+" / 1 / 2 / 3"],["Pause","Esc"],["KI an / aus","F2"]]
	for i in range(rows.size()):
		label_at(rows[i][0],Vector2(110,192+i*34),18,Color("a6bdcc"))
		label_at(rows[i][1],Vector2(325,192+i*34),18)
	label_at("GAMEPAD",Vector2(743,153),13,Color("78dfbf"),null,true)
	label_at("Linker Stick: bewegen\nRechter Stick: zielen\nA: ausweichen · B: wechseln\nX / Y / LB / RB: Attacken\nStart: Pause",Vector2(743,192),18)
	label_at("KAMPF-KOMFORT",Vector2(743,316),13,Color("78dfbf"),null,true)
	label_at("Pfeile, Maus und Gamepad sind aktiv.\nTouch-Geräte nutzen den virtuellen Stick.",Vector2(743,343),14,Color("b7cad9"))
	label_at("KAMPFTIPPS",Vector2(743,368),13,Color("f1cd84"),null,true)
	label_at("Donner kündigt den Einschlag an.\nVerlasse rechtzeitig den Zielkreis.\n\nNasse Ziele nehmen 25 % mehr\nElektroschaden. Eis verlangsamt.\n\nFelsen blockieren Schüsse und\nkönnen zerstört werden.",Vector2(743,404),17,Color("b7cad9"))
	button_at("← Zurück",Rect2(110,575,240,48),show_menu)

func show_settings() -> void:
	screen = "settings"
	clear(ui)
	panel(Rect2(56,44,1168,632),Color(0.05,0.09,0.15,0.98))
	label_at("EINSTELLUNGEN",Vector2(88,65),32)
	panel(Rect2(82,130,438,440),Color("192c3e"))
	panel(Rect2(544,130,650,440),Color("192c3e"))
	label_at("KI-REAKTION",Vector2(104,153),13,Color("85dcc5"),null,true)
	for i in range(3):
		button_at(["Leicht","Normal","Schwer"][i],Rect2(104+i*130,193,120,45),func(): difficulty=i; save_settings(); show_settings(),difficulty==i)
	label_at("Gleiche Werte für beide Seiten.\nDie Stufe verändert Reaktionszeit,\nAusweichen und Attackenwahl.",Vector2(104,265),17,Color("afc4d4"))
	label_at("EFFEKTE-LAUTSTÄRKE",Vector2(104,378),13,Color("85dcc5"),null,true)
	var slider := HSlider.new()
	slider.position = Vector2(104,422)
	slider.size = Vector2(390,25)
	slider.min_value = 0
	slider.max_value = 1
	slider.step = 0.05
	slider.value = sound_volume
	slider.value_changed.connect(func(value): sound_volume=value; update_audio_volume(); save_settings())
	ui.add_child(slider)
	button_at("Ton testen",Rect2(104,482,185,44),func(): play_sound("attack"))
	label_at("TASTENBELEGUNG",Vector2(568,153),13,Color("85dcc5"),null,true)
	label_at("Taste anklicken, dann eine neue Taste drücken.",Vector2(568,182),16,Color("afc4d4"))
	var actions := ["left","right","up","down","dodge","attack0","attack1","attack2","attack3","switch"]
	for i in range(actions.size()):
		var action: String = actions[i]
		var col := 0 if i<5 else 1
		var row := i%5
		var x := 568+col*312
		var y := 227+row*50
		label_at(Controls.NAMES[action],Vector2(x,y+7),17)
		button_at("…" if pending_rebind==action else key_label(action),Rect2(x+165,y,115,39),func(): pending_rebind=action; binding_message="Jetzt neue Taste drücken. Esc bricht ab."; show_settings(),pending_rebind==action)
	var message := binding_message if not binding_message.is_empty() else "Pfeile und Maus bleiben nutzbar. Esc pausiert immer."
	var note := label_at(message,Vector2(568,494),14,Color("f0ce91"))
	note.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	note.set_deferred("size",Vector2(592,55))
	button_at("← Zurück",Rect2(88,602,220,47),func(): pending_rebind=""; binding_message=""; show_menu())
	button_at("Standardtasten",Rect2(934,602,260,47),func(): key_bindings.clear(); configure_input(); save_settings(); pending_rebind=""; binding_message="Standardtasten wiederhergestellt."; show_settings())

func start_fight(enable_ai: bool) -> void:
	get_tree().paused=false
	process_mode=Node.PROCESS_MODE_INHERIT
	screen = "fight"
	if game_mode=="story": arena_id=str(STORY[story_chapter].arena)
	elif game_mode=="boss": arena_id=str(BOSS_ROUTES[selected_boss].arena)
	else: roll_random_arena()
	reset_world()
	ai_enabled = enable_ai
	ai_reaction = [1.65,1.0,0.65][difficulty]
	if game_mode=="tournament": ai_reaction*=maxf(0.62,1.0-float(tournament_round-1)*0.14)
	elif game_mode=="survival": ai_reaction*=maxf(0.58,1.0-float(survival_wave-1)*0.1)
	elapsed = 0
	feedback_text=""
	feedback_until=0
	hazard_timer=6.0
	switch_cooldown = 0
	active_indices = [0,0]
	mouse_aim = false
	world = Node2D.new()
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(world)
	for p in arena_rock_positions():
		var rock := Rock.new()
		rock.position = p
		rock.game = self
		world.add_child(rock)
		rocks.append(rock)
	var rival: Array = ["gengar","sichlor","lapras"]
	if enable_ai:
		if game_mode=="boss":
			var boss_route: Dictionary=BOSS_ROUTES[selected_boss]
			rival=boss_route.teams[clampi(boss_round-1,0,boss_route.teams.size()-1)].duplicate()
			if boss_round>=4: rival[0]=str(boss_route.boss)
		elif game_mode=="story": rival=STORY[story_chapter].rival.duplicate()
		else: rival=random_rival_team()
	last_rival_team = rival.duplicate()
	for side in range(2):
		var lineup: Array = selected_team if side==0 else rival
		for id in lineup:
			var fighter := Fighter.new()
			fighter.setup(str(id),roster[id],self,side)
			fighter.ai = side==1 and ai_enabled
			world.add_child(fighter)
			teams[side].append(fighter)
			fighters.append(fighter)
			if side==1 and game_mode=="boss": fighter.power_multiplier=1.15+float(boss_round-1)*0.1
			elif side==1 and game_mode=="tournament": fighter.power_multiplier=1.0+float(tournament_round-1)*0.08
			elif side==1 and game_mode=="survival": fighter.power_multiplier=1.0+float(survival_wave-1)*0.06
			elif side==0: fighter.power_multiplier=1.0+minf(0.2,float(trainer_level-1)*0.01)
			if side==0 and game_mode=="survival" and survival_hp.has(id): fighter.hp=minf(float(fighter.data.hp),float(survival_hp[id]))
		var first = teams[side][0]
		first.position = Vector2(300 if side==0 else 980,390)
		first.aim = Vector2.RIGHT if side==0 else Vector2.LEFT
		first.set_active(true)
		effect(first.position+Vector2(0,-25),Color(first.data.color),"switch",48,"normal")
	hud = BattleHUD.new()
	hud.game = self
	hud.size = Vector2(1280,720)
	ui.add_child(hud)
	add_touch_controls()
	intro = label_at("BEREIT?",Vector2(545,300),48,Color("ffe0a0"))

func start_mode(mode: String) -> void:
	game_mode=mode
	if mode=="tournament": tournament_round=1
	if mode=="boss": boss_round=1
	if mode=="survival":
		survival_wave=1
		survival_hp.clear()
	start_fight(mode!="training")

func get_active(side: int):
	if teams[side].is_empty():
		return null
	return teams[side][active_indices[side]]

func random_rival_team() -> Array:
	var pool: Array = CREATURES.duplicate()
	var result: Array = []
	for attempt in range(12):
		pool = CREATURES.duplicate()
		result = []
		for i in range(3):
			var index := combat_rng.randi_range(0,pool.size()-1)
			result.append(pool.pop_at(index))
		var old_team: Array=last_rival_team.duplicate()
		result.sort()
		old_team.sort()
		if result!=old_team or last_rival_team.is_empty():
			return result
	return result

func get_opponent(side: int):
	return get_active(1-side)

func switch_team(side: int, slot := -1, forced := false) -> bool:
	if not forced and (switch_cooldown>0 or screen!="fight"):
		if side==0 and screen=="fight":
			feedback("Teamwechsel · noch %.1f s" % switch_cooldown)
		return false
	var current = get_active(side)
	if current == null:
		return false
	if not forced and (current.stun>0 or current.statuses.has("sleep") or current.dodge>0 or current.dash_time>0):
		return false
	if slot<0:
		for offset in range(1,4):
			var candidate: int = (active_indices[side]+offset)%3
			if teams[side][candidate].hp>0:
				slot = candidate
				break
	if slot<0 or slot==active_indices[side] or teams[side][slot].hp<=0:
		return false
	var point: Vector2 = current.position
	var direction: Vector2 = current.aim
	current.set_active(false)
	active_indices[side] = slot
	var next = get_active(side)
	next.position = point
	next.aim = direction
	next.aim_mode = current.aim_mode
	next.stun = 0
	next.set_active(true)
	if side==0:
		switch_cooldown = 2.0
	effect(point+Vector2(0,-25),Color(next.data.color),"switch",60,"normal")
	play_sound("switch")
	return true

func spawn_attack(source, move: Dictionary) -> void:
	var aim_at: Vector2 = source.position+source.aim*minf(350,float(move.range))
	if is_instance_valid(source.target):
		aim_at = source.position+(source.target.position-source.position).limit_length(float(move.range))
	aim_at = aim_at.clamp(bounds.position,bounds.end)
	var shot := Attack.new()
	shot.configure(source,move,aim_at)
	world.add_child(shot)
	effect(source.position+Vector2(0,-23),Color(move.color),"cast",24+float(move.radius)*0.35,str(move.type))
	play_sound("water" if move.type=="water" else ("fire" if move.type=="fire" else "attack"))

func effect(point: Vector2, tint: Color, kind: String, radius: float, element := "normal") -> void:
	if not is_instance_valid(world):
		return
	var e := Burst.new()
	e.position = point
	e.tint = tint
	e.kind = kind
	e.radius = radius
	e.game = self
	e.element = element
	world.add_child(e)

func show_damage(point: Vector2, amount: int, tint := Color.WHITE) -> void:
	var l := Label.new()
	l.text = str(amount)
	l.position = point
	l.z_index = 1000
	l.add_theme_font_override("font",mono)
	l.add_theme_font_size_override("font_size",22)
	l.add_theme_color_override("font_color",Color("fff4cc"))
	l.add_theme_color_override("font_shadow_color",Color("152238"))
	l.add_theme_constant_override("shadow_offset_x",2)
	l.add_theme_constant_override("shadow_offset_y",2)
	world.add_child(l)
	var tween := l.create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(l,"position:y",point.y-35,0.6)
	tween.parallel().tween_property(l,"modulate:a",0.0,0.6)
	tween.tween_callback(l.queue_free)

func _input(event: InputEvent) -> void:
	if screen=="fight" and event is InputEventScreenTouch:
		if event.pressed and event.position.y>=626:
			for slot in range(5):
				if Rect2(143+slot*219,626,208,59).has_point(event.position):
					if slot==0: get_active(0).try_dodge(touch_move)
					else: get_active(0).attack(slot-1)
					break
			get_viewport().set_input_as_handled()
		elif event.pressed and event.position.y>=128 and event.position.y<=187 and event.position.x<234:
			for slot in range(3):
				if Rect2(24+slot*70,128,62,59).has_point(event.position): switch_team(0,slot)
			get_viewport().set_input_as_handled()
		elif event.pressed and event.position.x<480 and event.position.y>300 and touch_finger<0:
			touch_finger=event.index
			touch_origin=event.position
			touch_move=Vector2.ZERO
			get_viewport().set_input_as_handled()
		elif not event.pressed and event.index==touch_finger:
			touch_finger=-1
			touch_move=Vector2.ZERO
			get_viewport().set_input_as_handled()
		elif event.pressed and event.position.x>=480 and bounds.has_point(event.position):
			touch_aim_finger=event.index
			aim_point=event.position
			mouse_aim=true
			get_viewport().set_input_as_handled()
		elif not event.pressed and event.index==touch_aim_finger:
			touch_aim_finger=-1
			get_active(0).attack(0)
			get_viewport().set_input_as_handled()
	if screen=="fight" and event is InputEventScreenDrag:
		if event.index==touch_finger:
			touch_move=(event.position-touch_origin).limit_length(70.0)/70.0
			get_viewport().set_input_as_handled()
		elif event.index==touch_aim_finger:
			aim_point=event.position.clamp(bounds.position,bounds.end)
			mouse_aim=true
			get_viewport().set_input_as_handled()
	if not pending_rebind.is_empty() and event is InputEventKey and event.pressed and not event.echo:
		var code: int = event.physical_keycode if event.physical_keycode!=0 else event.keycode
		if code==KEY_ESCAPE:
			pending_rebind=""
			binding_message="Tastenänderung abgebrochen."
		else:
			var issue := Controls.conflict(pending_rebind,code,key_bindings)
			if issue.is_empty():
				key_bindings[pending_rebind]=code
				configure_input()
				save_settings()
				pending_rebind=""
				binding_message="Taste gespeichert."
			else:
				binding_message=issue
		show_settings()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseMotion:
		mouse_aim = false
	if event is InputEventJoypadButton and event.pressed and event.button_index==JOY_BUTTON_START:
		if screen=="fight":
			pause_game()
		elif screen=="pause":
			resume()
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode==KEY_ESCAPE:
			if screen=="data_error":
				quit_game()
				return
			if screen=="fight":
				pause_game()
			elif screen=="pause":
				resume()
			elif screen!="menu":
				show_menu()
		if event.keycode==KEY_F2 and screen=="fight":
			ai_enabled = not ai_enabled
			for fighter in teams[1]:
				fighter.ai = ai_enabled
		if screen=="fight" and event.keycode in [KEY_1,KEY_2,KEY_3]:
			switch_team(0,event.keycode-KEY_1)
	if screen=="fight" and event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
		if event.position.y>=626 and event.position.y<=685:
			for slot in range(5):
				if Rect2(143+slot*219,626,208,59).has_point(event.position):
					if slot==0:
						get_active(0).try_dodge()
					else:
						get_active(0).attack(slot-1)
					break
			get_viewport().set_input_as_handled()
		if event.position.y>=128 and event.position.y<=187 and event.position.x>=24 and event.position.x<234:
			for slot in range(3):
				if Rect2(24+slot*70,128,62,59).has_point(event.position):
					switch_team(0,slot)
					break
			get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if screen=="fight" and event is InputEventMouseButton and event.pressed and bounds.has_point(event.position):
		if event.button_index in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_RIGHT]:
			get_active(0).attack(0 if event.button_index==MOUSE_BUTTON_LEFT else 1)
			get_viewport().set_input_as_handled()

func feedback(text: String) -> void:
	feedback_text=text
	feedback_until=elapsed+1.2

func pause_game() -> void:
	if screen!="fight":
		return
	screen = "pause"
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel(Rect2(0,0,1280,720),Color(0.02,0.04,0.08,0.8),Color.TRANSPARENT,modal)
	panel(Rect2(420,215,440,280),Color("152637"),Color("476478"),modal)
	label_at("PAUSE",Vector2(553,246),40,Color.WHITE,modal)
	button_at("Fortsetzen",Rect2(465,322,350,52),resume,true,modal)
	button_at("Hauptmenü",Rect2(465,392,350,48),func(): get_tree().paused=false; process_mode=Node.PROCESS_MODE_INHERIT; show_menu(),false,modal)

func resume() -> void:
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_INHERIT
	screen = "fight"
	clear(modal)

func _process(dt: float) -> void:
	world_time += dt
	if screen!="fight":
		return
	if is_instance_valid(intro):
		intro.text = "LOS!" if elapsed>0.5 else "BEREIT?"
		intro.modulate.a = maxf(0,1-(elapsed-0.9)*4)
		if elapsed>1.2:
			intro.queue_free()
	shake = maxf(0,shake-dt*20)
	camera.offset = Vector2(visual_rng.randf_range(-shake,shake),visual_rng.randf_range(-shake,shake)) if shake>0 else Vector2.ZERO

func _physics_process(dt: float) -> void:
	if screen!="fight":
		return
	elapsed+=dt
	switch_cooldown=maxf(0,switch_cooldown-dt)
	hazard_timer-=dt
	if hazard_timer<=0:
		hazard_timer=7.0
		trigger_arena_event()
	if Input.is_action_just_pressed("switch"):
		switch_team(0)
	for side in range(2):
		var active = get_active(side)
		if active!=null and active.hp<=0:
			effect(active.position+Vector2(0,-25),Color(active.data.color),"attack_hit",72,"normal")
			shake=maxf(shake,7)
			var living := false
			for fighter in teams[side]:
				if fighter.hp>0:
					living = true
			if not living:
				finish(side==1)
				return
			switch_team(side,-1,true)

func hazard_damage(fighter, amount: float, element: String) -> void:
	if not is_instance_valid(fighter) or fighter.hp<=0:
		return
	var lost: float = fighter.apply_damage(amount)
	show_damage(fighter.position+Vector2(0,-70),int(lost),Color("f2d39a"))
	effect(fighter.position+Vector2(0,-20),Color("f2d39a"),"attack_hit",38,element)

func trigger_arena_event() -> void:
	var active_fighters := [get_active(0),get_active(1)]
	match arena_id:
		"volcano":
			feedback("Lavakessel · Hitzewelle!")
			for fighter in active_fighters:
				if not has_arena_affinity(fighter): hazard_damage(fighter,5,"fire")
		"meadow":
			feedback("Blütenpfad · Naturkraft heilt passende Typen.")
			for fighter in active_fighters:
				if has_arena_affinity(fighter): fighter.hp=minf(float(fighter.data.hp),fighter.hp+6)
		"coast":
			feedback("Korallenstrand · Eine Welle macht alle nass.")
			for fighter in active_fighters:
				if is_instance_valid(fighter): fighter.statuses["wet"]=2.5
		"crystal":
			feedback("Kristallhöhle · Frostimpuls!")
			for fighter in active_fighters:
				if not has_arena_affinity(fighter): fighter.statuses["slow"]=1.4
		"ruins":
			feedback("Sonnenruinen · Alte Energie erwacht.")
			for fighter in active_fighters:
				if is_instance_valid(fighter): fighter.energy=minf(100,fighter.energy+10)
		"storm":
			feedback("Sturmspitze · Blitzentladung!")
			for fighter in active_fighters:
				if not has_arena_affinity(fighter): hazard_damage(fighter,6,"electric")
		"haunted":
			feedback("Spukschloss · Schatten rauben Energie.")
			for fighter in active_fighters:
				if is_instance_valid(fighter) and not has_arena_affinity(fighter): fighter.energy=maxf(0,fighter.energy-10)
		"jungle":
			feedback("Urwaldring · Regeneration!")
			for fighter in active_fighters:
				if has_arena_affinity(fighter): fighter.hp=minf(float(fighter.data.hp),fighter.hp+8)
		"factory":
			feedback("Impulskraftwerk · Energieschub!")
			for fighter in active_fighters:
				if has_arena_affinity(fighter): fighter.energy=minf(100,fighter.energy+14)

func finish(won: bool) -> void:
	screen = "result"
	total_matches+=1
	if won:
		wins+=1
		current_streak+=1
		best_streak=maxi(best_streak,current_streak)
	else:
		losses+=1
		current_streak=0
	if won: award_progress()
	if won:
		update_unlocks()
	if won and game_mode=="survival":
		for fighter in teams[0]: survival_hp[fighter.id]=maxf(1,fighter.hp)
	if won and game_mode=="story":
		story_completed=maxi(story_completed,story_chapter+1)
		save_settings()
	camera.offset = Vector2.ZERO
	total_hits = 0
	total_damage = 0.0
	for fighter in teams[0]:
		total_hits += fighter.hits
		total_damage += fighter.damage_done
	clear(ui)
	panel(Rect2(0,0,1280,720),Color(0.02,0.05,0.1,0.86),Color.TRANSPARENT)
	panel(Rect2(336,134,608,467),Color("17283b"),Color("567275"))
	label_at("KAMPF ABGESCHLOSSEN",Vector2(505,162),13,Color("8edac6"),null,true)
	var result_heading := "DEIN TEAM GEWINNT" if won else "NIEDERLAGE"
	if won and game_mode=="boss": result_heading="BOSS-RUNDE %d GESCHAFFT" % boss_round if boss_round<4 else "%s BESIEGT" % str(roster[BOSS_ROUTES[selected_boss].boss].name).to_upper()
	elif won and game_mode=="tournament": result_heading="TURNIERSIEG" if tournament_round>=3 else "RUNDE %d GEWONNEN" % tournament_round
	elif won and game_mode=="survival": result_heading="ÜBERLEBEN GESCHAFFT" if survival_wave>=5 else "WELLE %d GESCHAFFT" % survival_wave
	elif won and game_mode=="story": result_heading="CHRONIK VOLLENDET" if story_chapter>=STORY.size()-1 else "KAPITEL %d GESCHAFFT" % (story_chapter+1)
	var heading := label_at(result_heading,Vector2(368,208),42,Color("f6d48e") if won else Color("f1a7b2"))
	heading.custom_minimum_size=Vector2(544,58)
	heading.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	var subtitle := label_at("Alle gegnerischen Kreaturen besiegt." if won else "Das gegnerische Team gewinnt. Revanche?",Vector2(368,268),17,Color("b5c9d8"))
	subtitle.custom_minimum_size=Vector2(544,24)
	subtitle.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	for i in range(3):
		var image := portrait(selected_team[i],Rect2(460+i*103,293,92,92))
		var fighter = teams[0][i]
		image.modulate.a=1.0 if fighter.hp>0 else 0.3
		label_at(("%d KP" % ceili(fighter.hp)) if fighter.hp>0 else "KO",Vector2(485+i*103,384),11,Color("9ecfbe") if fighter.hp>0 else Color("da9fa8"),null,true)
	label_at("%d TREFFER    %.1f SCHADEN    %d SEKUNDEN" % [total_hits,total_damage,int(elapsed)],Vector2(387,409),16,Color("b3c9d9"),null,true)
	label_at("SIEGE %d  ·  NIEDERLAGEN %d  ·  SERIE %d" % [wins,losses,current_streak],Vector2(450,435),12,Color("9eb6c6"),null,true)
	if won and game_mode=="tournament" and tournament_round<3:
		button_at("Nächste Runde",Rect2(389,470,242,53),continue_tournament,true)
	elif won and game_mode=="boss" and boss_round<4:
		button_at("Nächste Boss-Runde",Rect2(389,470,242,53),continue_boss,true)
	elif won and game_mode=="survival" and survival_wave<5:
		button_at("Nächste Welle",Rect2(389,470,242,53),continue_survival,true)
	elif won and game_mode=="story" and story_chapter<STORY.size()-1:
		button_at("Nächstes Kapitel",Rect2(389,470,242,53),continue_story,true)
	else:
		button_at("Revanche",Rect2(389,470,242,53),func(): start_fight(ai_enabled),true)
	button_at("Team ändern",Rect2(648,470,242,53),show_team)
	button_at("Hauptmenü",Rect2(513,541,252,39),show_menu)
	play_sound("win")

func continue_tournament() -> void:
	tournament_round+=1
	start_fight(true)

func continue_boss() -> void:
	boss_round+=1
	start_fight(true)

func continue_survival() -> void:
	survival_wave+=1
	start_fight(true)

func continue_story() -> void:
	story_chapter+=1
	show_story()

func award_progress() -> void:
	trainer_xp += 180 if game_mode=="boss" else (130 if game_mode in ["tournament","survival"] else 100)
	while trainer_xp>=trainer_level*150:
		trainer_xp-=trainer_level*150
		trainer_level+=1
	save_settings()

func type_name(type: String) -> String:
	return {"electric":"ELEKTRO","fire":"FEUER","water":"WASSER","ghost":"GEIST","ice":"EIS","bug":"KÄFER","normal":"NORMAL","flying":"FLUG","poison":"GIFT","grass":"PFLANZE","fighting":"KAMPF","steel":"STAHL","psychic":"PSYCHO","dark":"UNLICHT","rock":"GESTEIN","dragon":"DRACHE","ground":"BODEN","fairy":"FEE"}.get(type,type.to_upper())

func fighter_types(data: Dictionary) -> String:
	var names := PackedStringArray()
	for type in data.get("types",[data.type]):
		names.append(type_name(str(type)))
	return "/".join(names)

func arena_title() -> String:
	return arena_display_name(arena_id)

func arena_display_name(id: String) -> String:
	return {"volcano":"Lavakessel","meadow":"Blütenpfad","coast":"Korallenstrand","crystal":"Kristallhöhle","ruins":"Sonnenruinen","storm":"Sturmspitze","haunted":"Spukschloss","jungle":"Urwaldring","factory":"Impulskraftwerk"}.get(id,id)

func roll_random_arena() -> String:
	arena_id = ARENAS[combat_rng.randi_range(0,ARENAS.size()-1)]
	return arena_id

func arena_rock_positions() -> Array:
	match arena_id:
		"meadow":
			return [Vector2(365,275),Vector2(640,455),Vector2(915,275)]
		"coast":
			return [Vector2(340,255),Vector2(940,255),Vector2(450,505),Vector2(830,505)]
		"crystal":
			return [Vector2(465,260),Vector2(815,260),Vector2(465,505),Vector2(815,505),Vector2(640,382)]
		"ruins":
			return [Vector2(270,260),Vector2(505,345),Vector2(775,425),Vector2(1010,505)]
		"storm":
			return [Vector2(380,382),Vector2(640,260),Vector2(640,505),Vector2(900,382)]
		"haunted":
			return [Vector2(320,270),Vector2(520,465),Vector2(760,295),Vector2(960,485)]
		"jungle":
			return [Vector2(330,250),Vector2(330,515),Vector2(640,382),Vector2(950,250),Vector2(950,515)]
		"factory":
			return [Vector2(430,290),Vector2(640,470),Vector2(850,290)]
		_:
			return [Vector2(420,303),Vector2(873,465),Vector2(682,238),Vector2(580,521)]

func has_arena_affinity(fighter) -> bool:
	if fighter == null:
		return false
	for type in fighter.data.get("types",[fighter.data.type]):
		if type in ARENA_TYPES.get(arena_id,[]):
			return true
	return false

func arena_modifier(fighter, stat: String) -> float:
	var value: float = float({"speed":1.10,"energy":1.20}.get(stat,1.0)) if has_arena_affinity(fighter) else 1.0
	# Terrain zones change actual movement, not just the background.
	if stat=="speed" and is_instance_valid(fighter):
		var types_here: Array=fighter.data.get("types",[fighter.data.type])
		if arena_id=="coast" and fighter.position.y>410:
			value*=1.12 if "water" in types_here else 0.72
		elif arena_id=="volcano" and fighter.position.y<285 and "fire" not in types_here:
			value*=0.82
		elif arena_id=="jungle" and fighter.position.x>520 and fighter.position.x<760 and "grass" not in types_here:
			value*=0.84
	return value

func add_touch_controls() -> void:
	if not DisplayServer.is_touchscreen_available(): return
	var hint:=label_at("◯ HALTEN: BEWEGEN",Vector2(42,548),13,Color(0.75,0.9,1.0,0.78))
	hint.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var attack_hint:=label_at("WISCHEN + LOSLASSEN: ANGRIFF",Vector2(835,548),12,Color(1.0,0.85,0.55,0.78))
	attack_hint.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var action_hint:=label_at("UNTEN: ATTACKEN · AUSWEICHEN",Vector2(480,694),12,Color(0.82,0.9,1.0,0.68))
	action_hint.mouse_filter=Control.MOUSE_FILTER_IGNORE

func mark_terrain(point: Vector2, element: String, mark_size: float) -> void:
	if not is_instance_valid(world): return
	var mark:=TerrainMark.new()
	mark.position=point
	mark.size=clampf(mark_size,18,52)
	mark.tint={"fire":Color("612d24"),"electric":Color("695f2a"),"ice":Color("497284"),"water":Color("285670"),"dark":Color("372745"),"ghost":Color("423252"),"grass":Color("315d37")}.get(element,Color("3a3540"))
	world.add_child(mark)

func arena_move_modifier(move_type: String, stat: String) -> float:
	if move_type not in ARENA_TYPES.get(arena_id,[]):
		return 1.0
	return {"power":1.12,"speed":1.10,"size":1.12}.get(stat,1.0)

func arena_rule_text() -> String:
	return {"volcano":"BONUS: FEUER · GESTEIN · BODEN","meadow":"BONUS: PFLANZE · KÄFER · FEE","coast":"BONUS: WASSER · EIS · ELEKTRO","crystal":"BONUS: EIS · PSYCHO · STAHL","ruins":"BONUS: KAMPF · GEIST · NORMAL","storm":"BONUS: ELEKTRO · FLUG · DRACHE","haunted":"BONUS: GEIST · UNLICHT · PSYCHO","jungle":"BONUS: PFLANZE · GIFT · KÄFER","factory":"BONUS: STAHL · ELEKTRO · KAMPF"}.get(arena_id,"")

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH)==OK:
		var lineup = config.get_value("game","team",selected_team)
		if lineup is Array and lineup.size()==3 and lineup.all(func(id): return id in CREATURES) and lineup[0]!=lineup[1] and lineup[1]!=lineup[2] and lineup[0]!=lineup[2]:
			selected_team = lineup
		var saved_presets = config.get_value("game","team_presets",team_presets)
		if saved_presets is Array and saved_presets.size()==3:
			for i in range(3):
				if saved_presets[i] is Array and saved_presets[i].size()==3 and saved_presets[i].all(func(id): return id in CREATURES): team_presets[i]=saved_presets[i]
		active_preset=clampi(int(setting_number(config,"game","active_preset",0)),0,2)
		var arena = str(config.get_value("game","arena","volcano"))
		arena_id = arena if arena in ARENAS else "volcano"
		difficulty = clampi(int(setting_number(config,"game","difficulty",1)),0,2)
		trainer_level=maxi(1,int(setting_number(config,"progress","level",1)))
		trainer_xp=maxi(0,int(setting_number(config,"progress","xp",0)))
		story_completed=clampi(int(setting_number(config,"progress","story_completed",0)),0,STORY.size())
		var saved_unlocks = config.get_value("progress","unlocked_creatures",unlocked_creatures)
		if saved_unlocks is Array:
			unlocked_creatures=["pikachu","glurak","turtok"]
			for id in saved_unlocks:
				if id in CREATURES and id not in unlocked_creatures: unlocked_creatures.append(id)
		update_unlocks()
		wins=maxi(0,int(setting_number(config,"progress","wins",0)))
		losses=maxi(0,int(setting_number(config,"progress","losses",0)))
		total_matches=maxi(0,int(setting_number(config,"progress","matches",0)))
		best_streak=maxi(0,int(setting_number(config,"progress","best_streak",0)))
		sound_volume = clampf(setting_number(config,"audio","volume",0.35),0,1)
		var saved_keys = config.get_value("input","keys",{})
		if saved_keys is Dictionary:
			for action in Controls.DEFAULTS:
				var code = saved_keys.get(action)
				if code is int and Controls.conflict(action,code,saved_keys).is_empty():
					key_bindings[action]=code

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("game","team",selected_team)
	config.set_value("game","team_presets",team_presets)
	config.set_value("game","active_preset",active_preset)
	config.set_value("game","arena",arena_id)
	config.set_value("game","difficulty",difficulty)
	config.set_value("progress","level",trainer_level)
	config.set_value("progress","xp",trainer_xp)
	config.set_value("progress","story_completed",story_completed)
	config.set_value("progress","unlocked_creatures",unlocked_creatures)
	config.set_value("progress","wins",wins)
	config.set_value("progress","losses",losses)
	config.set_value("progress","matches",total_matches)
	config.set_value("progress","best_streak",best_streak)
	config.set_value("audio","volume",sound_volume)
	config.set_value("input","keys",key_bindings)
	config.save(SAVE_PATH)

func setting_number(config: ConfigFile, section: String, key: String, fallback: float) -> float:
	var value = config.get_value(section,key,fallback)
	if (value is int or value is float) and is_finite(float(value)):
		return float(value)
	return fallback

func prepare_sounds() -> void:
	var sound_rng := RandomNumberGenerator.new()
	sound_rng.seed=54879
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_pool.append(audio_player)
	for i in range(7):
		var voice := AudioStreamPlayer.new()
		add_child(voice)
		audio_pool.append(voice)
	for sound in ["attack","hit","dodge","thunder","fire","water","impact","switch","win"]:
		var stream := AudioStreamWAV.new()
		stream.format = AudioStreamWAV.FORMAT_16_BITS
		stream.mix_rate = 22050
		var duration := 0.4 if sound in ["thunder","win"] else 0.14
		var samples := PackedByteArray()
		var frequency := float({"attack":780,"hit":150,"dodge":420,"thunder":65,"fire":110,"water":600,"impact":85,"switch":950,"win":660}[sound])
		for i in range(int(22050*duration)):
			var t := i/22050.0
			var progress := t/duration
			var pitch := frequency*(1-progress*0.4)
			var wave := sin(t*pitch*TAU)
			if sound in ["thunder","hit","fire","water"]:
				wave = wave*0.3 + sound_rng.randf_range(-1,1)*0.7
			var sample := int(wave*(1-progress)*(1-progress)*6000)
			samples.append(sample & 255)
			samples.append((sample >> 8) & 255)
		stream.data = samples
		sounds[sound] = stream
	prepare_music()

func prepare_music() -> void:
	music_player=AudioStreamPlayer.new()
	add_child(music_player)
	var roots := {"volcano":110.0,"meadow":146.8,"coast":130.8,"crystal":164.8,"ruins":98.0,"storm":123.5,"haunted":82.4,"jungle":138.6,"factory":185.0}
	for arena in ARENAS:
		var stream:=AudioStreamWAV.new()
		stream.format=AudioStreamWAV.FORMAT_16_BITS
		stream.mix_rate=22050
		stream.loop_mode=AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin=0
		stream.loop_end=88200
		var samples:=PackedByteArray()
		var root_note: float=roots[arena]
		var pattern := [1.0,1.25,1.5,2.0,1.5,1.25,1.125,1.5]
		for i in range(88200):
			var t:=i/22050.0
			var step:=mini(7,int(t/0.5))
			var freq: float=root_note*float(pattern[step])
			var pulse:=1.0 if fmod(t*freq,1.0)<0.42 else -1.0
			var bass:=sin(t*root_note*0.5*TAU)
			var beat:=exp(-fmod(t,0.5)*12.0)*sin(t*55*TAU)
			var sample:=int((pulse*0.22+bass*0.25+beat*0.18)*2600)
			samples.append(sample&255); samples.append((sample>>8)&255)
		stream.data=samples
		music_streams[arena]=stream

func update_music() -> void:
	if not is_instance_valid(music_player) or not music_streams.has(arena_id): return
	if music_player.stream!=music_streams[arena_id]:
		music_player.stream=music_streams[arena_id]
		music_player.volume_db=linear_to_db(maxf(0.0001,sound_volume*0.22))
		music_player.play()

func play_sound(sound: String) -> void:
	if sound_volume<=0 or not sounds.has(sound):
		return
	var voice: AudioStreamPlayer = audio_pool[audio_cursor]
	for available in audio_pool:
		if not available.playing:
			voice=available
			break
	audio_cursor=(audio_cursor+1)%audio_pool.size()
	voice.stream = sounds[sound]
	voice.volume_db = linear_to_db(sound_volume)
	voice.play()

func update_audio_volume() -> void:
	for voice in audio_pool:
		voice.volume_db=linear_to_db(maxf(0.0001,sound_volume))
	if is_instance_valid(music_player): music_player.volume_db=linear_to_db(maxf(0.0001,sound_volume*0.22))

func stop_audio() -> void:
	for voice in audio_pool:
		if is_instance_valid(voice):
			voice.stop()
			voice.stream=null
	if is_instance_valid(music_player): music_player.stop()

func _exit_tree() -> void:
	stop_audio()
	sounds.clear()

func _notification(what: int) -> void:
	if what==NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game()
	elif what==NOTIFICATION_WM_WINDOW_FOCUS_OUT and screen=="fight" and focus_pause_enabled:
		pause_game()

func quit_game() -> void:
	if is_quitting:
		return
	is_quitting=true
	screen="closing"
	stop_audio()
	await get_tree().create_timer(0.1,true).timeout
	get_tree().quit()


