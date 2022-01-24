extends Area

# Remember to connect _on_projectile_impact

export var damage: int = 10
export var friendly_splash: bool = false

var bodies = []
onready var parent = get_node("../")

func _on_DamageAoe_body_entered(body):
	bodies.append(body)

func _on_DamageAoe_body_exited(body):
	bodies.erase(body)

func _on_Projectile_impact():
	for body in bodies:
		if friendly_splash or not parent.iff.should_exclude(body):
			Health.do_damage(body, damage)
