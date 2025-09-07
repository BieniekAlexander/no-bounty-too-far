extends StaticBody2D

enum HingeLocation {TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT}

@export var hinge_location: HingeLocation = HingeLocation.TOP_RIGHT
@export var vertical: bool = true

# location of the hinge with respect to the door in its vertical state. Note the convention because the position swaps when the door is opened.
var hinge_transform:
	get:
		return {
			HingeLocation.TOP_LEFT:		Vector2(-1, -1) * 16,
			HingeLocation.TOP_RIGHT:		Vector2(+1, -1) * 16,
			HingeLocation.BOTTOM_LEFT:	Vector2(-1, +1) * 16,
			HingeLocation.BOTTOM_RIGHT:	Vector2(+1, +1) * 16
		}[hinge_location]

func toggle() -> void:
	if vertical:
		global_position += hinge_transform
		$Sprite.frame = 1
	else:
		global_position -= hinge_transform
		$Sprite.frame = 0
	
	vertical = not vertical

func on_interact() -> void:
	toggle()
	
