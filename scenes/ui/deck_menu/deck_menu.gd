extends Control
class_name DeckMenu

signal draw_pressed

@onready var background_detector: Button = $BackgroundDetector
@onready var center_container: CenterContainer = $CenterContainer
@onready var draw_button: Button = %DrawButton

func _ready() -> void:
	background_detector.pressed.connect(_on_background_detector_pressed)
	draw_button.pressed.connect(_on_draw_button_pressed)

func _on_draw_button_pressed() -> void:
	draw_pressed.emit()
	queue_free()

func _on_background_detector_pressed() -> void:
	queue_free()
