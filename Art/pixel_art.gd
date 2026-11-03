extends RefCounted
## Directional overworld sprites use the project PNGs in Art/Sprites.
## The procedural drawings below remain as a safe fallback.
static var cache: Dictionary = {}
const INK = Color("182338")

static func rect(im: Image, x: int, y: int, w: int, h: int, c: Color) -> void:
	im.fill_rect(Rect2i(x,y,w,h).intersection(Rect2i(0,0,72,72)),c)

static func oval(im: Image, x: int, y: int, rx: int, ry: int, c: Color) -> void:
	for py in range(maxi(0,y-ry),mini(72,y+ry+1)):
		for px in range(maxi(0,x-rx),mini(72,x+rx+1)):
			if pow(float(px-x)/maxi(1,rx),2)+pow(float(py-y)/maxi(1,ry),2) <= 1:
				im.set_pixel(px,py,c)

static func poly(im: Image, points: Array, c: Color) -> void:
	var polygon := PackedVector2Array()
	for p in points:
		polygon.append(Vector2(p[0],p[1]))
	var bounds := Rect2(polygon[0], Vector2.ZERO)
	for p in polygon:
		bounds = bounds.expand(p)
	for y in range(maxi(0,int(bounds.position.y)),mini(72,int(bounds.end.y)+1)):
		for x in range(maxi(0,int(bounds.position.x)),mini(72,int(bounds.end.x)+1)):
			if Geometry2D.is_point_in_polygon(Vector2(x,y),polygon):
				im.set_pixel(x,y,c)

static func eye(im: Image, x: int, y: int, evil := false) -> void:
	oval(im,x,y,3,4,INK)
	rect(im,x,y-2,2,2,Color.WHITE)
	if evil:
		rect(im,x-2,y-4,6,2,Color("f4a9bc"))

