ESX = nil
PlayerData, AllData, Config = nil, nil, nil
local MyTeam = "none"
local airdrops = {}
local hitprops = {}
local hBlip = {}
local GameState, getdata, isPicking, isDead, InAction, MenuEnable = false, false, false, false, false, false
local requiredModels = {"p_cargo_chute_s", "ex_prop_adv_case_sm", "cuban800", "s_m_m_pilot_02", "prop_box_wood02a_pu"}
local WEAPON_FLARE = GetHashKey("weapon_flare")
local FLARE_AMMO = GetHashKey("w_am_flare")
local script_name = GetCurrentResourceName()
local hitcount = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	Citizen.Wait(500)
	PlayerData = ESX.GetPlayerData()
	TriggerServerEvent(script_name .. ':getGameState')
end)

RegisterNetEvent(script_name .. ':setGameData')
AddEventHandler(script_name .. ':setGameData', function(cf, data, GState, team)
	Config = cf
	getdata = true
	GameState = GState
	AllData = data
	MyTeam = team
	if GameState then
		Gameon()
	end
end)

RegisterNetEvent(script_name .. ':setMyteam')
AddEventHandler(script_name .. ':setMyteam', function(team)
	MyTeam = team
end)

RegisterNetEvent(script_name .. ':setGameStart')
AddEventHandler(script_name .. ':setGameStart', function(data, GState)
	GameState = GState
	AllData = data
	if GameState then
		TriggerServerEvent(script_name .. ':getMyteam')
		Gameon()
	else
		if MenuEnable then
			SendNUIMessage({ message = "hideUI" })
			MenuEnable = false
		end
		for k, v in pairs(hBlip) do
			RemoveBlip(v) 
			hBlip[k] = nil
		end
		for k,v in pairs(hitprops) do
			DeleteObject(v.prop)
            SetModelAsNoLongerNeeded(GetHashKey(v.model))
		end
        for r,x in pairs(airdrops) do
            DeleteObject(x.crate)
            if x.parachute then
                DeleteObject(x.parachute)
            end
            if x.pilot then
                SetEntityAsMissionEntity(x.pilot, false, true)
                DeletePed(x.pilot)
                SetEntityAsMissionEntity(x.aircraft, false, true)
                DeleteEntity(x.aircraft)
            end
            StopSound(x.soundID)
            ReleaseSoundId(x.soundID)
            RemoveBlip(x.blip)
        end
	end
end)

RegisterNetEvent(script_name .. ':setHoldStatus')
AddEventHandler(script_name .. ':setHoldStatus', function(k, bool)
	AllData[k].cd = bool
	if MenuEnable then
		SendNUIMessage({
			message = "updateData",
			teamData = AllData
		})
	end
end)

RegisterNetEvent(script_name .. ':setStealthStatus')
AddEventHandler(script_name .. ':setStealthStatus', function(k, bool)
	AllData[k].cds = bool
end)

RegisterNetEvent(script_name .. ':UpdateScore')
AddEventHandler(script_name .. ':UpdateScore', function(k, sc, _zone, _name)
	AllData[k].score = sc
	if MenuEnable then
		SendNUIMessage({
			message = "updateData",
			teamData = AllData
		})
		local text = _name..' Get points from '.. AllData[_zone].teamLabel ..' House'
		SendNUIMessage({
			message = "updateFeed",
			sendData = text,
		})
	end
	local playerPed = PlayerPedId()
	local pedCoords = GetEntityCoords(playerPed)
	local dist = #(pedCoords - AllData[_zone].center)
	if dist < Config.DistanceHouse and MyTeam ~= _zone then
		Citizen.Wait(500)
		ESX.Game.Teleport(playerPed, AllData[_zone].outside)
	end
end)

RegisterNetEvent(script_name .. ':UpdateStealth')
AddEventHandler(script_name .. ':UpdateStealth', function(k, sc, _zone, _sc, _name)
	AllData[k].score = sc
	AllData[_zone].score = _sc
	if MenuEnable then
		SendNUIMessage({
			message = "updateData",
			teamData = AllData
		})
		local text = _name..' Stealth points from'.. AllData[_zone].teamLabel ..' House'
		SendNUIMessage({
			message = "updateFeed",
			sendData = text,
		})
	end
end)

