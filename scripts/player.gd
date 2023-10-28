extends CharacterBody3D
class_name Player

const cube = preload('res://scenes/cube.tscn')

@export var speed := 300.0
@export var gravity := 10.0

@onready var _gimbal := $Gimbal
@onready var _camera := $Gimbal/Camera3D

var _look = Vector2.ZERO

var camera: Camera3D:
	get:
		return _camera

func _capture():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _release():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(ev: InputEvent):
	if ev is InputEventKey:
		if ev.is_pressed() and ev.keycode == KEY_ESCAPE:
			_release()
	if ev is InputEventMouseMotion:
		_look = ev.relative
	if ev is InputEventMouseButton:
		if ev.is_pressed():
			_capture()
		
func _ready():
	_capture()
	
func _process(delta):
	if Input.is_action_just_pressed('fire'):
		var node = cube.instantiate()
		var dir = -_camera.global_transform.basis.z
		var viewport = get_viewport()
		viewport.add_child(node)
		node.global_position = _camera.global_position + dir
		node.linear_velocity = dir * 10.0

func _physics_process(delta):
		
	if abs(_look.length_squared()) > 0.001 and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-_look.x * 0.001)
		_gimbal.rotate_x(-_look.y * 0.001)
		_look = Vector2.ZERO
		pass
	
	var horizontal = Input.get_axis('move_left', 'move_right')
	var forward = Input.get_axis('move_back', 'move_forward')
	
	var direction = Vector3.ZERO
	direction += horizontal * transform.basis.x
	direction -= forward * transform.basis.z
	direction = direction.normalized()
	
	velocity.x = direction.x * speed * delta
	velocity.z = direction.z * speed * delta
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	move_and_slide()
	
	if Input.is_action_just_pressed('jump'):
		_jump()
	
func _jump():
	if not is_on_floor(): return
	velocity.y += gravity * 0.25
	pass
