extends CanvasLayer
class_name InspectMenu

@onready var background_detector: Button = $BackgroundDetector
@onready var sprite_2d: Sprite2D = $Control/Sprite2D

func _ready() -> void:
	background_detector.pressed.connect(_on_background_detector_pressed)

func _on_background_detector_pressed() -> void:
	queue_free()
