extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -600.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var health = 1000
var destroyed = false
@onready var position_is_position = Vector2(0,0)

@onready var player_gun = $Gun
@onready var aimcast = $Gun/AimCast
@onready var player_sprite = $PlayerSprite

@onready var root_node = null

#@onready var Bullet = preload("res://bullet.tscn")
@onready var Bullet = preload("res://ricochet_bullet.tscn")
@onready var TestItem = preload("res://test_item.tscn")
#@export var Bullet : PackedScene

func _ready():
	root_node = get_tree().get_root().get_child(0)
	root_node.set_player(self)


func _physics_process(delta):
	if not destroyed:
		step(delta)


func step(delta):
	# Add the gravity.
	if health <= 0:
		destroyed = true
		queue_free()
	if not is_on_floor():
		velocity.y += gravity * delta
	player_gun.visible = true
	
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if not is_on_floor():
		player_sprite.animation = "jump"
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	
	
	if direction:
		if is_on_floor():
			player_sprite.animation = "walk"
		player_sprite.scale.x = 2 * direction
		velocity.x = direction * SPEED
	else:
		if is_on_floor():
			player_sprite.animation = "idle"
		velocity.x = move_toward(velocity.x, 0, SPEED)
		

	move_and_slide()


func _input(event):
	if event.is_action_pressed("Shoot"):
		shoot()


func shoot():
	if not player_gun.is_tip_colliding():
		
		var direction = (get_global_mouse_position() - self.global_position).normalized()
		
		var end_point = self.global_position + direction * 10000
		#var collision_point = aimcast.get_collision_point()
		var query = PhysicsRayQueryParameters2D.create(global_position, end_point)
		query.set_collision_mask(1)
		var space_state = get_world_2d().direct_space_state
		var bullet_spots = make_bounces(query, direction, space_state)
		
		var new_bullet = Bullet.instantiate()
		new_bullet.global_position = self.global_position + direction * 10
		get_tree().get_root().add_child(new_bullet)
		new_bullet.prepare_bullet(7, bullet_spots, global_position)


func make_bounces(query, direction, space_state, list=[], i=0, max_bounces=6):
		var result = space_state.intersect_ray(query)
		if result:
			
			# Get bounce dir
			var collision_point = result["position"]
			var normal = result["normal"]
			var new_dir = direction.bounce(normal).normalized()
			
			# Visualize the bounce
			var test_item = TestItem.instantiate()
			test_item.global_position = (collision_point)
			get_tree().get_root().add_child(test_item)

			# Append collision spot to list
			#print(result["collider"].name)
			if result["collider"].is_in_group("enemies"):
				var new_goal = collision_point + direction*10000
				var new_query = PhysicsRayQueryParameters2D.create(collision_point, new_goal)
				#list.append([collision_point, result["collider"]])
				return make_bounces(new_query, direction, space_state, list, i, max_bounces+1)
			else:
				list.append([collision_point, null])
			
			# Make bounce query
			var new_goal = collision_point + new_dir*10000
			var new_query = PhysicsRayQueryParameters2D.create(collision_point, new_goal)
			new_query.exclude = [result["rid"]]
			new_query.set_collision_mask(1)
			i += 1
			
			if i >= max_bounces:
				return list
			
			return make_bounces(new_query, new_dir, space_state, list, i, max_bounces)
		else:
			# Append non-colliding spot to list
			var point = global_position + direction * 10000
			list.append([point, null])
			return list
			


func _on_hurtbox_area_body_entered(body):
	if body.is_in_group("enemies"):
		var bat = body
		self.health -= 1
