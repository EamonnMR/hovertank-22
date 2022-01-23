extends Control

onready var vehicle_dd: OptionButton = $VBoxContainer/Selection/VehicleSelect/MenuButton
onready var primary_dd: OptionButton = $VBoxContainer/Selection/PrimaryWeaponSelect/MenuButton
onready var secondary_dd: OptionButton = $VBoxContainer/Selection/SecondaryWeaponSelect/MenuButton
onready var pilot_dd: OptionButton = $VBoxContainer/Selection/PilotSelect/MenuButton
onready var controller_dd: OptionButton = $VBoxContainer/LaunchOptions/ControllerOption

func _ready():
	for i in Client.VEHICLES:
		vehicle_dd.add_item(Client.VEHICLES[i].name)
	
	for i in Client.CONTROLLERS:
		controller_dd.add_item(i)
	
	for i in Client.WEAPONS:
		for j in [primary_dd, secondary_dd]:
			j.add_item(Client.WEAPONS[i].name)
			
	for i in Client.PILOTS:
		pilot_dd.add_item(Client.PILOTS[i].name)
	
	update_text()


func _on_StartButton_pressed():
	get_tree().change_scene("res://World.tscn")


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_Vehicle_selected(index):
	Client.set_vehicle_selection(index)
	update_text()

func _on_ControllerOption_item_selected(index):
	Client.set_controller_selection(index)
	
func _on_Primary_selected(index):
	Client.set_primary_selection(index)
	update_text()

func _on_Secondary_selected(index):
	Client.set_secondary_selection(index)
	update_text()

func _on_Pilot_selected(index):
	Client.set_pilot_selection(index)
	update_text()

func update_text():
	$VBoxContainer/Selection/VehicleSelect/Desc.text = \
		Client.VEHICLES[Client.selected_vehicle].desc
	$VBoxContainer/Selection/PrimaryWeaponSelect/Desc.text = \
		Client.WEAPONS[Client.selected_primary].desc
	$VBoxContainer/Selection/SecondaryWeaponSelect/Desc.text = \
		Client.WEAPONS[Client.selected_secondary].desc
	$VBoxContainer/Selection/PilotSelect/Desc.text = \
		Client.PILOTS[Client.selected_pilot].desc