static func get_texture(id: String, frame := 0, direction := "front") -> Texture2D:
	var key := id+str(frame)+direction
	if cache.has(key):
		return cache[key]
	var file_direction := "down"
	if direction in ["back","back_right","back_left"]:
		file_direction = "up"
	elif direction in ["side","right","left","front_right","front_left"]:
		file_direction = "right"
	var sprite_path := "res://Art/Sprites/%s_%s.png" % [id,file_direction]
	if not ResourceLoader.exists(sprite_path):
		var nested_path := "res://Art/Sprites/AllPokemon/%s/%s_%s.png" % [id,id,file_direction]
		if ResourceLoader.exists(nested_path):
			sprite_path = nested_path
	if ResourceLoader.exists(sprite_path):
		var imported: Texture2D = load(sprite_path)
		cache[key] = animate_imported(imported,frame,direction)
		return cache[key]
	var im := Image.create(72,72,false,Image.FORMAT_RGBA8)
	var b: int = [0,1,0,-1][frame%4]
	if direction!="front":
		if id in ["katapuldra","despotar","ditto","rayquaza","kyogre","kyurem","zekrom","reshiram"]:
			generic_view(im,id,b,direction)
		elif direction=="back":
			back_view(im,id,b)
		else:
			side_view(im,id,b)
		cache[key]=ImageTexture.create_from_image(im)
		return cache[key]
	match id:
		"pikachu":
			poly(im,[[13,48],[2,36],[13,27],[20,36],[13,41],[23,51]],INK)
			poly(im,[[14,46],[5,36],[13,30],[17,36],[10,41],[22,48]],Color("e6a634"))
			poly(im,[[24,29],[17,2],[26,5],[33,31]],INK)
			poly(im,[[27,27],[21,7],[25,9],[30,29]],Color("f7cf49"))
			poly(im,[[43,27],[47,1],[56,4],[51,32]],INK)
			poly(im,[[46,27],[49,10],[53,9],[49,29]],Color("ffe16b"))
			oval(im,36,49,17,17,INK)
			oval(im,36,48,15,15,Color("d99d30"))
			oval(im,38,44,13,14,Color("f6ca41"))
			oval(im,37,31,20,16,INK)
			oval(im,37,30,18,14,Color("ffd958"))
			oval(im,33,25,11,7,Color("ffe68b"))
			oval(im,23,36,4,3,Color("ef6954"))
			oval(im,50,36,4,3,Color("ef6954"))
			eye(im,29,29)
			eye(im,45,29)
			rect(im,37,34,3,2,INK)
			poly(im,[[33,38],[38,40],[43,38]],INK)
			oval(im,23,50+b*2,5,7,Color("ffe16b"))
			oval(im,49,50-b*2,5,7,Color("ffe16b"))
			oval(im,27-b*2,63,7,4,INK)
			oval(im,46+b*2,63,7,4,INK)
			oval(im,27-b*2,62,6,3,Color("ffe16b"))
			oval(im,46+b*2,62,6,3,Color("ffe16b"))
		"glurak":
			poly(im,[[27,32],[4,14],[4,50],[25,43]],INK)
			poly(im,[[25,33],[7,20],[9,44],[22,40]],Color("387f98"))
			poly(im,[[45,32],[66,14],[68,50],[47,45]],INK)
			poly(im,[[47,33],[64,20],[63,44],[49,40]],Color("469eb0"))
			poly(im,[[23,53],[10,58],[4,47],[7,64],[26,61]],Color("ce683c"))
			poly(im,[[8,59],[1,51],[3,39],[8,45],[10,35],[16,49]],Color("fa793c"))
			poly(im,[[8,54],[5,48],[9,41],[12,49]],Color("ffe17b"))
			oval(im,36,48,17,19,INK)
			oval(im,36,47,15,17,Color("dc763f"))
			oval(im,39,49,9,14,Color("f9d68b"))
			poly(im,[[27,26],[25,8],[34,16],[43,12],[51,5],[49,28]],INK)
			poly(im,[[29,25],[28,13],[34,20],[43,17],[48,11],[46,27]],Color("ef9450"))
			oval(im,38,28,13,11,Color("ef9450"))
			oval(im,46,33,12,6,INK)
			oval(im,46,32,10,5,Color("f3ad66"))
			eye(im,42,24)
			rect(im,46,36,8,2,INK)
			rect(im,49,36,2,3,Color.WHITE)
			oval(im,24,62-b*2,9,5,INK)
			oval(im,48,62+b*2,9,5,INK)
			oval(im,24,61-b*2,7,4,Color("ef9450"))
			oval(im,48,61+b*2,7,4,Color("ef9450"))
		"turtok":
			oval(im,33,42,24,23,INK)
			oval(im,33,41,22,21,Color("745950"))
			oval(im,33,41,18,17,Color("b18d6c"))
			for x in [14,47]:
				rect(im,x,13,11,25,INK)
				rect(im,x+2,15,7,21,Color("bdc9cd"))
				rect(im,x+2,14,7,4,Color("4e6476"))
			oval(im,38,46,17,18,INK)
			oval(im,38,45,15,16,Color("e5d0a0"))
			for y in [40,47,54]:
				rect(im,27,y,23,1,Color("b6a07f"))
			oval(im,38,25,16,13,INK)
			oval(im,38,24,14,11,Color("62b8ce"))
			oval(im,40,20,10,5,Color("94d7df"))
			eye(im,29,23)
			eye(im,46,23)
			rect(im,34,30,12,2,INK)
			oval(im,16,43+b*2,8,11,INK)
			oval(im,16,42+b*2,6,9,Color("62b8ce"))
			oval(im,59,43-b*2,8,11,INK)
			oval(im,59,42-b*2,6,9,Color("62b8ce"))
			oval(im,23-b,63,10,5,INK)
			oval(im,50+b,63,10,5,INK)
			oval(im,23-b,62,8,4,Color("62b8ce"))
			oval(im,50+b,62,8,4,Color("62b8ce"))
		"gengar":
			poly(im,[[13,34],[10,9],[29,22],[36,10],[43,22],[60,8],[58,37]],INK)
			poly(im,[[16,34],[14,15],[30,26],[36,17],[42,26],[56,14],[55,37]],Color("7660b4"))
			oval(im,36,43,26,23,INK)
			oval(im,36,42,24,21,Color("7353a7"))
			oval(im,32,33,18,12,Color("9271cd"))
			poly(im,[[17,30],[30,34],[28,40],[19,37]],Color("f38c96"))
			poly(im,[[41,34],[55,29],[52,38],[43,40]],Color("f38c96"))
			rect(im,25,34,2,5,INK)
			rect(im,44,34,2,5,INK)
			poly(im,[[18,43],[36,48],[55,42],[48,55],[26,56]],INK)
			poly(im,[[22,45],[36,50],[52,45],[46,53],[27,53]],Color("f5e3d1"))
			for x in [28,35,42]:
				rect(im,x,48,1,6,Color("7353a7"))
			poly(im,[[15,44],[2,49+b],[11,56],[18,51]],Color("7353a7"))
			poly(im,[[56,44],[69,49-b],[60,56],[53,51]],Color("7353a7"))
			oval(im,22-b*2,63,9,4,Color("58417d"))
			oval(im,50+b*2,63,9,4,Color("58417d"))
		"lapras":
			oval(im,36,55,28,12,INK)
			oval(im,36,54,26,10,Color("6ebecb"))
			poly(im,[[14,55],[3,64+b],[24,64]],Color("94d6de"))
			poly(im,[[48,55],[69,63-b],[46,65]],Color("94d6de"))
			oval(im,31,48,20,13,INK)
			oval(im,31,47,18,11,Color("8b8aa2"))
			for p in [[18,42],[31,38],[43,43]]:
				poly(im,[[p[0]-3,p[1]+3],[p[0],p[1]-5],[p[0]+5,p[1]+4]],Color("c6c5d6"))
			oval(im,38,36,10,22,INK)
			oval(im,38,35,8,20,Color("72c4d5"))
			oval(im,38,17,15,12,INK)
			oval(im,38,16,13,10,Color("8bd7e0"))
			poly(im,[[35,9],[38,0],[41,9]],Color("f2dfb6"))
			poly(im,[[26,12],[17,8],[20,23],[28,24]],Color("72b3cd"))
			poly(im,[[49,12],[58,8],[55,23],[48,24]],Color("72b3cd"))
			eye(im,31,16)
			eye(im,45,16)
			rect(im,34,23,9,1,INK)
		"sichlor":
			poly(im,[[25,30],[6,12],[12,42],[28,43]],Color("c8e3d2"))
			poly(im,[[45,29],[63,11],[60,42],[43,45]],Color("a8cebb"))
			oval(im,36,45,13,18,INK)
			oval(im,36,44,11,16,Color("69ae65"))
			oval(im,36,23,15,13,INK)
			oval(im,36,22,13,11,Color("91ce77"))
			poly(im,[[25,16],[25,3],[34,14]],Color("91ce77"))
			poly(im,[[39,14],[48,4],[48,19]],Color("91ce77"))
			eye(im,30,21)
			eye(im,44,21)
			poly(im,[[23,36],[15,31],[2,49],[7,55],[20,42]],INK)
			poly(im,[[22,37],[16,35],[5,49],[8,51],[20,40]],Color("e0e9dc"))
			poly(im,[[49,36],[58,31],[71,49],[65,55],[52,42]],INK)
			poly(im,[[50,37],[57,35],[68,49],[65,51],[52,40]],Color("e0e9dc"))
			poly(im,[[30,55],[18-b,65],[29,66],[36,55]],Color("91ce77"))
			poly(im,[[40,55],[48+b,65],[58,65],[45,53]],Color("91ce77"))
		"katapuldra":
			poly(im,[[18,47],[8,34],[18,28],[27,37],[24,51]],INK)
			poly(im,[[20,45],[12,35],[19,31],[24,38],[22,48]],Color("777bc4"))
			poly(im,[[24,25],[28,4],[36,17],[44,4],[48,26]],INK)
			poly(im,[[28,23],[31,10],[36,20],[41,10],[44,25]],Color("8b91dc"))
			oval(im,38,42,18,19,INK)
			oval(im,38,41,16,17,Color("858bd4"))
			oval(im,44,34,9,6,Color("b9aeea"))
			eye(im,42,31,true)
			poly(im,[[25,47],[36,55],[50,47],[45,60],[31,61]],Color("4b4f9b"))
			oval(im,28-b,64,8,4,Color("6d73bd"))
			oval(im,49+b,64,8,4,Color("6d73bd"))
		"despotar":
			poly(im,[[11,38],[17,12],[29,20],[43,12],[60,37],[55,61],[18,61]],INK)
			poly(im,[[15,37],[20,17],[30,25],[42,17],[56,37],[51,57],[21,57]],Color("a99564"))
			poly(im,[[24,22],[31,7],[38,22]],Color("71804e"))
			poly(im,[[29,31],[36,25],[44,31],[40,39],[30,39]],Color("d0bd7d"))
			eye(im,32,31)
			eye(im,45,31)
			poly(im,[[22,48],[36,52],[50,47],[45,55],[28,56]],Color("6f754d"))
			oval(im,24-b,64,10,5,Color("8a754f"))
			oval(im,49+b,64,10,5,Color("8a754f"))
		"ditto":
			oval(im,36,46,24,19,INK)
			oval(im,36,44,22,17,Color("b98bd1"))
			oval(im,30,36,6,5,Color("e3c5e7"))
			oval(im,43,36,6,5,Color("e3c5e7"))
			eye(im,30,39)
			eye(im,44,39)
			poly(im,[[28,48],[36,51],[45,48]],INK)
			oval(im,26-b,63,8,4,Color("9b72b8"))
			oval(im,47+b,63,8,4,Color("9b72b8"))
		"rayquaza":
			poly(im,[[12,40],[4,27],[18,28],[25,17],[34,25],[46,15],[58,27],[69,22],[60,39],[50,47],[43,62],[30,55],[21,62]],INK)
			poly(im,[[16,38],[10,30],[20,31],[27,22],[34,30],[46,21],[55,31],[63,27],[57,36],[47,43],[40,56],[32,50],[24,57]],Color("63d7a2"))
			poly(im,[[27,22],[32,5],[38,23]],Color("9be7b9"))
			eye(im,43,29)
			poly(im,[[48,38],[63,42],[51,46]],Color("d8f2d4"))
			oval(im,27-b,64,9,4,Color("399b7d"))
			oval(im,49+b,64,9,4,Color("399b7d"))
		"kyogre":
			poly(im,[[8,43],[2,28],[14,31],[23,18],[36,25],[49,18],[61,31],[70,27],[64,46],[51,58],[36,64],[21,58]],INK)
			poly(im,[[12,42],[7,31],[16,34],[24,23],[35,30],[48,23],[58,34],[66,31],[60,43],[49,54],[36,59],[23,54]],Color("4f9edb"))
			poly(im,[[18,30],[23,14],[30,28]],Color("e65c62")); poly(im,[[43,28],[50,14],[55,31]],Color("e65c62"))
			oval(im,28,36,5,4,Color("f7e6d0")); oval(im,47,36,5,4,Color("f7e6d0"))
			rect(im,31,44,17,3,Color("d9eef1")); oval(im,25-b,63,10,4,Color("2e5c9b")); oval(im,48+b,63,10,4,Color("2e5c9b"))
		"kyurem":
			poly(im,[[14,55],[8,35],[20,22],[28,5],[36,18],[45,5],[53,23],[65,35],[58,56],[45,64],[28,64]],INK)
			poly(im,[[18,53],[13,36],[23,26],[30,13],[36,24],[43,13],[50,27],[60,36],[54,53],[44,59],[29,59]],Color("9fd4e4"))
			poly(im,[[27,31],[36,22],[45,31],[40,42],[31,42]],Color("f6fbff")); eye(im,30,34); eye(im,47,34)
			poly(im,[[28,47],[36,53],[45,47],[41,58],[31,58]],Color("658ba7"))
		"zekrom":
			poly(im,[[11,49],[7,25],[22,31],[28,9],[38,27],[50,9],[56,31],[69,25],[63,52],[52,63],[23,63]],INK)
			poly(im,[[16,48],[13,31],[24,36],[30,18],[37,34],[47,18],[53,36],[63,31],[59,48],[50,57],[26,57]],Color("536e9e"))
			poly(im,[[29,38],[36,29],[44,38],[40,49],[32,49]],Color("42d9f2")); rect(im,34,41,5,2,Color("bff7ff")); eye(im,27,34); eye(im,49,34)
			oval(im,25-b,64,10,4,Color("273653")); oval(im,49+b,64,10,4,Color("273653"))
		"reshiram":
			poly(im,[[12,50],[5,28],[20,31],[28,8],[36,24],[46,8],[54,31],[69,27],[61,52],[49,64],[24,64]],INK)
			poly(im,[[17,48],[10,32],[22,35],[29,16],[36,31],[45,16],[51,35],[63,31],[57,48],[47,58],[27,58]],Color("e8e7dc"))
			poly(im,[[24,30],[36,18],[48,30],[42,43],[30,43]],Color("e65c3f")); eye(im,28,32); eye(im,48,32)
			poly(im,[[27,49],[36,54],[46,49],[41,60],[31,60]],Color("e7b74f"))
	cache[key] = ImageTexture.create_from_image(im)
	return cache[key]