RegisterNetEvent(script_name .. ':UpdateAirdrop')
AddEventHandler(script_name .. ':UpdateAirdrop', function(k, sc, _name)
	AllData[k].score = sc
	if MenuEnable then
		SendNUIMessage({
			message = "updateData",
			teamData = AllData
		})
		local text = _name..' Get points from Airdrop point'
		SendNUIMessage({
			message = "updateFeed",
			sendData = text,
		})
	end
end)

RegisterCommand("eventshow", function(source, args, raw)
	if not MenuEnable and GameState then
		SendNUIMessage({
			message = "openUI",
			teamData = AllData,
			propData = hitprops
		})
		MenuEnable = true
	end
end, false)

RegisterCommand("eventclose", function(source, args, raw)
	if MenuEnable then
		SendNUIMessage({ message = "hideUI" })
		MenuEnable = false
	end
end, false)

function DrawText3D(x,y,z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

function Gameon()

	for k, v in pairs(AllData) do 
        local blip = AddBlipForCoord(v.coords)
        SetBlipSprite(blip, 414)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, 40)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("EVENT ".. v.teamLabel .." House")
        EndTextCommandSetBlipName(blip)
		hBlip[k] = blip
    end
	
	SendNUIMessage({
		message = "openUI",
		teamData = AllData,
		propData = hitprops
	})
	MenuEnable = true
	
	Citizen.CreateThread(function()
		while GameState do
			if MyTeam ~= "none" then
				local pedCoords = GetEntityCoords(PlayerPedId())
				for zone, data in pairs(AllData) do
					if Config.showDistanceHouse then
						DrawMarker(1, data.center.x, data.center.y, data.center.z -20, 0.0, 0.0, 0.0, 0, 0.0, 0.0, (Config.DistanceHouse * 2), (Config.DistanceHouse * 2), 100.0, 0, 0, 0, 120, false, true, 2, false, false, false, false)
					end
                    if Config.CollectPointEnable then
                        if (GetDistanceBetweenCoords(pedCoords, data.coords.x , data.coords.y, data.coords.z, true) < 1.0) and not isPicking and not isDead and not IsPedInAnyVehicle(PlayerPedId(), false) and IsPedOnFoot(PlayerPedId()) then
                            if MyTeam ~= zone then
                                if not data.cd then
                                    DrawText3D(data.coords.x , data.coords.y, data.coords.z + 0.5, ("[E] ~y~Pickup Point ("..data.teamLabel.." House)"))
                                    if (IsControlJustReleased(0, 38)) then
                                        isPicking = true
                                        TriggerEvent('mythic_progbar:client:progress', {
                                            name = "unique_action_name",
                                            duration = (Config.DurationCollect * 1000),
                                            label = "Loading",
                                            useWhileDead = false,
                                            canCancel = false,
                                            controlDisables = {
                                                disableMovement = true,
                                                disableCarMovement = true,
                                                disableMouse = false,
                                                disableCombat = true,
                                            },
                                            animation = {
                                                animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                                                anim = "machinic_loop_mechandplayer",
                                                flags = 49,
                                            },
                                        }, function(status)
                                            if (not status) then
                                                isPicking = false
                                                TriggerServerEvent(script_name .. ':Getpoints', zone, MyTeam)
                                            else
                                                isPicking = false
                                            end
                                        end)
                                    end
                                else
                                    DrawText3D(data.coords.x , data.coords.y, data.coords.z + 0.5, ("~r~Point not to get"))
                                end
                            end
                        end
                    end
					if Config.StealthEnable then
						if (GetDistanceBetweenCoords(pedCoords, data.stealthcoords.x , data.stealthcoords.y, data.stealthcoords.z, true) < 2.5) and not isPicking and not isDead and not IsPedInAnyVehicle(PlayerPedId(), false) and IsPedOnFoot(PlayerPedId()) then
							if MyTeam ~= zone then
								if not data.cds and data.score > 0 then
									DrawText3D(data.stealthcoords.x , data.stealthcoords.y, data.stealthcoords.z + 0.5, ("[E] ~y~Stealth Point ("..data.teamLabel.." House)"))
									if (IsControlJustReleased(0, 38)) then
										isPicking = true
										TriggerEvent('mythic_progbar:client:progress', {
											name = "unique_action_name",
											duration = (Config.DurationStealth * 1000),
											label = "Loading",
											useWhileDead = false,
											canCancel = false,
											controlDisables = {
												disableMovement = true,
												disableCarMovement = true,
												disableMouse = false,
												disableCombat = true,
											},
											animation = {
												animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
												anim = "machinic_loop_mechandplayer",
												flags = 49,
											},
										}, function(status)
											if (not status) then
												isPicking = false
												TriggerServerEvent(script_name .. ':Stealthpoints', zone, MyTeam)
											else
												isPicking = false
											end
										end)
									end
								else
									DrawText3D(data.stealthcoords.x , data.stealthcoords.y, data.stealthcoords.z + 0.5, ("~r~Point not to stealth"))
								end
							end
						end
					end
				end
				if not InAction and not isDead then
					for i=1, #AllData[MyTeam].BedList do
						local bedID = AllData[MyTeam].BedList[i]
						local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), bedID.objCoords.x, bedID.objCoords.y, bedID.objCoords.z, true)
						if distance < 2.0 then
							DrawText3D(bedID.objCoords.x, bedID.objCoords.y, bedID.objCoords.z + 0.4, "Press [~g~E~s~] for ~b~Heal~s~")
							if IsControlJustReleased(0, 38) then
								local player = PlayerPedId()
								local currentHealth = GetEntityHealth(player)
								local maxHealth = GetEntityMaxHealth(player)
								if (currentHealth == maxHealth) then
									exports.pNotify:SendNotification({text = "You are not injured.",type = "error"})
								else
									bedActive(player, bedID.objCoords.x, bedID.objCoords.y, bedID.objCoords.z-1.0, bedID.heading, bedID)
								end
							end
						end
					end
				elseif InAction then
					DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z + 0.4, "Press [~r~X~s~] for ~b~Exit~s~")
					if (IsControlJustReleased(0, 73)) then
						LeaveBed()
					end
				end
				Citizen.Wait(1)
			else
				Citizen.Wait(10000)
			end
		end
	end)
	
	Citizen.CreateThread(function()
		while GameState do
			Citizen.Wait(0)
			if MyTeam ~= "none" then
				if isPicking == true then
					DisableControlAction(0, 29, true) -- B
					DisableControlAction(0, 73, true) -- X
					DisableControlAction(0, 323, true) -- X
					DisableControlAction(0, 246, true) -- Y
					DisableControlAction(0, 289, true) -- F2
					DisableControlAction(0, 74, true) -- H
					DisableControlAction(0, 22, true) -- SPACEBAR
					DisableControlAction(0, 30, true) -- disable left/right
					DisableControlAction(0, 31, true) -- disable forward/back
					DisableControlAction(0, 23, true) -- disable f
					DisableControlAction(0, 21, true) -- disable sprint
					DisableControlAction(0, 44, true) -- Cover
					DisableControlAction(0, 18, true) -- Enter
					DisableControlAction(0, 176, true) -- Enter
					DisableControlAction(0, 201, true) -- Enter
					DisableControlAction(0, 170, true) -- F3
					DisableControlAction(0, 166, true) -- F5
					DisableControlAction(0, 167, true) -- F6
					DisableControlAction(0, 56, true) -- F9
				else
					Citizen.Wait(300)
				end
			else
				Citizen.Wait(1000)
			end
		end
	end)
	
	Citizen.CreateThread(function()
		while GameState do
			local found = false
			local player = PlayerPedId()
			local pos = GetEntityCoords(player)
			for k,v in pairs(airdrops) do
				found = true
				local crate_pos = GetEntityCoords(v.crate)
				if (GetDistanceBetweenCoords(pos, crate_pos, true) < 250.0) then
					DrawMarker(1, crate_pos.x, crate_pos.y, crate_pos.z -20, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 90.0, 90.0, 100.0, 0, 0, 0, 120, false, true, 2, false, false, false, false)
					if (GetDistanceBetweenCoords(pos, crate_pos, false) < 46.0) then
						if IsPedInAnyVehicle(player, false) then
							local veh = GetVehiclePedIsIn(player, false)
							if GetPedInVehicleSeat(veh, -1) == player then
								if DoesEntityExist(veh) and NetworkHasControlOfEntity(veh) then
									ESX.Game.DeleteVehicle(veh)
								end
							end
						end
						if GetDistanceBetweenCoords(pos, crate_pos, true) < 2.0 and not isPicking and not IsPedInAnyVehicle(player, false) and IsPedOnFoot(player) and MyTeam ~= "none" then
							if v.available and v.available > 0 then
								ESX.Game.Utils.DrawText3D({x = crate_pos.x, y = crate_pos.y, z = crate_pos.z + 0.5}, 'Unlock in '..v.available.." second", 0.8)
							elseif v.available and v.available <= 0 then
								ESX.Game.Utils.DrawText3D({x = crate_pos.x, y = crate_pos.y, z = crate_pos.z + 0.5}, 'Press [E] to open crate', 0.8)
								if IsControlJustReleased(0, 38) then
									isPicking = true
									exports["mythic_progbar"]:Progress(
									{
										name = "unique_action_name",
										duration = (DurationAirdrop * 1000),
										label = "Pickup..",
										useWhileDead = false,
										canCancel = false,
										controlDisables = {
											disableMovement = true,
											disableCarMovement = true,
											disableMouse = false,
											disableCombat = true
										},
										animation = {
											animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
											anim = "machinic_loop_mechandplayer",
											flags = 49,
										},
									}, function(status)
										if not status then
											if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), crate_pos, true) < 2.0 and not isDead  then
												TriggerServerEvent(script_name .. ':CollectAirdrop', k, MyTeam)
												Citizen.Wait(500)
											else
												TriggerEvent("pNotify:SendNotification", {text = "too far", type = "error"})
											end
											isPicking = false
										else
											isPicking = false
										end
									end)
								end
							end
						end
					end
				end
				if v.duration and v.duration <= 0 then
					DeleteEntity(airdrops[k].crate)
					StopSound(airdrops[k].soundID)
					ReleaseSoundId(airdrops[k].soundID)
					RemoveBlip(airdrops[k].blip)
					airdrops[k] = nil
				end
			end
			if not found then
				Citizen.Wait(1000)
			else
				Citizen.Wait(0)
			end
		end
	end)

    Citizen.CreateThread(function()
        while true do
            if next(hitprops) then
                for k, v in pairs(hitprops) do
                    if HasEntityBeenDamagedByWeapon(v.prop, 0, 1) then
						if v.ident ~= MyTeam then
							hitcount[v.ident] = hitcount[v.ident] + 1
                        	TriggerServerEvent(script_name .. ':HitProp', v.ident, MyTeam)
							if hitcount[v.ident] > 40 then
								hitcount[v.ident] = 0
								ReCreateProp(v)
							end
						end
                        ClearEntityLastDamageEntity(v.prop)
                    end
                end
                Citizen.Wait(5)
            else
                Citizen.Wait(1000)
            end
        end
    end)
