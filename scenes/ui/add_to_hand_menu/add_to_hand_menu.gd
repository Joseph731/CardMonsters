extends Control
class_name AddToHandMenu

signal add_to_hand_pressed

@onready var background_detector: Button = $BackgroundDetector
@onready var center_container: CenterContainer = $CenterContainer
@onready var add_to_hand_button: Button = %AddToHandButton

func _ready() -> void:
	background_detector.pressed.connect(_on_background_detector_pressed)
	add_to_hand_button.pressed.connect(_on_add_to_hand_pressed)

func _on_add_to_hand_pressed() -> void:
	add_to_hand_pressed.emit()
	queue_free()


func _on_background_detector_pressed() -> void:
	queue_free()