static func generic_view(im: Image, id: String, b: int, direction: String) -> void:
	var base:=Color("b98bd1")
	var dark:=Color("6f5c98")
	if id=="katapuldra":
		base=Color("858bd4"); dark=Color("4b4f9b")
	elif id=="despotar":
		base=Color("a99564"); dark=Color("68734c")
	elif id=="rayquaza":
		base=Color("63d7a2"); dark=Color("399b7d")
	elif id=="kyogre":
		base=Color("4f9edb"); dark=Color("2e5c9b")
	elif id=="kyurem":
		base=Color("9fd4e4"); dark=Color("658ba7")
	elif id=="zekrom":
		base=Color("536e9e"); dark=Color("273653")
	elif id=="reshiram":
		base=Color("e8e7dc"); dark=Color("b9a98f")
	if id in ["kyogre","kyurem","zekrom","reshiram","rayquaza"]:
		# Gen-5-style back silhouettes: preserve each legendary's signature shape.
		if id=="kyogre":
			poly(im,[[7,50],[3,30],[18,35],[28,22],[36,30],[48,22],[62,35],[69,30],[63,52],[50,63],[22,63]],INK)
			poly(im,[[13,48],[10,34],[21,39],[29,29],[36,36],[45,29],[56,39],[63,34],[58,49],[48,57],[24,57]],base)
		elif id=="kyurem":
			poly(im,[[13,58],[8,30],[22,22],[28,5],[36,22],[44,5],[55,23],[64,31],[58,59],[45,67],[25,67]],INK)
			poly(im,[[18,55],[14,33],[25,27],[30,14],[36,29],[42,14],[50,28],[59,34],[54,55],[44,61],[28,61]],base)
		elif id=="zekrom":
			poly(im,[[11,58],[8,27],[23,35],[29,10],[37,30],[49,10],[56,35],[69,27],[63,59],[51,68],[23,68]],INK)
			poly(im,[[17,55],[14,33],[25,41],[31,19],[37,38],[46,19],[52,41],[63,33],[58,55],[49,62],[27,62]],base)
		elif id=="reshiram":
			poly(im,[[10,57],[6,28],[21,35],[29,9],[36,27],[45,9],[54,35],[69,28],[62,58],[49,68],[24,68]],INK)
			poly(im,[[16,53],[12,34],[23,41],[30,17],[36,34],[44,17],[51,41],[63,34],[57,54],[47,61],[28,61]],base)
		else:
			poly(im,[[13,58],[5,39],[18,35],[23,8],[36,26],[49,8],[54,35],[68,39],[59,58],[36,68]],INK)
			poly(im,[[18,55],[11,41],[22,39],[27,18],[36,32],[45,18],[50,39],[61,41],[54,54],[36,62]],base)
		return
	if id=="ditto":
		oval(im,36,45,23,18,INK); oval(im,36,43,21,16,base); oval(im,29,36,5,4,Color("e3c5e7")); oval(im,43,36,5,4,Color("e3c5e7")); eye(im,30,39); eye(im,44,39)
	else:
		oval(im,36,44,22,21,INK); oval(im,36,42,20,19,base); poly(im,[[20,32],[28,8],[36,22],[45,8],[53,33]],dark); oval(im,25+b,64,9,4,dark); oval(im,48-b,64,9,4,dark)

