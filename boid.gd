extends KinematicBody2D

var _max_speed = 2
var _speed = 2
var _direction = Vector2(0, 1)
var _separation_distance = 20

var _local_flockmates = []


func _physics_process(_delta):
	self.rotation = Vector2(0, 1).angle_to(_direction)
	var collision = self.move_and_collide(_direction * _speed)
	if collision:
		if collision.collider is TileMap:
			_direction = _collision_reaction_direction(collision)
	else:
		_direction = _flock_direction()

func _collision_reaction_direction(collision):
	return (collision.position - collision.normal).direction_to(self.position)


func _flock_direction():
	var separation = Vector2()
	var heading = _direction
	var cohesion = Vector2()

	for flockmate in _local_flockmates:
		heading += flockmate.get_direction()
		cohesion += flockmate.position

		var distance = self.position.distance_to(flockmate.position)

		if distance < _separation_distance:
			separation -= (flockmate.position - self.position).normalized() * (_separation_distance / distance * _speed)

	if _local_flockmates.size() > 0:
		heading /= _local_flockmates.size()
		cohesion /= _local_flockmates.size()
		var center_direction = self.position.direction_to(cohesion)
		var center_speed = _max_speed * self.position.distance_to(cohesion) / $detection_radius/CollisionShape2D.shape.radius
		cohesion = center_direction * center_speed

	return (_direction + separation * 0.5 + heading * 0.5 + cohesion * 0.5).clamped(_max_speed)


func get_direction():
	return _direction


func set_direction(direction):
	_direction = direction


func _on_detection_radius_body_entered(body):
	if body == self:
		return

	if body.is_in_group("boid"):
		_local_flockmates.push_back(body)


func _on_detection_radius_body_exited(body):
	if body.is_in_group("boid"):
		_local_flockmates.erase(body)
