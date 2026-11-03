extends RefCounted
## Reject broken editable data before constructing a battle.
const KINDS = ["bolt","dash","orb","thunder","flame","zone","crescent","burst","water","beam","shield","wave","pulse","melee","nova"]
static func number(value, minimum: float, maximum: float) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value)>=minimum and float(value)<=maximum

static func validate(roster: Dictionary, moves: Dictionary, types: Dictionary, creature_ids: Array) -> PackedStringArray:
	var errors := PackedStringArray()
	for id in creature_ids:
		var d = roster.get(id)
		if not d is Dictionary:
			errors.append("Kreatur fehlt oder ist kein Objekt: "+str(id))
			continue
		for field in ["name","type","color","ability","description"]:
			if not d.get(field) is String or str(d.get(field,"")).is_empty():
				errors.append(str(id)+": Textfeld fehlt: "+field)
		for field in ["hp","attack","defense","special_attack","special_defense","speed","radius","scale"]:
			if not number(d.get(field),0.01,10000):
				errors.append(str(id)+": ungültiger Zahlenwert: "+field)
		if d.get("color") is String and not Color.html_is_valid(d.color):
			errors.append(str(id)+": ungültige Grafikfarbe")
		var lineup = d.get("moves")
		if not lineup is Array or lineup.size()!=4:
			errors.append(str(id)+": genau vier Attacken erforderlich")
		else:
			for move in lineup:
				if not move is String or not moves.has(move):
					errors.append(str(id)+": unbekannte Attacke: "+str(move))
		var defenders = d.get("types",[d.get("type","")])
		if not defenders is Array or defenders.is_empty() or defenders.size()>2:
			errors.append(str(id)+": ein oder zwei Typen erforderlich")
		else:
			for type in defenders:
				if not type is String or not types.has(type):
					errors.append(str(id)+": unbekannter Typ: "+str(type))
	for id in moves:
		var d = moves[id]
		if not d is Dictionary:
			errors.append("Attacke ist kein Objekt: "+str(id))
			continue
		for field in ["name","kind","type","color"]:
			if not d.get(field) is String:
				errors.append(str(id)+": Textfeld fehlt: "+field)
		if not d.get("kind") in KINDS:
			errors.append(str(id)+": unbekannte Angriffsform")
		if not types.has(d.get("type","")):
			errors.append(str(id)+": unbekannter Angriffstyp")
		for field in ["damage","cost","range","speed","radius"]:
			if not number(d.get(field),0,10000):
				errors.append(str(id)+": ungültiger Zahlenwert: "+field)
		if not number(d.get("cooldown"),0.05,120):
			errors.append(str(id)+": Cooldown muss positiv sein")
		if not number(d.get("cost"),0,100):
			errors.append(str(id)+": Energiekosten außerhalb von 0 bis 100")
		for field in ["duration","delay","tick_interval"]:
			if d.has(field) and not number(d[field],0.01,120):
				errors.append(str(id)+": ungültige Dauer: "+field)
	for attack_type in types:
		var table = types[attack_type]
		if not table is Dictionary:
			errors.append("Ungültige Typentabelle: "+str(attack_type))
			continue
		for defense_type in table:
			if not number(table[defense_type],0,4):
				errors.append("Ungültiger Typenfaktor: "+str(attack_type)+" / "+str(defense_type))
	return errors
