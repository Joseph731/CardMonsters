extends Control
class_name CardMenu

signal move_pressed

@onready var background_detector: Button = $BackgroundDetector
@onready var center_container: CenterContainer = $CenterContainer
@onready var move_button: Button = %MoveButton

func _ready() -> void:
	background_detector.pressed.connect(_on_background_detector_pressed)
	move_button.pressed.connect(_on_move_button_pressed)

func _on_move_button_pressed() -> void:
	move_pressed.emit()
	queue_free()

func _on_background_detector_pressed() -> void:
	queue_free()
