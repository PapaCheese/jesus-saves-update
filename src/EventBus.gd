extends Node

# General Events
signal toggle_main_menu()
signal quit_game()
signal pause_game()
signal resume_game()
signal save_game(state, slot)
signal load_game(slot)

# Player Events
signal player_respawn()
signal player_change_facing(direction)
signal player_animation(animation)