end

AddEventHandler('esx:onPlayerDeath', function(data)
    isDead = true
	isPicking = false
	LeaveBed()
end)

AddEventHandler('esx:onPlayerSpawn', function()
    isDead = false
end)

function ActiveBed(player, x, y, z)
    SetEntityCoords(player, x, y, z + 0.3)
    TaskPlayAnim(player, 'missfbi5ig_0' , 'lyinginpain_loop_steve' ,8.0, -8.0, -1, 1, 0, false, false, false )
end

function bedActive(player, x, y, z, heading)
    FreezeEntityPosition(player, true)
    local animDict = 'missfbi5ig_0'
    local animName = 'lyinginpain_loop_steve'
    local taskFlag = 3
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(0)
    end
    ActiveBed(player, x, y, z)
    local headingCal = heading + 180
    if headingCal > 360 then
        headingCal = headingCal - 360
    end
    SetEntityHeading(player, headingCal)
    InAction = true
	local timerecover = (((60 * 1000) * Config.RecoverTime) / 100)
    Citizen.CreateThread(function ()
        Citizen.Wait(5)
        local currentHealth = GetEntityHealth(player)
        local maxHealth = GetEntityMaxHealth(player)

        if (currentHealth < maxHealth)  then
            Citizen.Wait(5000)
            if InAction then
                while currentHealth < maxHealth and InAction do
                    if not IsEntityPlayingAnim(
                        player --[[ Entity ]], 
                        animDict --[[ string ]], 
                        animName --[[ string ]], 
                        taskFlag --[[ integer ]]
                    ) then
                        ActiveBed(player, x, y, z)
                    end
                    Citizen.Wait(timerecover)
                    currentHealth = GetEntityHealth(player) + 1
                    SetEntityHealth(player, currentHealth)
                end
                currentHealth = GetEntityHealth(player)
                if currentHealth == maxHealth then
					LeaveBed()
                end
            end
        end
    end)
