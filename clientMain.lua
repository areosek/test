local client_input_group = ClientInputGroup.new()
on_server_event:Connect(function(player)
	shared.monster = player
end)

client_input_group:bind_user_setting(function()
	if shared.monster == local_player then
		if framework.character.is_nv_head_gear_enabled() == false then
			framework.character.set_nv_enabled(true)
		else
			framework.character.set_nv_enabled(false)
		end
	end
end, InputType.Began, "night_vision")


