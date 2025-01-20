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
    shared.monster_data.started = false -- Variable to check if game started. Doesn't spawn joined players as spectators when game weren't started.
    shared.monster_data.weaponary = {
        ["primary"] = {
            [1] = {
                ["code"] = "a13c-0231-gc2e-edb6-28f0-a743-59wq-8960",
                ["weapon"] = "M4A1",
            },
            [2] = {
                ["code"] = "3e08-0231-wm5m-m4ab-bwm3-zeg8-8dnw-016f",
                ["weapon"] = "M4A1",
            },
            [3] = {
                ["code"] = "qbbn-0231-hhz1-1naz-820b-3f01-no1d-42ef",
                ["weapon"] = "M4A1",
            },
            [4] = {
                ["code"] = "3g5c-0231-cc71-deg8-wgq5-wgaq-ozgq-zmcc",
                ["weapon"] = "Remington870",
            },
            [5] = {
                ["code"] = "936n-0231-6dg0-w2q2-66e1-3boe-da5b-88qg",
                ["weapon"] = "AK308",
            },
            [6] = {
                ["code"] = "ca8m-0231-557d-4592-7e3f-na0w-n6md-en09",
                ["weapon"] = "AK74N",
            },
            [7] = {
                ["code"] = "fb4z-0231-o183-nma4-cc0z-wg92-3dh9-56eq",
                ["weapon"] = "AUG_A3",
            },
            [8] = {
                ["code"] = "hh8o-0231-31af-6o2z-4gdo-7nzc-q67z-332d",
                ["weapon"] = "SCARH",
            },
            [9] = {
                ["code"] = "4bza-0231-ff2z-2gda-64zf-za0a-n363-o9n0",
                ["weapon"] = "Vector",
            },
        },
        ["secondary"] = {
            [1] = {
                ["code"] = "zohf-0231-zn2q-cf61-b56f-1452-2h01-cah3",
                ["weapon"] = "EDC_X9",
            },
            [2] = {
                ["code"] = "o1fg-0231-8g4a-h4f2-ow2b-9nbz-fb71-4n2g",
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
            player.set_team("defender")
            player.set_speed(1)
            player.set_initial_health(100)
            player.respawn()
            player.set_camera_mode("Default")
        end
    end

    local function randomize_weapons(player)
        if player.get_team() == "defender" then -- Military weapons
        local primary_num = math.random(1,#weaponary["primary"])
        local secondary_num = math.random(1,#weaponary["secondary"])
        local setup_primary = weapons.get_setup_from_code(weaponary["primary"][primary_num]["code"])
        local setup_secondary = weapons.get_setup_from_code(weaponary["secondary"][secondary_num]["code"])

        player.set_weapon("primary",weaponary["primary"][primary_num]["weapon"],setup_primary.data.data)
        player.set_weapon("secondary",weaponary["secondary"][secondary_num]["weapon"],setup_secondary.data.data)
        player.set_weapon("throwable1","nothing")
        player.set_weapon("throwable2","nothing")
        player.equip_weapon("primary")
        else -- Monster weapons
        player.set_weapon("primary","EDC_X9", weapons.get_setup_from_code("hq9g-0231-7q9q-odwq-a6qb-w4z1-8cad-d2zm").data.data)
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
            sharedvars.plr_disable_nvg = false -- nvg accessible only for monster TODO.
            map.set_preset("darkworld") -- Setting spooky, scary night, booooo.
            map.set_time(1)
            gamemode.force_set_gamemode("team_deathmatch")
            for _, player in pairs(players.get_all()) do  -- Spawns players with assigned roles	 	
                if monster ~= player.name then			 -- Military setup
                    player.set_team("defender") 
                    player.set_camera_mode("Default") 
                    player.set_speed(1)
                    player.respawn()
                    randomize_weapons(player)
                else							         -- Monster setup
                    player.set_team("attacker") 		 
                    player.set_camera_mode("Default")
                    player.set_initial_health(500 + #playerList * 200)  -- health inscrease by playercount
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