static func animate_imported(texture: Texture2D, frame: int, direction: String) -> Texture2D:
	var source:=texture.get_image()
	# Die gelieferten Sprites sind Einzelbilder, keine Sprite-Sheets. Eine
	# Pixelverschiebung würde Konturen zerreißen; das sanfte Wippen übernimmt
	# bereits fighter.gd über die Sprite-Position.
	return ImageTexture.create_from_image(source)

static func back_view(im: Image, id: String, b: int) -> void:
	match id:
		"pikachu":
			poly(im,[[24,27],[16,1],[25,4],[32,27]],INK)
			poly(im,[[27,26],[20,8],[24,10],[30,27]],Color("f9ce4d"))
			poly(im,[[41,26],[48,1],[56,4],[49,29]],INK)
			poly(im,[[44,26],[50,9],[53,10],[47,28]],Color("f9ce4d"))
			oval(im,36,46,17,20,INK)
			oval(im,36,45,15,18,Color("d8a232"))
			oval(im,36,31,19,15,INK)
			oval(im,36,30,17,13,Color("f6cd48"))
			oval(im,33,25,12,6,Color("ffe17a"))
			rect(im,24,46,24,4,Color("a56a32"))
			rect(im,25,54,22,4,Color("a56a32"))
			oval(im,22,48+b,5,9,Color("f6cd48"))
			oval(im,50,48-b,5,9,Color("f6cd48"))
			poly(im,[[39,61],[48,44],[43,39],[52,26],[66,34],[54,47],[58,50],[46,64]],INK)
			poly(im,[[43,59],[51,44],[47,39],[54,30],[61,34],[50,47],[54,50],[45,61]],Color("fce06b"))
			oval(im,26+b*2,64,7,3,Color("e1aa3a"))
			oval(im,46-b*2,64,7,3,Color("e1aa3a"))
		"glurak":
			poly(im,[[29,37],[5,11-b*2],[3,51],[28,48]],INK)
			poly(im,[[27,37],[8,18-b*2],[7,45],[26,45]],Color("347589"))
			poly(im,[[43,37],[67,11+b*2],[69,51],[44,48]],INK)
			poly(im,[[45,37],[64,18+b*2],[65,45],[46,45]],Color("438ea1"))
			oval(im,36,46,16,20,INK)
			oval(im,36,45,14,18,Color("cd6d3e"))
			poly(im,[[24,26],[23,9],[33,16],[40,16],[49,9],[48,29]],INK)
			oval(im,36,27,12,12,Color("ef9956"))
			poly(im,[[26,26],[26,13],[33,19],[41,19],[46,13],[46,28]],Color("ef9956"))
			poly(im,[[33,58],[29,51],[25,43],[31,46],[36,54],[45,61],[53,57],[51,66],[40,66]],Color("ef9956"))
			poly(im,[[52,65],[46,56],[50,43],[55,49],[61,39],[64,57],[58,66]],Color("fc8c43"))
			poly(im,[[53,61],[50,54],[56,46],[60,55],[57,62]],Color("ffe290"))
			oval(im,25+b*2,63,7,4,Color("ef9956"))
			oval(im,47-b*2,63,7,4,Color("ef9956"))
		"turtok":
			oval(im,36,22,14,12,INK)
			oval(im,36,21,12,10,Color("63b5cc"))
			for x in [12,49]:
				rect(im,x,9,11,32,INK)
				rect(im,x+2,11,7,26,Color("aabac5"))
				rect(im,x+2,11,7,4,Color("4b687e"))
			oval(im,36,45,23,23,INK)
			oval(im,36,44,21,21,Color("c1b493"))
			oval(im,36,43,18,18,Color("916c50"))
			poly(im,[[28,33],[43,32],[49,44],[41,55],[28,53],[23,42]],Color("ad865e"))
			poly(im,[[28,33],[43,32],[49,44],[41,55],[28,53],[23,42],[28,33]],INK)
			poly(im,[[29,35],[42,34],[47,44],[40,53],[29,51],[25,42]],Color("b28d65"))
			for p in [[18,30,27,34],[44,33,54,28],[49,44,56,47],[41,55,45,62],[27,54,22,62],[22,42,15,44]]:
				poly(im,[[p[0],p[1]],[p[2],p[3]],[p[2]+1,p[3]+2],[p[0]+1,p[1]+2]],INK)
			oval(im,11,45+b*2,6,10,Color("63b5cc"))
			oval(im,61,45-b*2,6,10,Color("63b5cc"))
			oval(im,22+b*2,65,8,3,Color("63b5cc"))
			oval(im,50-b*2,65,8,3,Color("63b5cc"))
		"gengar":
			poly(im,[[13,35],[10,9],[27,21],[35,9],[43,21],[60,8],[58,37]],INK)
			poly(im,[[16,35],[14,15],[29,26],[35,16],[41,26],[56,15],[55,37]],Color("7453a7"))
			oval(im,36,43,25,24,INK)
			oval(im,36,42,23,22,Color("7353a7"))
			oval(im,33,32,17,10,Color("8766bd"))
			for y in [30,40,50]:
				poly(im,[[31,y+5],[35,y-3],[42,y+6]],Color("a283cd"))
			poly(im,[[14,43],[2,50+b],[11,57],[18,50]],Color("7353a7"))
			poly(im,[[57,43],[70,50-b],[61,57],[54,50]],Color("7353a7"))
			oval(im,23+b*2,64,8,3,Color("58417d"))
			oval(im,49-b*2,64,8,3,Color("58417d"))
		"lapras":
			oval(im,36,52,26,14,INK)
			oval(im,36,51,24,12,Color("71bdcd"))
			oval(im,36,23,9,21,INK)
			oval(im,36,22,7,19,Color("76c1d1"))
			oval(im,36,14,12,10,INK)
			oval(im,36,13,10,8,Color("8fd6de"))
			poly(im,[[26,11],[16,7],[19,21],[28,21]],Color("6eb5c8"))
			poly(im,[[45,11],[56,7],[53,21],[45,21]],Color("6eb5c8"))
			oval(im,36,48,20,16,INK)
			oval(im,36,47,18,14,Color("8b8aa2"))
			for p in [[23,42],[36,36],[49,43],[31,53],[44,55]]:
				poly(im,[[p[0]-4,p[1]+4],[p[0],p[1]-5],[p[0]+5,p[1]+4]],Color("c3c4d4"))
			poly(im,[[17,53],[3,62+b],[22,64]],Color("9ad4de"))
			poly(im,[[55,53],[69,62-b],[50,64]],Color("9ad4de"))
		"sichlor":
			oval(im,36,23,14,13,INK)
			oval(im,36,22,12,11,Color("7db86a"))
			poly(im,[[24,15],[25,4],[33,15]],Color("93cc78"))
			poly(im,[[39,15],[47,4],[48,17]],Color("93cc78"))
			oval(im,36,46,12,18,INK)
			oval(im,36,45,10,16,Color("6ba75f"))
			poly(im,[[34,34],[9,23-b*2],[12,48],[34,54]],INK)
			poly(im,[[32,36],[13,28-b*2],[16,46],[32,50]],Color("c1dcc4"))
			poly(im,[[38,34],[63,23+b*2],[60,48],[38,54]],INK)
			poly(im,[[40,36],[59,28+b*2],[56,46],[40,50]],Color("a9cfb8"))
			poly(im,[[23,39],[13,46],[6,56],[10,60],[22,49]],Color("d4e4d9"))
			poly(im,[[49,39],[59,46],[66,56],[62,60],[50,49]],Color("d4e4d9"))
			oval(im,26+b*2,64,7,3,Color("91ce77"))
			oval(im,46-b*2,64,7,3,Color("91ce77"))

