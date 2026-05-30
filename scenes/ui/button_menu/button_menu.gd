extends Control
class_name ButtonMenu

@onready var background_detector: Button = $BackgroundDetector
@onready var center_container: CenterContainer = $CenterContainer

func _ready() -> void:
	background_detector.pressed.connect(_on_background_detector_pressed)

func _on_background_detector_pressed() -> void:
	queue_free()
