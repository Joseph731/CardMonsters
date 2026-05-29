extends Control
class_name DeckMenu

signal draw_pressed
signal search_pressed
signal shuffle_pressed

@onready var background_detector: Button = $BackgroundDetector
@onready var center_container: CenterContainer = $CenterContainer
@onready var draw_button: Button = %DrawButton
@onready var search_button: Button = %SearchButton
@onready var shuffle_button: Button = %ShuffleButton

func _ready() -> void:
	background_detector.pressed.connect(_on_background_detector_pressed)
	draw_button.pressed.connect(_on_draw_button_pressed)
	search_button.pressed.connect(_on_search_button_pressed)
	shuffle_button.pressed.connect(_on_shuffle_button_pressed)

func _on_draw_button_pressed() -> void:
	draw_pressed.emit()
	queue_free()

func _on_search_button_pressed()-> void:
	search_pressed.emit()
	queue_free()

func _on_shuffle_button_pressed()-> void:
	shuffle_pressed.emit()
	queue_free()

func _on_background_detector_pressed() -> void:
	queue_free()
