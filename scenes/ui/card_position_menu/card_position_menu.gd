extends ButtonMenu
class_name CardPositionMenu

signal position_selected(card_position)

@onready var face_up_attack_button: Button = %FaceUpAttack
@onready var face_up_defense_button: Button = %FaceUpDefense
@onready var face_down_attack_button: Button = %FaceDownAttack
@onready var face_down_defense_button: Button = %FaceDownDefense

func _ready() -> void:
	super._ready()
	face_up_attack_button.pressed.connect(_on_face_up_attack_button_pressed)
	face_up_defense_button.pressed.connect(_on_face_up_defense_button_pressed)
	face_down_attack_button.pressed.connect(_on_face_down_attack_button_pressed)
	face_down_defense_button.pressed.connect(_on_face_down_defense_button_pressed)
	
func _on_face_up_attack_button_pressed() -> void:
	position_selected.emit(Card.Card_Position.FACE_UP_ATTACK)
	queue_free()

func _on_face_up_defense_button_pressed() -> void:
	position_selected.emit(Card.Card_Position.FACE_UP_DEFENSE)
	queue_free()

func _on_face_down_attack_button_pressed() -> void:
	position_selected.emit(Card.Card_Position.FACE_DOWN_ATTACK)
	queue_free()

func _on_face_down_defense_button_pressed() -> void:
	position_selected.emit(Card.Card_Position.FACE_DOWN_DEFENSE)
	queue_free()

func _on_background_detector_pressed() -> void:
	position_selected.emit(null)
	super._on_background_detector_pressed()

#func remove_buttons???
