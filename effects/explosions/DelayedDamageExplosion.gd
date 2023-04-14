extends "res://effects/explosions/GenericExplosion.gd"

func immediate_damage():
	# Don't do damage immediately
	pass

func _ready():
	super._ready()
	assert($Lifetime.wait_time > $DamageDelay.wait_time)
	
