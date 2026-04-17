extends Node

# Loading battle scene
signal trigger_encounter(encounter_data)
signal end_encounter
signal refresh_player_data(new_data)

#Passing variables to party manager
signal pass_party_to_load(current_party)

#Player controls
signal pause(toggle: bool)

#Player Buttons
signal skipped_selected
signal attack_selected
signal move_selected
signal skill_selected

# Attack & Skill animations
signal take_damage
signal perform_skill
signal skill_finished

# Returns skill index of selected skill
signal skill_button_pressed(skill: Skill)

# Display Signals
signal display_option_info(op_name: String, op_desc: String, op_dmg: String)
signal clear_option_text
signal mana_changed(new_mana: float)

# Dialogue Lines
signal text_finished

# Temporaty until better solution
signal temp_do_chatter
signal temp_pass_level(starting_room: Room)
