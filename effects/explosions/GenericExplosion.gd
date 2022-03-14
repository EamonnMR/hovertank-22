extends Spatial

export var damage: int = true
export var radius: int = true
export var friendly_splash: bool = true
var iff: IffProfile

func init(damage: int = 0, radius: int = 0, friendly_splash: bool = true, iff: IffProfile = null):
	self.damage = damage
	self.radius = radius

func immediate_damage():
	call_deferred("do_damage")

func do_damage():
	for body in Util.generic_aoe_query(self, self.global_transform.origin, radius):
		if friendly_splash or not iff.should_exclude(body.collider):
			Health.do_damage(body.collider, damage)

func _ready():
	$Particles.emitting = true
	$AudioStreamPlayer3D.play()
	$Lifetime.wait_time = $Particles.lifetime * 10
	$Lifetime.start()
	$Notifier.notify()
	immediate_damage()
	
func _on_Lifetime_timeout():
	queue_free()
