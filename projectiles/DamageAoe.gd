extends Area3D

# Remember to connect _on_projectile_impact

var damage: int = 0
@export var radius: int = 0
@export var friendly_splash: bool = false

var bodies = []
@onready var parent = get_node("../")

func _ready():
	damage = parent.splash_damage
	parent.connect("impact",Callable(self,"do_damage"))

func do_damage():
	for body in Util.generic_aoe_query(self, self.global_transform.origin, radius):
		if friendly_splash or not parent.iff.should_exclude(body.collider):
			Health.do_damage(body.collider, damage)
