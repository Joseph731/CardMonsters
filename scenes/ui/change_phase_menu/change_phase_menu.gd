extends Control
class_name ChangePhaseMenu

signal phase_pressed(selected_phase: PhaseUI.Phase)

@onready var battle_phase_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/BattlePhaseButton
@onready var end_phase_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/EndPhaseButton

func _ready() -> void:
	battle_phase_button.pressed.connect(_on_battle_phase_pressed)
	end_phase_button.pressed.connect(_on_end_phase_pressed)

func _on_battle_phase_pressed() -> void:
	phase_pressed.emit(PhaseUI.Phase.Battle)
	queue_free()

func _on_end_phase_pressed() -> void:
	phase_pressed.emit(PhaseUI.Phase.End)
	queue_free()
