on_server_event:Connect(function(player)
	if player == local_player then
		framework.character.is_nv_enabled()
	end
end)