extends Node2D

onready var platform_container := $platform_container as Node2D
onready var platform_initial_position_y = $platform_container/platform.position.y
onready var camera := $camera as Camera2D
onready var player := $player as KinematicBody2D
onready var score_label := $camera/score as Label
onready var camera_start_position = $camera.position.y

var last_platform_is_cloud := false
var score := 0

export (Array, PackedScene) var platform_scene

func level_generator(amount):
	for items in amount:
		
		var new_type = randi() % 4
		
		platform_initial_position_y -= rand_range(36, 54)
		
		
		var new_platform
		
		if new_type == 0:
			new_platform = platform_scene[0].instance() as StaticBody2D
		elif new_type == 1:
			new_platform = platform_scene[1].instance() as StaticBody2D
		elif new_type >= 2:
			if last_platform_is_cloud == false and score > 1000:     #Aqui indicamos que para generar enemigos o plataforma tipo nube el jugador debe llegar a mas de 1000 puntos, esta logica se utilizara en un futuro para proximos enemigos y tipos de plataforma en funcion al escenario
				new_platform = platform_scene[new_type].instance() as StaticBody2D
				new_platform.connect("delete_object", self, "delete_object")
				last_platform_is_cloud = true
			else:
				new_platform = platform_scene[0].instance() as StaticBody2D
				last_platform_is_cloud = false
				
		
		if new_type != null:
			new_platform.position = Vector2(rand_range(20, 160), platform_initial_position_y)
			platform_container.call_deferred("add_child", new_platform)
	pass

func _ready() -> void:
	randomize()
	level_generator(30)

func _physics_process(delta: float) -> void:
	if player.position.y < camera.position.y:
		camera.position.y = player.position.y
	score_update()
	

func delete_object(obstacle):
	if obstacle.is_in_group("player"):
		#get_tree().reload_current_scene()
		if score > Global.highscore:
			Global.highscore = score
		
		if get_tree().change_scene("res://scenes/title_screen.tscn") != OK:
			print("SI JALA")
	elif obstacle.is_in_group("platform") or obstacle.is_in_group("enemies"):
		obstacle.queue_free()
		level_generator(1)
	


func _on_platform_cleaner_body_entered(body: Node) -> void:
	delete_object(body)
	

func score_update():
	score = camera_start_position - camera.position.y
	score_label.text = str(int(score))