static func side_view(im: Image, id: String, b: int) -> void:
	match id:
		"pikachu":
			poly(im,[[22,54],[4,37],[13,25],[24,36],[17,42],[29,53]],INK)
			poly(im,[[22,50],[8,36],[14,29],[20,36],[13,42],[27,50]],Color("edbc43"))
			oval(im,35,48,14,18,INK)
			oval(im,35,47,12,16,Color("e5b43c"))
			oval(im,40,49,7,13,Color("ffdf6b"))
			poly(im,[[33,28],[26,1],[35,4],[42,28]],INK)
			poly(im,[[35,25],[30,9],[34,10],[39,27]],Color("ffe16b"))
			oval(im,41,30,16,15,INK)
			oval(im,41,29,14,13,Color("ffd558"))
			oval(im,52,36,10,6,Color("ffd558"))
			eye(im,46,27)
			rect(im,59,34,3,2,INK)
			oval(im,42,37,4,3,Color("ed6d59"))
			oval(im,45,50+b,5,8,Color("ffe16b"))
			oval(im,30+b*3,64,8,3,Color("edbc43"))
			oval(im,43-b*3,64,8,3,Color("ffe16b"))
		"glurak":
			poly(im,[[28,56],[8,59],[5,45],[3,64],[28,64]],Color("d97845"))
			poly(im,[[7,54],[0,42],[4,31],[10,40],[14,34],[15,48]],Color("ff9b48"))
			poly(im,[[7,48],[4,41],[8,37],[11,44]],Color("ffe398"))
			oval(im,37,46,14,20,INK)
			oval(im,37,45,12,18,Color("dd7c44"))
			oval(im,44,48,7,14,Color("f5d18c"))
			poly(im,[[32,35],[13,12-b*3],[8,44],[32,49]],INK)
			poly(im,[[29,36],[15,20-b*3],[12,40],[30,45]],Color("3a8c9e"))
			poly(im,[[34,22],[33,6],[42,15],[51,11],[53,26]],Color("eb9250"))
			oval(im,44,26,11,12,INK)
			oval(im,44,25,9,10,Color("ef9e58"))
			oval(im,54,31,12,6,INK)
			oval(im,54,30,10,4,Color("f2ad68"))
			eye(im,48,22)
			rect(im,53,34,10,1,INK)
			oval(im,32+b*3,64,8,3,Color("d97845"))
			oval(im,46-b*3,64,8,3,Color("ef9e58"))
		"turtok":
			oval(im,27,44,17,22,INK)
			oval(im,27,43,15,20,Color("9b7959"))
			oval(im,25,43,11,15,Color("b4936c"))
			rect(im,18,10,11,29,INK)
			rect(im,20,12,7,24,Color("c0cbd0"))
			rect(im,20,11,7,5,Color("476579"))
			oval(im,41,46,13,19,INK)
			oval(im,41,45,11,17,Color("dcc79b"))
			oval(im,43,24,14,13,INK)
			oval(im,43,23,12,11,Color("65bacf"))
			oval(im,52,29,9,5,Color("8dd0da"))
			eye(im,48,21)
			rect(im,50,32,9,1,INK)
			oval(im,49,45+b*2,7,11,Color("65bacf"))
			oval(im,29+b*3,64,9,3,Color("5696b0"))
			oval(im,48-b*3,64,9,3,Color("7cc9d9"))
		"gengar":
			poly(im,[[18,35],[13,13],[29,23],[37,8],[48,26]],INK)
			poly(im,[[21,35],[18,20],[30,29],[36,15],[44,27]],Color("7455a9"))
			oval(im,36,44,22,23,INK)
			oval(im,36,43,20,21,Color("7353a7"))
			oval(im,39,32,15,13,Color("8b69c1"))
			poly(im,[[42,29],[58,26],[54,36],[43,38]],Color("f39aa7"))
			rect(im,49,30,2,6,INK)
			poly(im,[[39,42],[60,38],[53,53],[39,55]],INK)
			poly(im,[[41,44],[57,41],[51,51],[41,52]],Color("f0dfd2"))
			rect(im,48,43,1,9,Color("7353a7"))
			poly(im,[[45,47],[65,51+b],[55,58],[43,55]],Color("7353a7"))
			oval(im,28+b*3,64,8,3,Color("58417d"))
			oval(im,46-b*3,64,8,3,Color("7455a9"))
		"lapras":
			oval(im,32,53,25,12,INK)
			oval(im,32,52,23,10,Color("70bfcd"))
			oval(im,29,46,18,13,INK)
			oval(im,29,45,16,11,Color("8b8aa2"))
			for p in [[18,40],[30,35],[40,42]]:
				poly(im,[[p[0]-3,p[1]+4],[p[0],p[1]-5],[p[0]+4,p[1]+4]],Color("c3c4d4"))
			oval(im,49,34,8,21,INK)
			oval(im,49,33,6,19,Color("72c4d5"))
			oval(im,52,16,13,10,INK)
			oval(im,52,15,11,8,Color("8bd7e0"))
			poly(im,[[45,9],[48,0],[51,10]],Color("f2dfb6"))
			poly(im,[[43,13],[34,8],[37,22],[44,23]],Color("6eb5c8"))
			eye(im,57,14)
			poly(im,[[17,53],[4,63+b],[25,63]],Color("8ed3dd"))
			poly(im,[[39,54],[58,63-b],[37,65]],Color("8ed3dd"))
		"sichlor":
			oval(im,36,45,11,18,INK)
			oval(im,36,44,9,16,Color("74ac62"))
			poly(im,[[32,34],[10,19-b*2],[15,48],[32,47]],INK)
			poly(im,[[30,35],[14,26-b*2],[18,45],[30,44]],Color("c4dfcc"))
			poly(im,[[35,16],[34,4],[42,15],[50,10],[52,28]],Color("91ce77"))
			oval(im,43,25,13,12,INK)
			oval(im,43,24,11,10,Color("91ce77"))
			eye(im,48,22)
			poly(im,[[44,39],[56,34],[70,46],[67,53],[57,42],[46,47]],INK)
			poly(im,[[47,40],[56,38],[67,47],[65,49],[57,40],[47,44]],Color("dcebdc"))
			poly(im,[[32,55],[22+b*3,65],[34,65],[40,55]],Color("7aaf65"))
			poly(im,[[41,54],[48-b*3,65],[59-b*3,65],[46,53]],Color("91ce77"))