end

function LeaveBed()
    if not InAction then
        return
    end
    local player = PlayerPedId()
    local getOutDict = 'switch@franklin@bed'
    local getOutAnim = 'sleep_getup_rubeyes'
	InAction = false
	RequestAnimDict(getOutDict)
	while not HasAnimDictLoaded(getOutDict) do
		Citizen.Wait(0)
	end
	DoScreenFadeOut(500)
	while not IsScreenFadedOut() do
		Citizen.Wait(100)
	end
	SetEntityInvincible(player, false)
	local heading = GetEntityHeading(player) + 90
	if heading > 360 then
		heading = heading - 360
	end
	SetEntityHeading(player, heading)
	local coords = GetEntityCoords(player)
	SetEntityCoords(player, coords.x, coords.y, coords.z - 1.55)
	TaskPlayAnim(player, getOutDict , getOutAnim, 100.0, 1.0, -1, 3, -1, 0, 0, 0)
	Citizen.Wait(1000)
	DoScreenFadeIn(500)
	Citizen.Wait(4000)
	ClearPedTasks(player)
	FreezeEntityPosition(player, false)
end

RegisterNetEvent(script_name .. ':broadcast_location')
AddEventHandler(script_name .. ':broadcast_location', function(ident, pos)
	local blip = AddBlipForCoord(pos.x, pos.y, pos.z)
	SetBlipSprite(blip, 4)
	SetBlipColour(blip, 56)
	SetBlipAlpha(blip, 255)
	
	airdrops[ident] = {
		blip = blip
	}
end)

