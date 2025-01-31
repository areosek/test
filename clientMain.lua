task.wait(10)
shared.monster_data = 
{
	player = nil,
	on_server_event = nil,
	client_input_group = nil,
	bind_user_setting = nil
}

shared.monster_data.on_server_event = on_server_event:Connect(function(player)
	shared.monster_data.player = player
	print(player)
end)

shared.monster_data.client_input_group = ClientInputGroup.new()

shared.monster_data.bind_user_setting = shared.monster_data.client_input_group:bind_user_setting(function()
	if shared.monster_data.player == local_player then
		if framework.character.is_nv_head_gear_enabled() == false then
			framework.character.set_nv_enabled(true)
		else
			framework.character.set_nv_enabled(false)
		end
	end
end, InputType.Began, "night_vision")


