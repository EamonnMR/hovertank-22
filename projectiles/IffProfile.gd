class_name IffProfile

# Passes information around about who projectiles can and cannot hit.

var owner: Node
var faction: int
var exclude_allies: bool

func _init(owner: Node,faction: int,exclude_allies: bool):
	self.owner = owner
	self.faction = faction
	self.exclude_allies = exclude_allies
	
func _to_string():
	return "IffProfile: Owner: {a}, Faction: {b}, Exclude Allies? {c}".format(
		{"a": owner, "b": faction, "c": exclude_allies})


func should_exclude(collider: Node):
	var collider_faction = collider.get("faction")
	if collider == owner:
		return true
	if collider_faction == null:
		return false
	if collider_faction == faction and self.exclude_allies:
		print("Excluding: ", self, "collider_faction: ", self)
		return true
	return false
