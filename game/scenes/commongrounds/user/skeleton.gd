#@tool
extends Skeleton2D

@onready var right_upper_arm_bone: Bone2D
@onready var right_lower_arm_bone: Bone2D 
@onready var right_arm_sprite: AnimatedSprite2D 
@export var angle_threshold : float = 30 # The threshold angle in degrees

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		right_upper_arm_bone = get_node_or_null("TorsoBone/RightUpperArmBone")
		right_lower_arm_bone = get_node_or_null("TorsoBone/RightUpperArmBone/RightLowerArmBone")
		right_arm_sprite = get_node_or_null("TorsoBone/RightUpperArmBone/Sprite2D")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if right_upper_arm_bone and right_lower_arm_bone and right_arm_sprite:
		var right_upper_arm_angle : float = right_upper_arm_bone.get_bone_angle()
		var right_lower_arm_angle : float = right_lower_arm_bone.get_bone_angle()
		var relative_angle : Variant = abs(right_upper_arm_angle - right_lower_arm_angle)
		print("relative: " + str(relative_angle) + ", upper: " + str(right_upper_arm_angle) + ", lower: " + str(right_lower_arm_angle))
	
		if relative_angle > angle_threshold:
			right_arm_sprite.frame = 0 # Bending arm sprite
		else:
			right_arm_sprite.frame = 1 # Straight arm sprite
