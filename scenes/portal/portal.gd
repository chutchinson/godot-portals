extends Node3D
class_name Portal

@export var target: Portal

@onready var _viewport = $Viewport
@onready var _camera = $Viewport/Camera
@onready var _mesh = $Area/PortalMesh

var _tracked = []
	
func _ready():
	var viewport = get_viewport()
	_viewport.size = viewport.size
	_attach.call_deferred()
	
func _attach():
	var texture = _viewport.get_texture()
	var material = _mesh.get_active_material(0) as ShaderMaterial
	material.set_shader_parameter('portal_texture', texture)
	#var dup = material.duplicate()
	#dup.set_shader_parameter('portal_texture', texture)
	#_mesh.set_surface_override_material(0, dup)
	
func _process(_delta):
	var viewport = get_viewport()
	var player_cam = viewport.get_camera_3d()
	
	# set camera position and rotation (transform) facing the target relative
	# to the portal we are looking at (this one)
	
	_camera.global_transform = target.global_transform \
		* global_transform.affine_inverse() \
		* player_cam.global_transform
		
	
	# construct a clipping plane which is exactly at the portal's 
	# position facing away from the portal
	
	#var origin = global_transform.origin
	#var normal = global_transform.basis.z.normalized()
	#var plane = Plane(normal, origin.dot(normal))
	#var near = plane.project(_camera.global_position).distance_to(_camera.global_position)
	#var far = 1000.0
	#
	## compute frustum offset
	#var offset = player_cam.to_local(global_position)

	# _camera.set_frustum(4.0, Vector2(offset.x, offset.y), near, far)
	
func track(body: PhysicsBody3D):
	if not _tracked.has(body):
		_tracked.push_back(body)
		
func untrack(body: PhysicsBody3D):
	_tracked.erase(body)

func teleport(body: PhysicsBody3D, target: Transform3D):
	body.global_transform = target

func visible(value: bool):
	_mesh.visible = value
	pass

func _on_area_body_entered(body: PhysicsBody3D):
	if _tracked.has(body): return
	target.track(body)
	
	if body is CharacterBody3D:
		target.visible(false)
	
	body.global_transform = target.global_transform \
		* global_transform.affine_inverse() \
		* body.global_transform
		
	# speedy thing goes in, speedy thing comes out	
	if body is RigidBody3D:
		body.linear_velocity = body.global_transform.basis * body.linear_velocity

func _on_area_body_exited(body):
	untrack(body)
	visible(true)

