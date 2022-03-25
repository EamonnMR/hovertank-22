extends Control

onready var vehicle_dd: OptionButton = $VBoxContainer/Selection/VehicleSelect/MenuButton
onready var primary_dd: OptionButton = $VBoxContainer/Selection/PrimaryWeaponSelect/MenuButton
onready var secondary_dd: OptionButton = $VBoxContainer/Selection/SecondaryWeaponSelect/MenuButton
onready var pilot_dd: OptionButton = $VBoxContainer/Selection/PilotSelect/MenuButton
onready var controller_dd: OptionButton = $VBoxContainer/LaunchOptions/ControllerOption
onready var cameras_dd: OptionButton = $VBoxContainer/LaunchOptions/CameraOption
onready var missions_dd: OptionButton = $VBoxContainer/Mission/MenuButton

func _ready():
	for i in Client.VEHICLES:
		vehicle_dd.add_item(Client.VEHICLES[i].name)
	
	for i in Client.CONTROLLERS:
		controller_dd.add_item(i)
	
	for i in Client.CAMERAS:
		cameras_dd.add_item(i)
	
	for i in Client.WEAPONS:
		for j in [primary_dd, secondary_dd]:
			j.add_item(Client.WEAPONS[i].name)
	
	for i in Client.LEVELS:
		missions_dd.add_item(i.name)
	
	# HACK
	secondary_dd.selected = 1
	for i in Client.PILOTS:
		pilot_dd.add_item(Client.PILOTS[i].name)
	
	update_text()


func _on_StartButton_pressed():
	Client.start_level()


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

func _on_level_selected(index):
	Client.current_level = index
	update_text()

func update_text():
	
	$VBoxContainer/Selection/VehicleSelect/Desc.bbcode_text = \
		Client.VEHICLES[Client.selected_vehicle].desc
	$VBoxContainer/Selection/PrimaryWeaponSelect/Desc.bbcode_text = \
		Client.WEAPONS[Client.selected_primary].desc
	$VBoxContainer/Selection/SecondaryWeaponSelect/Desc.bbcode_text = \
		Client.WEAPONS[Client.selected_secondary].desc
	$VBoxContainer/Selection/PilotSelect/Desc.bbcode_text = \
		Client.PILOTS[Client.selected_pilot].desc
	$VBoxContainer/Selection/PilotSelect/Desc.bbcode_text = \
		Client.PILOTS[Client.selected_pilot].desc
	$VBoxContainer/Mission/Desc.bbcode_text = \
		Client.LEVELS[Client.current_level].desc

func _on_CameraOption_item_selected(index):
	Client.set_camera_selection(index)
