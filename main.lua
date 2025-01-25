-- author: areosek
-- game version: 0.23.1
-- script version: 1.2 FINAL
-- description: Idea for gamemode made by GamingMaster951. In this gamemode there is 1 (monster) vs everyone (military). The person who has been picked as monster can see more, run faster and has more health than everyone else, but have only weak 9mm pistol. The goal of the monster is to kill everyone and vice versa. Base code (one life) by blackshibe and edition of it for monster gamemode by areosek.

--[[ 

1.2 features:
- now weapons are randomized to avoid too very powerful guns.

TODO:
impossible for now(?)
- nvg is accessible only for monster (prob need to wait for API update)

]]
if shared.monster_data ~= nil then --Unloads(kidna?) if script was before in console.
	warn("monster script is already loaded, disconnecting")
	shared.monster_data.started = nil
    shared.monster_data.weaponary = nil
	shared.monster_data.player_died:Disconnect()
	shared.monster_data.player_joined:Disconnect()
	shared.monster_data.player_chatted:Disconnect()
else
    shared.monster_data =
    {
        started = nil,
        weaponary = nil,
        player_died = nil,
        player_joined = nil,
        player_chatted = nil
    }
    
    shared.monster_data.started = false -- Variable to check if game started. Doesn't spawn joined players as spectators when game weren't started.
    shared.monster_data.weaponary = {
        ["primary"] = {
            [1] = {
                ["code"] = "418q-0233-enww-ehm2-gc6a-195c-g7ab-f28a",
                ["weapon"] = "M4A1",
            },
            [2] = {
                ["code"] = "418q-0233-enww-ehm2-gc6a-195c-g7ab-f28a",
                ["weapon"] = "M4A1",
            },
            [3] = {
                ["code"] = "418q-0233-enww-ehm2-gc6a-195c-g7ab-f28a",
                ["weapon"] = "M4A1",
            },
            [4] = {
                ["code"] = "c218-0233-42fa-qeco-w4am-m3ch-f74h-8574",
                ["weapon"] = "Remington870",
            },
            [5] = {
                ["code"] = "1353-0233-heo1-0qzf-06ez-6dnf-gezh-egg1",
                ["weapon"] = "AK308",
            },
            [6] = {
                ["code"] = "q272-0233-8fdg-70b1-1af4-3maf-8b59-aee9",
                ["weapon"] = "AK74N",
            },
            [7] = {
                ["code"] = "g4w4-0233-aq8m-abge-7z3e-hgz0-heha-g49g",
                ["weapon"] = "AUG_A3",
            },
            [8] = {
                ["code"] = "2392-0233-5h5h-2cnb-98mb-3gb0-hmwd-baca",
                ["weapon"] = "SCARH",
            },
            [9] = {
                ["code"] = "5whm-0233-o7d8-8gc8-hdnn-w21h-q9zm-fm1c",
                ["weapon"] = "Vector",
            },
        },
        ["secondary"] = {
            [1] = {
                ["code"] = "0q5b-0233-c4cw-8nqc-m73n-5dd7-5n7w-2935",
                ["weapon"] = "EDC_X9",
            },
            [2] = {
                ["code"] = "c23w-0233-81wb-d8g3-e9c3-z546-b5e8-mdb0",
                ["weapon"] = "Glock17",
            },
        }
    }

    local function end_round() -- Ends round. Killing everyone, setting same team to everyone to avoid 2 or more monsters and take super speed from dead players.
        shared.monster_data.started = false
        gamemode.force_set_gamemode("none")
        map.set_preset("shipment")
        map.set_time(10)
        wait(3)
        chat.send_ingame_notification("round ended")
        players.reset_ragdolls()
        for _, player in pairs(players.get_all()) do
            player.fire_client("")
            player.set_team("defender")
            player.set_speed(1)
            player.set_initial_health(100)
            player.respawn()
            player.set_camera_mode("Default")
        end
    end

    local function randomize_weapons(player)
        if player.get_team() == "defender" then -- Military weapons
        local primary_num = math.random(1,#shared.monster_data.weaponary["primary"])
        local secondary_num = math.random(1,#shared.monster_data.weaponary["secondary"])
        local setup_primary = weapons.get_setup_from_code(shared.monster_data.weaponary["primary"][primary_num]["code"])
        local setup_secondary = weapons.get_setup_from_code(shared.monster_data.weaponary["secondary"][secondary_num]["code"])

        player.set_weapon("primary",shared.monster_data.weaponary["primary"][primary_num]["weapon"],setup_primary.data.data)
        player.set_weapon("secondary",shared.monster_data.weaponary["secondary"][secondary_num]["weapon"],setup_secondary.data.data)
        player.set_weapon("throwable1","nothing")
        player.set_weapon("throwable2","nothing")
        player.equip_weapon("primary")
        else -- Monster weapons 
        player.set_weapon("primary","EDC_X9", weapons.get_setup_from_code("0q5b-0233-c4cw-8nqc-m73n-5dd7-5n7w-2935").data.data)
        player.set_weapon("secondary","nothing")
        player.set_weapon("throwable1","nothing")
        player.set_weapon("throwable2","nothing")
        player.equip_weapon("primary")
        end
    end

    local function set_freecam(plr) -- Sets freecam to a player.
        plr.set_camera_mode("Freecam")
        plr.set_speed(5)
    end

    shared.monster_data.player_chatted = chat.player_chatted:Connect(function(sender, channel, content)
        if content == "!start" and sender == sharedvars.vip_owner then -- Starts game.
            chat.send_announcement("starting the round.")

            local playerList = {} --Chosing random player as monster.
            for _, player in pairs(players.get_all()) do
                playerList[_] = player.name
            end
            local monster = playerList[math.random(1,#playerList)]

            sharedvars.gm_match_time_minutes = (6 + #playerList * 2) -- Match time increase with number of players. On 2 players it is 10 minutes and with next joined player time increase by 2.
            sharedvars.plr_magazines = (3 + #playerList) -- Decide of number of magazines on start. With increasing playtime number of spare mags also increase with player count.
            sharedvars.plr_nv_color = Color3.fromRGB(200, 55, 50) -- Red nvg.
            sharedvars.gm_team_balancing_threshold = 50
            sharedvars.plr_disable_nvg = true -- nvg accessible only for monster TODO.
            map.set_preset("darkworld") -- Setting spooky, scary night, booooo.
            map.set_time(1)
            gamemode.force_set_gamemode("team_deathmatch")
            for _, player in pairs(players.get_all()) do  -- Spawns players with assigned roles	
            wait(0.1)
                if monster ~= player.name then			 -- Military setup
                    player.set_team("defender") 
                    player.set_camera_mode("Default") 
                    player.set_speed(1)
                    player.respawn()
                    randomize_weapons(player)
                else							         -- Monster setup
                    player.fire_client(player.name) -- Gives information to server, that player is monster and only can use NV gear.
                    player.set_team("attacker") 		 
                    player.set_camera_mode("Default")
                    player.set_initial_health(500 + #playerList * 200)  -- health inscreases by playercount
                    player.respawn()
                    randomize_weapons(player)
                end 
            end
            randomize_weapons()
            shared.monster_data.started = true
            wait(3)
            chat.send_ingame_notification("round started")
        elseif content == "!end" and sender == sharedvars.vip_owner then -- Ends game.
            chat.send_announcement("ending the round.")
            end_round()
        end
    end)

    shared.monster_data.player_died = on_player_died:Connect(function(name, killer_data, stats_counted)
        local player = players.get(name)
        if player.get_team() == "attacker" and shared.monster_data.started == true then --Checks if died player were a monster. If yes, game ends.
            chat.send_announcement("Monster has been killed by ",killer_data,"!")
            end_round()
        else
            if shared.monster_data.started == true then --Check if game started.
                set_freecam(player)
            end
        end
    end)

    shared.monster_data.player_joined = on_player_joined:Connect(function(name)
        local player = players.get(name)
        player.set_team("defender")
        if shared.monster_data.started == true then
            set_freecam(player)
        end
    end)

	map.set_map("afghanistan") --Best map for gamemode.
	info("")
	info("monster gamemode loaded!")
	info("to start the gamemode, type '!start' in the chat.")
	info("to end the gamemode, type '!end' in the chat.")
	info("only the VIP owner can do those commands.")
end
    