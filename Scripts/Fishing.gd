extends Node
#area you are in
var current_area = "lake"

var fish_waiting = false
var fish_bite_timer = 0.0
var fish_bite_time = 0.0

var fish_hooked = false
var fish_pending = null



# fishing stuff

func start_fishing():

	fish_waiting = true
	fish_hooked = false
	fish_pending = null

	fish_bite_timer = 0.0
	fish_bite_time = randf_range(2.0, 6.0)



#update timer for catching

func update(delta):

	if !fish_waiting:
		return

	fish_bite_timer += delta

	if fish_bite_timer >= fish_bite_time:
		trigger_bite()



# trigger biting 

func trigger_bite():

	fish_waiting = false
	fish_hooked = true

	#$"Statuslbl"("Something bit the hook!")



# fish on hook

func resolve_fish():

	if !fish_hooked:
		return null

	
	var fish_table = FishDB.tables[current_area]

	var roll = randf_range(0, 100)
	var cumulative = 0

	for fish in fish_table:
		cumulative += fish["rarity"]

		if roll <= cumulative:
			fish_pending = fish["name"]
			break
	
	var result = fish_pending
	#fish_label.text = "You caught: " + fish
	print("You caught:", result)
	
	fish_pending = null
	fish_hooked = false

	return result