RegisterNetEvent(script_name .. ':broadcast_airdrop')
AddEventHandler(script_name .. ':broadcast_airdrop', function(ident, spawn_pos, drop_pos, avlbtime, duration)
	airdrops[ident].available = avlbtime
	airdrops[ident].duration = duration
	Citizen.CreateThread(function()
		for i = 1, #requiredModels do
			RequestModel(GetHashKey(requiredModels[i]))
			while not HasModelLoaded(GetHashKey(requiredModels[i])) do
				Citizen.Wait(0)
			end
		end
		
		RequestWeaponAsset(WEAPON_FLARE) 
		while not HasWeaponAssetLoaded(WEAPON_FLARE) do
			Citizen.Wait(0)
		end
		
		airdrops[ident].crate = CreateObject(GetHashKey("ex_prop_adv_case_sm"), spawn_pos, false, false, true)
		SetEntityLodDist(airdrops[ident].crate, 1000)
		ActivatePhysics(airdrops[ident].crate)
		SetDamping(airdrops[ident].crate, 2, 0.1) 
		SetEntityVelocity(airdrops[ident].crate, 0.0, 0.0, -0.2)
		SetEntityInvincible(airdrops[ident].crate, true)
		
		
		airdrops[ident].parachute = CreateObject(GetHashKey("p_cargo_chute_s"), spawn_pos, false, false, true)
		SetEntityLodDist(airdrops[ident].parachute, 1000)
		SetEntityVelocity(airdrops[ident].parachute, 0.0, 0.0, -0.2)
		ActivatePhysics(airdrops[ident].parachute)

		AttachEntityToEntity(airdrops[ident].parachute, airdrops[ident].crate, 0, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
		
		airdrops[ident].soundID = GetSoundId()
		PlaySoundFromEntity(airdrops[ident].soundID, "Crate_Beeps", airdrops[ident].crate, "MP_CRATE_DROP_SOUNDS", true, 0)
		
		Citizen.Wait(500)
		
		local exceed = GetGameTimer() + (90 * 1000)
		while (GetEntityHeightAboveGround(airdrops[ident].crate) > 1 and exceed > GetGameTimer()) do
			ActivatePhysics(airdrops[ident].crate)
			ActivatePhysics(airdrops[ident].parachute)
			Citizen.Wait(100)
		end

		Citizen.CreateThread(function()
			while airdrops[ident] and airdrops[ident].duration > 0 do
				ActivatePhysics(airdrops[ident].crate)
				ActivatePhysics(airdrops[ident].parachute)
				Citizen.Wait(500)
			end
		end)
		
		if exceed < GetGameTimer() then
			SetEntityCoords(airdrops[ident].crate, spawn_pos.x, spawn_pos.y, spawn_pos.z + 0.5)
			PlaceObjectOnGroundProperly(airdrops[ident].crate)

			Citizen.CreateThread(function()
				while airdrops[ident] and airdrops[ident].duration > 0 do
					SetEntityCoords(airdrops[ident].crate, drop_pos.x, drop_pos.y, drop_pos.z)
					PlaceObjectOnGroundProperly(airdrops[ident].crate)
					FreezeEntityPosition(airdrops[ident].crate, true)
					Citizen.Wait(500)
				end
			end)
			
			local blip = AddBlipForEntity(airdrops[ident].crate)
			SetBlipSprite(blip, 1)
			SetBlipColour(blip, 56)
			SetBlipScale(blip, 0.5)
			SetBlipAsShortRange(blip, true)
			SetBlipDisplay(blip, 4)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Airdrop point")
			EndTextCommandSetBlipName(blip)
		end

		local parachuteCoords = vector3(GetEntityCoords(airdrops[ident].parachute))
		
		SetEntityAsMissionEntity(airdrops[ident].parachute, true)
		DetachEntity(airdrops[ident].parachute, true, true)
		
		SetEntityCoords(airdrops[ident].parachute, vector3(0,0,-100))
		DeleteObject(airdrops[ident].parachute)
		FreezeEntityPosition(airdrops[ident].crate, true)
		PlaceObjectOnGroundProperly(airdrops[ident].crate)

		StopSound(airdrops[ident].soundID)
		ReleaseSoundId(airdrops[ident].soundID)
		
		for i = 1, #requiredModels do
			Citizen.Wait(0)
			SetModelAsNoLongerNeeded(GetHashKey(requiredModels[i]))
		end
		
		RemoveWeaponAsset(WEAPON_FLARE)
	end)
end)

RegisterNetEvent(script_name .. ':broadcast_airdrop2')
AddEventHandler(script_name .. ':broadcast_airdrop2', function(ident, drop_pos, avlbtime, duration)
	airdrops[ident].available = avlbtime
	airdrops[ident].duration = duration
	Citizen.CreateThread(function()
		for i = 1, #requiredModels do
			RequestModel(GetHashKey(requiredModels[i]))
			while not HasModelLoaded(GetHashKey(requiredModels[i])) do
				Citizen.Wait(0)
			end
		end
		airdrops[ident].crate = CreateObject(GetHashKey("ex_prop_adv_case_sm"), drop_pos, false, false, true)
		SetEntityInvincible(airdrops[ident].crate, true)
		airdrops[ident].soundID = GetSoundId()
		PlaySoundFromEntity(airdrops[ident].soundID, "Crate_Beeps", airdrops[ident].crate, "MP_CRATE_DROP_SOUNDS", true, 0)
		Citizen.Wait(500)
		
		Citizen.CreateThread(function()
			while airdrops[ident] and airdrops[ident].duration > 0 do
				ActivatePhysics(airdrops[ident].crate)
				Citizen.Wait(500)
			end
		end)

		SetEntityCoords(airdrops[ident].crate, drop_pos.x, drop_pos.y, drop_pos.z + 0.5)
		PlaceObjectOnGroundProperly(airdrops[ident].crate)

		Citizen.CreateThread(function()
			while airdrops[ident] and airdrops[ident].duration > 0 do
				SetEntityCoords(airdrops[ident].crate, drop_pos.x, drop_pos.y, drop_pos.z)
				PlaceObjectOnGroundProperly(airdrops[ident].crate)
				FreezeEntityPosition(airdrops[ident].crate, true)
				Citizen.Wait(500)
			end
		end)
		
		local blip = AddBlipForEntity(airdrops[ident].crate)
		SetBlipSprite(blip, 1)
		SetBlipColour(blip, 56)
		SetBlipScale(blip, 0.5)
		SetBlipAsShortRange(blip, true)
		SetBlipDisplay(blip, 4)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Airdrop point")
		EndTextCommandSetBlipName(blip)
		FreezeEntityPosition(airdrops[ident].crate, true)
		PlaceObjectOnGroundProperly(airdrops[ident].crate)
		StopSound(airdrops[ident].soundID)
		ReleaseSoundId(airdrops[ident].soundID)
		
		for i = 1, #requiredModels do
			Citizen.Wait(0)
			SetModelAsNoLongerNeeded(GetHashKey(requiredModels[i]))
		end
	end)
end)

RegisterNetEvent(script_name .. ':remove_airdrop')
AddEventHandler(script_name .. ':remove_airdrop', function(ident)
	if airdrops[ident] then
		local pos = GetEntityCoords(airdrops[ident].crate)
		
		DeleteObject(airdrops[ident].crate)
		if airdrops[ident].parachute then
			SetEntityAsMissionEntity(airdrops[ident].parachute, true)
			SetEntityCoords(airdrops[ident].parachute, vector3(0,0,0))
			DeleteObject(airdrops[ident].parachute)
		end
		
		if airdrops[ident].pilot then
			SetEntityAsMissionEntity(airdrops[ident].pilot, false, true)
			DeletePed(airdrops[ident].pilot)
			SetEntityAsMissionEntity(airdrops[ident].aircraft, false, true)
			DeleteEntity(airdrops[ident].aircraft)
		end
		
		StopSound(airdrops[ident].soundID)
		ReleaseSoundId(airdrops[ident].soundID)
		RemoveBlip(airdrops[ident].blip)
		
		airdrops[ident] = nil
		
		while DoesObjectOfTypeExistAtCoords(pos, 10.0, FLARE_AMMO, true) do
            Wait(0)
            local prop = GetClosestObjectOfType(pos, 10.0, FLARE_AMMO, false, false, false)
            RemoveParticleFxFromEntity(prop)
            SetEntityAsMissionEntity(prop, true, true)
            DeleteObject(prop)
        end
	end
end)

RegisterNetEvent(script_name .. ':updatetime')
AddEventHandler(script_name .. ':updatetime', function(ident, duration, avlbtime)
	if airdrops[ident] then
		airdrops[ident].duration = duration
		airdrops[ident].available = avlbtime
	end
end)

RegisterNetEvent(script_name .. ':updateprop')
AddEventHandler(script_name .. ':updateprop', function(duration, data)
    for k, v in pairs(hitprops) do
        hitprops[k].duration = duration
        hitprops[k].hp = data[k].hp
    end
    if MenuEnable then
        SendNUIMessage({
            message = "UpdateHP",
            propData = hitprops
        })
    end
end)

RegisterNetEvent(script_name .. ':remove_hitprop')
AddEventHandler(script_name .. ':remove_hitprop', function(ident)
	if hitprops[ident] then
		ESX.Game.DeleteObject(hitprops[ident].prop)
		hitprops[ident] = nil
		if MenuEnable then
			SendNUIMessage({
				message = "UpdateHP",
                propData = hitprops
			})
		end
	end
end)

RegisterNetEvent(script_name .. ':timeoutprop')
AddEventHandler(script_name .. ':timeoutprop', function()
	local playerPed = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)
    for k, v in pairs(hitprops) do
        ESX.Game.DeleteObject(v.prop)
		local pp = GetClosestObjectOfType(playerCoords, 50.0, AllData[k].model, false, false, false)
		if DoesEntityExist(pp) then
			ESX.Game.DeleteObject(pp)
		end
		hitprops[k] = nil
		if MenuEnable then
			SendNUIMessage({
				message = "UpdateHP",
                propData = hitprops
			})
		end
	end
end)

