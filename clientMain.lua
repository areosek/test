on_server_event:Connect(function(args)
	for i in args do
	print(args[i])
	end
end)