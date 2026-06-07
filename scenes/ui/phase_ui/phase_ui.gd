extends PanelContainer
class_name PhaseUI

enum Phase {Draw, Standby, Main1, Battle, Main2, End}

const CHANGE_PHASE_MENU = preload("uid://dkmhn4r5i1ly8")

@onready var label: Label = $HBoxContainer/Label
@onready var change_phase_button: Button = $HBoxContainer/ChangePhaseButton

var phase_text: String = "Draw Phase"

var _current_phase: Phase = Phase.Draw
var current_phase: Phase:
	get:
		return _current_phase
	set(value):
		_current_phase = value
		
		match value:
			Phase.Draw: phase_text = "Draw Phase"
			Phase.Standby: phase_text = "Standby Phase"
			Phase.Main1: phase_text = "Main Phase 1"
			Phase.Battle: phase_text = "Battle Phase"
			Phase.Main2: phase_text = "Main Phase 2"
			Phase.End: phase_text = "End Phase"

func _ready() -> void:
	change_phase_button.pressed.connect(_on_change_phase_pressed)
	
	update_label()

func _on_change_phase_pressed() -> void:
	get_parent().show_allow_menu.rpc("End " + phase_text + "?", "_on_allow_change_phase_yes_pressed", "Your opponent declined your request to change phases.")

func update_label() -> void:
	label.text = str(phase_text)

@rpc("any_peer", "call_remote", "reliable")
func change_phases() -> void:
	if current_phase == Phase.Main1:
		var change_phase_menu: ChangePhaseMenu = CHANGE_PHASE_MENU.instantiate()
		change_phase_menu.phase_pressed.connect(_on_phase_pressed)
		get_parent().menu_container.add_child(change_phase_menu)
	else:
		increment_phase.rpc()

@rpc("any_peer", "call_local", "reliable")
func increment_phase() -> void:
	current_phase = (current_phase + 1) % Phase.size() as Phase
	update_label()

@rpc("any_peer", "call_local", "reliable")
func _on_phase_pressed(selected_phase: Phase) -> void:
	if multiplayer.get_remote_sender_id() == 0:
		_on_phase_pressed.rpc(selected_phase)
		return
	current_phase = selected_phase
	update_label()