function ReCreateProp(prop)
	if hitprops[prop.ident] then
		local PModel = AllData[prop.ident].model
		if not HasModelLoaded(GetHashKey(PModel)) then
			RequestModel(GetHashKey(PModel))
			while not HasModelLoaded(GetHashKey(PModel)) do
				Citizen.Wait(1)
			end
		end
		ESX.Game.DeleteObject(hitprops[prop.ident].prop)
		hitprops[prop.ident].prop = nil
		local Cprop = CreateObject(GetHashKey(PModel), prop.coords, false, false, true)
		SetEntityCoords(Cprop, prop.coords.x, prop.coords.y, prop.coords.z-0.0)
		SetEntityHeading(Cprop, prop.heading)
		-- PlaceObjectOnGroundProperly(Cprop)
		FreezeEntityPosition(Cprop, true)
		SetModelAsNoLongerNeeded(GetHashKey(PModel))
		hitprops[prop.ident].prop = Cprop
	end
end

RegisterNetEvent(script_name .. ':broadcast_hitprop')
AddEventHandler(script_name .. ':broadcast_hitprop', function(data)
    for k, v in pairs(data) do
        local PModel = AllData[v.ident].model
        if not HasModelLoaded(GetHashKey(PModel)) then
            RequestModel(GetHashKey(PModel))
            while not HasModelLoaded(GetHashKey(PModel)) do
                Citizen.Wait(1)
            end
        end
        local Cprop = CreateObject(GetHashKey(PModel), v.coords, false, false, true)
        SetEntityCoords(Cprop, v.coords.x, v.coords.y, v.coords.z-0.0)
        SetEntityHeading(Cprop, v.heading)
		-- PlaceObjectOnGroundProperly(Cprop)
        FreezeEntityPosition(Cprop, true)
        SetModelAsNoLongerNeeded(GetHashKey(PModel))
        hitprops[v.ident] = {
            ident = v.ident,
            hp = v.hp,
            coords = v.coords,
            heading = v.heading,
            duration = v.duration,
            prop = Cprop,
            model = PModel
        }
		hitcount[v.ident] = 0
    end
    SendNUIMessage({
        message = "UpdateHP",
        propData = hitprops
    })
end)

