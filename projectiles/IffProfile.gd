class_name IffProfile

# Passes information around about who projectiles can and cannot hit.

var owner: Node
var exclude_npcs: bool
var exclude_players: bool

func _init(owner: Node, exclude_npcs: bool, exclude_players: bool):
	self.owner = owner
	self.exclude_npcs = exclude_npcs
	self.exclude_players = exclude_players

func should_exclude(collider: Node):
	return (
		exclude_players and (collider.has_method("is_player") and collider.is_player())
		or
		exclude_npcs and (collider.has_method("is_player") and not collider.is_player())
	)