RegisterNetEvent(script_name .. ':updatehpprop')
AddEventHandler(script_name .. ':updatehpprop', function(data)
    if hitprops[data.idn] then
        hitprops[data.idn] = data.hp
    end
end)

RegisterNetEvent(script_name .. ':UpdatePoints')
AddEventHandler(script_name .. ':UpdatePoints', function(k, sc)
	AllData[k].score = sc
	if MenuEnable then
		SendNUIMessage({
			message = "updateData",
			teamData = AllData
		})
	end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
		for k,v in pairs(hitprops) do
			DeleteObject(v.prop)
            SetModelAsNoLongerNeeded(GetHashKey(v.model))
		end
        for r,x in pairs(airdrops) do
            DeleteObject(x.crate)
            if x.parachute then
                DeleteObject(x.parachute)
            end
            if x.pilot then
                SetEntityAsMissionEntity(x.pilot, false, true)
                DeletePed(x.pilot)
                SetEntityAsMissionEntity(x.aircraft, false, true)
                DeleteEntity(x.aircraft)
            end
            StopSound(x.soundID)
            ReleaseSoundId(x.soundID)
            RemoveBlip(x.blip)
        end
    end
end)

function getStatus()
    local Status = false
    if GameState and MyTeam ~= "none" then
        Status = true
    end
	return Status, AllData[MyTeam].center
end