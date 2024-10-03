-- ██╗  ██╗ ██████╗     ██████╗ ███████╗██╗   ██╗███████╗██╗      ██████╗ ██████╗ ███████╗██████╗ 
-- ██║  ██║██╔════╝     ██╔══██╗██╔════╝██║   ██║██╔════╝██║     ██╔═══██╗██╔══██╗██╔════╝██╔══██╗
-- ███████║██║  ███╗    ██║  ██║█████╗  ██║   ██║█████╗  ██║     ██║   ██║██████╔╝█████╗  ██████╔╝
-- ██╔══██║██║   ██║    ██║  ██║██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║     ██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗
-- ██║  ██║╚██████╔╝    ██████╔╝███████╗ ╚████╔╝ ███████╗███████╗╚██████╔╝██║     ███████╗██║  ██║
-- ╚═╝  ╚═╝ ╚═════╝     ╚═════╝ ╚══════╝  ╚═══╝  ╚══════╝╚══════╝ ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝

local ESX    			 	  = nil
local PlayerData 			  = {}
local JobBlips 				  = {}
local HasAlreadyEnteredMarker = false
local LastZone                = nil
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local userProperties          = {}
local this_Garage             = {}

local Hanluehe = false

local privateBlips            = {}
local hasAlreadyEnteredMarker, lastZone
local currentAction, currentActionMsg, currentActionData = nil, nil, {}
local Keys 					  = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)

	end
	
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
	refreshBlips()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	refreshBlips()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
	deleteBlips()
	refreshBlips()
end)

local function has_value (tab, val)
	for index, value in ipairs(tab) do
		if value == val then
				return true
		end
	end
	return false
end

-- List Owned Cars Menu
function ListOwnedCarsMenu()
	local elements = {}
	table.insert(elements, {label = 'ถ้ายานพาหนะของคุณไม่ได้อยู่ในโรงเก็บ กรุณาเช็คที่ Impound!!!'})
	
	ESX.TriggerServerCallback(GetCurrentResourceName() .. ':getOwnedCars', function(ownedCars)
		if #ownedCars == 0 then
			-- ESX.ShowNotification(_U('garage_nocars'))
			exports['mythic_notify']:SendAlert('error', 'คุณไม่มีรถในการาจ ! ! !', 3000)
		else
			SetNuiFocus(true, true)

			SendNUIMessage({
				display = true,
			})
			SendNUIMessage({
				clear = true,
			})

			for k,v in pairs(ownedCars) do
				local hashVehicule = json.decode(v.vehicle).model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName = GetLabelText(aheadVehName)
				local labelvehicle
				local plate = k .. '. ' .. v.plate
				local plate2 = v.plate
				local enginpersen = json.decode(v.health_vehicles).health_engine
                local bodypersen = json.decode(v.health_vehicles).health_body
				local fuelpersen = json.decode(v.health_vehicles).fuel
				local fuel = tostring(math.ceil(GetVehicleFuelLevel(fuelpersen)))
                local engine = tostring(math.ceil(enginpersen))
                local body = tostring(math.ceil(bodypersen))

				SendNUIMessage({
					garage = 'car',
					model = aheadVehName,
					plate = plate,
					plate2 = plate2,
					fuel  = fuel,
					engine = engine,
					body = body
				})

				

				if v.stored then
					labelvehicle = '| ' .. plate .. ' | ' .. vehicleName .. ' | ' .. _U('loc_garage') .. ' |'
				else
					labelvehicle = '| ' .. plate .. ' | ' .. vehicleName .. ' | ' .. _U('loc_pound')  .. ' |'
				end
				

				table.insert(elements, {
					label = labelvehicle, 
					vehicle = json.decode(v.vehicle), 
					stored = v.stored, 
					plate = v.plate, 
					damage = json.decode(v.health_vehicles)
				})
			end
		end
	end)
end

RegisterNUICallback('store', function(data, cb)

	ESX.TriggerServerCallback(GetCurrentResourceName() .. ':getOwnedCars', function(ownedCars)
		print(data.zone)
		if #ownedCars == 0 then
			-- ESX.ShowNotification(_U('garage_nocars'))
			exports['mythic_notify']:SendAlert('error', 'คุณไม่มีรถในการาจ ! ! !', 3000)
		else
			for _,v in pairs(ownedCars) do
			local cb_veh = nil
				local hashVehicule = json.decode(v.vehicle).model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName = GetLabelText(aheadVehName)
				local labelvehicle
				local fuelpersen = json.decode(v.health_vehicles)
				local fuel = tostring(math.ceil(GetVehicleFuelLevel(fuelpersen.fuel)))
				local plate = v.plate
				if data.item == json.decode(v.vehicle).plate then
						SpawnVehicle(json.decode(v.vehicle) , v.plate, json.decode(v.health_vehicles))
						Citizen.Wait(50)
						Handw()
						Hanluehe = true
						Citizen.Wait(Config.Checkcar *1000)
						Hanluehe = false
						ClearPedTasks(ped)
				
				end	
			end
		end
	end)
end)

RegisterNUICallback('focusOff', function(data, cb)
	SetNuiFocus(false, false)
end)

-- Store Owned Cars Menu
-- function StoreOwnedCarsMenu()
-- 	local playerPed  = GetPlayerPed(-1)
-- 	local vehicle =	GetVehiclePedIsIn(playerPed, false)
-- 	local DSMSS = GetVehiclePedIsIn(playerPed, false)
-- 	local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)
-- 	local coords = GetEntityCoords(PlayerPedId())
-- 	SendNUIMessage({
-- 		sound = true,
-- 	})
-- 	Play(coords)
	
-- 	ESX.TriggerServerCallback(GetCurrentResourceName() .. ':storeVehicle',function(valid)
-- 		if(valid) then
-- 			ESX.TriggerServerCallback(GetCurrentResourceName() .. ':checkMoney', function(hasEnoughMoney)
-- 				if hasEnoughMoney then
-- 					SaveDamage(vehicle, vehicleProps)
-- 					DeleteEntity(vehicle)
-- 					TriggerServerEvent(GetCurrentResourceName() .. ':setVehicleState', vehicleProps.plate, true)
-- 					TriggerEvent("mythic_notify:client:SendAlert", {
-- 						text = 'เก็บรถของคุณเรียบร้อยแล้ว',
-- 						type = "success",
-- 						timeout = 3000,
-- 						layout = "bottomCenter",
-- 						queue = "global"
-- 					})
-- 					-- TriggerEvent("mythic_notify:client:SendAlert", {
-- 					-- 	text = 'เก็บรถของคุณเรียบร้อยแล้ว จ่าย '..Config.Price..'',
-- 					-- 	type = "success",
-- 					-- 	timeout = 3000,
-- 					-- 	layout = "bottomCenter",
-- 					-- 	queue = "global"
-- 					-- })
-- 				else
-- 					TriggerEvent("mythic_notify:client:SendAlert", {
-- 						text = 'คุณไม่มีเงินเพียงพอ',
-- 						type = "error",
-- 						timeout = 3000,
-- 						layout = "bottomCenter",
-- 						queue = "global"
-- 					})		
-- 				end
-- 			end)
-- 			-- end, Config.Price)
-- 		else
-- 			TriggerEvent("mythic_notify:client:SendAlert", {
-- 				text = 'คุณไม่สามารถจัดเก็บยานพาหนะนี้ได้ เนื่องจากคุณไม่ใช่เจ้าของ',
-- 				type = "error",
-- 				timeout = 3000,
-- 				layout = "bottomCenter",
-- 				queue = "global"
-- 			})
-- 		end
-- 	end, vehicleProps)
-- end

function StoreOwnedCarsMenu()
	local playerPed  = GetPlayerPed(-1)
	local vehicle =	GetVehiclePedIsIn(playerPed, false)
	local DSMSS = GetVehiclePedIsIn(playerPed, false)
	local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)
	local coords = GetEntityCoords(PlayerPedId())
	SendNUIMessage({
		sound = true,
	})

	ESX.TriggerServerCallback(GetCurrentResourceName() .. ':storeVehicle',function(valid)
		if(valid) then
				SaveDamage(vehicle, vehicleProps)
				DeleteEntity(vehicle)
				TriggerServerEvent(GetCurrentResourceName() .. ':setVehicleState', vehicleProps.plate, true)
				TriggerEvent("mythic_notify:client:SendAlert", {
					text = 'เก็บรถของคุณเรียบร้อยแล้ว',
					type = "success",
					timeout = 3000,
				})
				
				
		else
			TriggerEvent("mythic_notify:client:SendAlert", {
				text = 'คุณไม่สามารถจัดเก็บยานพาหนะนี้ได้ เนื่องจากคุณไม่ใช่เจ้าของ',
				type = "error",
				timeout = 3000,
			})
		end
	end, vehicleProps)
end

Play = function(coord)
	if Config.OnEffect then
		PlayEffect(Config.TypePT, Config.particle, coord.x, coord.y, coord.z, Config.Size)
	end
end

-- Spawn Cars
function SpawnVehicle(vehicle, plate, damage)
	if Config.Delay.Enable then
		Delay()
	end
	
	local cb_veh = nil
	ESX.Game.SpawnVehicle(vehicle.model, {
		x = this_Garage.SpawnPoint.x,
		y = this_Garage.SpawnPoint.y,
		z = this_Garage.SpawnPoint.z + 1
	}, this_Garage.SpawnPoint.h, function(callback_vehicle)
		ESX.Game.SetVehicleProperties(callback_vehicle, vehicle)
		cb_veh = callback_vehicle
		SetDamage(callback_vehicle, damage)
		SetVehRadioStation(callback_vehicle, "OFF")
		Play(this_Garage.SpawnPoint)
		TaskWarpPedIntoVehicle(PlayerPedId(), callback_vehicle, -1)
		SetVehicleFuelLevel(cb_veh, damage.fuel)
		DecorSetFloat(cb_veh, '_FUEL_LEVEL', GetVehicleFuelLevel(cb_veh))
	end)

	TriggerServerEvent(GetCurrentResourceName() .. ':setVehicleState', plate, false)
	Wait(500)
end

function SpawnVehicle2(vehicle, plate)
	if Config.Delay.Enable then
		Delay()
	end
	
	local cb_veh = nil

	ESX.Game.SpawnVehicle(vehicle.model, {
		x = this_Garage.SpawnPoint.x,
		y = this_Garage.SpawnPoint.y,
		z = this_Garage.SpawnPoint.z + 1
	}, this_Garage.SpawnPoint.h, function(callback_vehicle)
		ESX.Game.SetVehicleProperties(callback_vehicle, vehicle)
		cb_veh = callback_vehicle
		SetVehRadioStation(callback_vehicle, "OFF")
		PlayEffect(Config.TypePT, Config.particle, this_Garage.SpawnPoint.x, this_Garage.SpawnPoint.y, this_Garage.SpawnPoint.z, Config.Size)
		TaskWarpPedIntoVehicle(PlayerPedId(), callback_vehicle, -1)

	end)
	
    TriggerServerEvent(GetCurrentResourceName() .. ':setVehicleState', plate, false)
    Wait(500) -- รอเวลา 5 วินาที
end


function Delay()
	TriggerEvent('mythic_progbar:client:progress', {
        name = 'getting_a_car',
        duration = Config.Delay.Length,
        label = 'กำลังเบิกรถ',
        useWhileDead = false,
        canCancel = false,
        controlDisables = {
        	disableMovement = true,
        	disableCarMovement = true,
        	disableMouse = false,
        	disableCombat = true,
        },
     	-- animation = {}
  	}, function(status)
  		if not status then
  		    -- Do Something If Event Wasn't Cancelled
  		end
  	end)

  	Citizen.Wait(Config.Delay.Length)
end


-- Set Damage Cars
function SetDamage(callback_vehicle, damage)
	SetVehicleEngineHealth(callback_vehicle, damage.health_engine + 0.0 or 1000.0)
	SetVehicleBodyHealth(callback_vehicle, damage.health_body + 0.0 or 1000.0)

	if damage.tyres then
		for tyreId = 1, 7, 1 do
			if damage.tyres[tyreId] ~= false then
				SetVehicleTyreBurst(callback_vehicle, tyreId, true, 1000)
			end
		end
	end

	if damage.doors then
		for doorId = 0, 5, 1 do
			if damage.doors[doorId] ~= false then
				SetVehicleDoorBroken(callback_vehicle, doorId - 1, true)
			end
		end
	end
end

-- Delete for Pounded Cars
RegisterNetEvent(GetCurrentResourceName() .. ':deletePoundCars_CL')
AddEventHandler(GetCurrentResourceName() .. ':deletePoundCars_CL', function(plates)
	SpawnPoundDelete(plates)
end)

-- Spawn Pound Delete
function SpawnPoundDelete(plate)
	for key, vehicle in pairs(ESX.Game.GetVehicles()) do
		local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)

		if vehicleProps.plate == plate then
			SetVehicleHasBeenOwnedByPlayer(vehicle, false) 
			SetEntityAsMissionEntity(vehicle, false, false) 
			DeleteVehicle(vehicle)
		end
    end
end

-- RegisterCommand("IPCH-Garage", function(source, args)
-- 	local ped = PlayerPedId()
	
-- 	Citizen.CreateThread(function()
-- 		pos = GetEntityCoords(ped)
-- 		heading = GetEntityHeading(ped)
		
-- 		local text = string.format("{ x = %.2f, y = %.2f, z = %.2f, h = %.2f },", pos.x, pos.y, pos.z, heading)
-- 		SendNUIMessage({
-- 			type = "copy-clipboard",
-- 			text = text
-- 		})
-- 		print(text)
-- 		TriggerEvent("mythic_notify:client:SendAlert", {
-- 			text = 'คัดลอกพิกัด' .. text,
-- 			type = "error",
-- 			timeout = 3000,
-- 			layout = "bottomCenter",
-- 			queue = "global"
-- 		})
-- 	end)
-- end, true)

-- RegisterCommand("dbj", function(source, args)
-- 	local ped = PlayerPedId()
	
-- 	Citizen.CreateThread(function()
-- 		pos = GetEntityCoords(ped)
-- 		heading = GetEntityHeading(ped)
		
-- 		local text = string.format("tablePos = vector3(%.2f, %.2f, %.2f), tableHeading = %.2f,", pos.x, pos.y, pos.z, heading)
-- 		SendNUIMessage({
-- 			type = "copy-clipboard",
-- 			text = text
-- 		})
-- 		print(text)
-- 		TriggerEvent("mythic_notify:client:SendAlert", {
-- 			text = 'คัดลอกพิกัด' .. text,
-- 			type = "error",
-- 			timeout = 3000,
-- 			layout = "bottomCenter",
-- 			queue = "global"
-- 		})
-- 	end)
-- end, true)

-- Save Damage Cars
function SaveDamage(vehicle, vehicleProps)
	local damage = {}
	damage.tyres = {}
	damage.doors = {}

	for id = 1, 7 do
		local tyreId = IsVehicleTyreBurst(vehicle, id, false)
	
		if tyreId then
			damage.tyres[#damage.tyres + 1] = tyreId
	
			if tyreId == false then
				tyreId = IsVehicleTyreBurst(vehicle, id, true)
				damage.tyres[ #damage.tyres] = tyreId
			end
		else
			damage.tyres[#damage.tyres + 1] = false
		end
	end
	
	for id = 0, 5 do
		local doorId = IsVehicleDoorDamaged(vehicle, id)
	
		if doorId then
			damage.doors[#damage.doors + 1] = doorId
		else
			damage.doors[#damage.doors + 1] = false
		end
	end

	damage.fuel = GetVehicleFuelLevel(vehicle)
	damage.health_engine = GetVehicleEngineHealth(vehicle)
	damage.health_body = GetVehicleBodyHealth(vehicle)
	TriggerServerEvent(GetCurrentResourceName() .. ':modifyDamage', vehicleProps.plate, damage)
end


-- Draw Markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		
		local playerPed = PlayerPedId()
		local coords    = GetEntityCoords(playerPed)
		local canSleep  = true
		local flash = 0
        local flashColor = 1
        local lastFlash = GetGameTimer()

		if Config.UseCarGarages == true then
			-- Car Garages
			for k,v in pairs(Config.CarGarages) do
				if (GetDistanceBetweenCoords(coords, v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z, true) < Config.DrawDistance) then
					canSleep = false
					if IsPedInAnyVehicle(PlayerPedId(), true) == false then
						DrawMarker(Config.PointMarker.type, v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.PointMarker.x, Config.PointMarker.y, Config.PointMarker.z, Config.PointMarker.r, Config.PointMarker.g, Config.PointMarker.b, 100, false, true, 2, false, false, false, false)
						-- ทำให้ Marker เลือนแสง
						 if (GetGameTimer() - lastFlash) >= 1000 then -- ปรับตัวเลขตรงนี้เพื่อเปลี่ยนความถี่ในการสลับสี
							lastFlash = GetGameTimer()
							if flashColor == 1 then
								SetMarkerColor(Config.PointMarker.type, 255, 0, 0, 255) -- ปรับสีตามต้องการ
								flashColor = 2
							elseif flashColor == 2 then
								SetMarkerColor(Config.PointMarker.type, 0, 255, 0, 255) -- ปรับสีตามต้องการ
								flashColor = 3
							elseif flashColor == 3 then
								SetMarkerColor(Config.PointMarker.type, 0, 0, 255, 255) -- ปรับสีตามต้องการ
								flashColor = 1
							end
						end
					else
						if v.DeletePoint then
							DrawMarker(Config.DeleteMarker.type, v.DeletePoint.x, v.DeletePoint.y, v.DeletePoint.z - 1, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.DeleteMarker.x, Config.DeleteMarker.y, Config.DeleteMarker.z, Config.DeleteMarker.r, Config.DeleteMarker.g, Config.DeleteMarker.b, 100, false, true, 2, false, false, false, false)	
						end
					end
				end
			end

			for k,v in pairs(Config.CarPounds) do
				if (GetDistanceBetweenCoords(coords, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, true) < Config.DrawDistance) then
					canSleep = false
					if IsPedInAnyVehicle(PlayerPedId(), true) == false then
						DrawMarker(Config.PoundMarker.type, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.PoundMarker.x, Config.PoundMarker.y, Config.PoundMarker.z, Config.PoundMarker.r, Config.PoundMarker.g, Config.PoundMarker.b, 100, false, true, 2, false, false, false, false)
					end
				end
			end
			for k,v in pairs(Config.PoPoint) do
				if ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' then
					if (GetDistanceBetweenCoords(coords, v.PoPoint.x, v.PoPoint.y, v.PoPoint.z, true) < Config.DrawDistance) then
						canSleep = false
						if IsPedInAnyVehicle(PlayerPedId(), true) == false then
							DrawMarker(Config.PoMarker.type, v.PoPoint.x, v.PoPoint.y, v.PoPoint.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.PoMarker.x, Config.PoMarker.y, Config.PoMarker.z, Config.PoMarker.r, Config.PoMarker.g, Config.PoMarker.b, 100, false, true, 2, false, false, false, false)
						end
					end
				end
			end

			for k,v in pairs(Config.AmPoint) do
				if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' then
					if (GetDistanceBetweenCoords(coords, v.AmPoint.x, v.AmPoint.y, v.AmPoint.z, true) < Config.DrawDistance) then
						canSleep = false
						if IsPedInAnyVehicle(PlayerPedId(), true) == false then
							DrawMarker(Config.AmMarker.type, v.AmPoint.x, v.AmPoint.y, v.AmPoint.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.AmMarker.x, Config.AmMarker.y, Config.AmMarker.z, Config.AmMarker.r, Config.AmMarker.g, Config.AmMarker.b, 100, false, true, 2, false, false, false, false)
						end
					end
				end
			end
		end
		
		if canSleep then
            Citizen.Wait(500)
        end
	end
end)

-- Activate Menu when in Markers
Citizen.CreateThread(function()
	local currentZone = 'garage'
	local zone = 'garage'
	while true do
		Citizen.Wait(0)
		local playerPed  = PlayerPedId()
		local coords     = GetEntityCoords(playerPed)
		local isInMarker = false
		
		if Config.UseCarGarages == true then
			-- Car Garages
			for k,v in pairs(Config.CarGarages) do
				if (GetDistanceBetweenCoords(coords, v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z, true) < Config.PointMarker.x) and IsPedInAnyVehicle(PlayerPedId(), true) == false then
					GarageStore()
					isInMarker  = true
					this_Garage = v
					currentZone = 'car_garage_point'
				end
				
				if v.DeletePoint then
					if(GetDistanceBetweenCoords(coords, v.DeletePoint.x, v.DeletePoint.y, v.DeletePoint.z, true) < Config.DeleteMarker.x) and IsPedInAnyVehicle(PlayerPedId(), true) then
						StoreCar()
						isInMarker  = true
						this_Garage = v
						currentZone = 'car_store_point'
					end
				end
			end
			
			-- Car Pounds
			for k,v in pairs(Config.CarPounds) do
				if (GetDistanceBetweenCoords(coords, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, true) < Config.PoundMarker.x) and IsPedInAnyVehicle(PlayerPedId(), true) == false then
					PoundStore()
					isInMarker  = true
					this_Garage = v
					currentZone = 'car_pound_point'
				end
			end

			

			
		else
			Citizen.Wait(500)
			
			-- Car Pounds
		end
		
		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			LastZone                = currentZone
			zone 					= currentZone



			if zone == 'car_garage_point' then
				CurrentAction     = 'car_garage_point'
				CurrentActionMsg  = _U('press_to_enter')
				CurrentActionData = {}
			elseif zone == 'car_pound_point' then
				CurrentAction     = 'car_pound_point'
				CurrentActionMsg  = _U('press_to_impound')
				CurrentActionData = {}
			elseif zone == 'car_store_point' then
				CurrentAction     = 'car_store_point'
				CurrentActionMsg  = _U('press_to_delete')
				CurrentActionData = {}
			end
		end
		
		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false		
			ESX.UI.Menu.CloseAll()
			CurrentAction = nil
		end
		
		if not isInMarker then
            Citizen.Wait(500)
        end
	end
end)
	
-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed  = PlayerPedId()
    	local coords = GetEntityCoords(PlayerPedId())
		
		if CurrentAction ~= nil then
		
		--	exports["hg.textui"]:AppleNotific("Press ~INPUT_CONTEXT~ To Open Garage") 
			
			if IsControlJustReleased(0, Keys['E']) then
				if CurrentAction == 'car_garage_point' then
					ListOwnedCarsMenu()
				elseif CurrentAction == 'car_pound_point' then
					ReturnOwnedCarsMenu()
				elseif CurrentAction == 'car_store_point' then
					Config.LoadingGarage()
					Wait(Config.Checkcar*1000)
					StoreOwnedCarsMenu()  
				    CurrentAction = nil
				end 
			end
		else
			Citizen.Wait(500)
		end
	end
end)

-- Blips
function deleteBlips()
	if JobBlips[1] ~= nil then
		for i=1, #JobBlips, 1 do
			RemoveBlip(JobBlips[i])
			JobBlips[i] = nil
		end
	end
end

--Citizen.CreateThread(function()
function refreshBlips()
	local blipList = {}
	local JobBlips = {}

	if Config.UseCarGarages == true then
		-- Car Garages
		for k,v in pairs(Config.CarGarages) do
			if v.Blips then
				table.insert(blipList, {
					coords = { v.GaragePoint.x, v.GaragePoint.y },
					text   = _U('blip_garage'),
					sprite = Config.BlipGarage.Sprite,
					color  = Config.BlipGarage.Color,
					scale  = Config.BlipGarage.Scale
				})
			end
		end

		for k,v in pairs(Config.CarPounds) do
			table.insert(blipList, {
				coords = { v.PoundPoint.x, v.PoundPoint.y },
				text   = _U('blip_pound'),
				sprite = Config.BlipPound.Sprite,
				color  = Config.BlipPound.Color,
				scale  = Config.BlipPound.Scale
			})
		end
		
	end

	for i=1, #blipList, 1 do
		CreateBlip(blipList[i].coords, blipList[i].text, blipList[i].sprite, blipList[i].color, 0.6)
	end
end

function CreateBlip(coords, text, sprite, color, scale)
	local blip = AddBlipForCoord( table.unpack(coords) )

	SetBlipSprite(blip, sprite)
	SetBlipScale(blip, scale)
	SetBlipColour(blip, color)

	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandSetBlipName(blip)
	table.insert(JobBlips, blip)
end

local entityEnumerator = {
	__gc = function(enum)
	  if enum.destructor and enum.handle then
		enum.destructor(enum.handle)
	  end
	  enum.destructor = nil
	  enum.handle = nil
	end
}
  
local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
	  local iter, id = initFunc()
	  if not id or id == 0 then
		disposeFunc(iter)
		return
	  end
	  
	  local enum = {handle = iter, destructor = disposeFunc}
	  setmetatable(enum, entityEnumerator)
	  
	  local next = true
	  repeat
		coroutine.yield(id)
		next, id = moveFunc(iter)
	  until not next
	  
	  enum.destructor, enum.handle = nil, nil
	  disposeFunc(iter)
	end)
end
  
function EnumerateObjects()
	return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function EnumeratePeds()
	return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
	return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function EnumeratePickups()
	return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end



-- Pound Owned Cars Menu
function ReturnOwnedCarsMenu()
	ESX.TriggerServerCallback(GetCurrentResourceName()..':getOutOwnedCars', function(ownedCars)
		local elements = {}
		if #ownedCars == 0 then
			-- ESX.ShowNotification(_U('garage_nocars'))
			exports['mythic_notify']:SendAlert('error', 'คุณไม่มีรถในการาจ ! ! !', 3000)
		else
			SendNUIMessage({
				clear = true,
			})

			SetNuiFocus(true, true)

			SendNUIMessage({
				display = true,
			})

			for k,v in pairs(ownedCars) do
				local hashVehicule = json.decode(v.vehicle).model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName = GetLabelText(aheadVehName)
				local labelvehicle
				local plate = k..'. '..v.plate
				local plate2 = v.plate
				local enginpersen = json.decode(v.health_vehicles).health_engine
                local bodypersen = json.decode(v.health_vehicles).health_body
                local fuelpersen = json.decode(v.health_vehicles).fuel
                local fuel = tostring(math.ceil(GetVehicleFuelLevel(fuelpersen)))
                local engine = tostring(math.ceil(GetVehicleFuelLevel(enginpersen)))
                local body = tostring(math.ceil(GetVehicleFuelLevel(bodypersen)))


				SendNUIMessage({
					garage = 'pound',
					model = aheadVehName,
					plate = plate,
					fuel  = fuel,
					plate2 = plate2,
					engine = engine,
					body = body,
				})

				if v.stored then
					labelvehicle = '| ' .. plate .. ' | ' .. vehicleName .. ' | ' .. _U('loc_garage') .. ' |'
				else
					labelvehicle = '| ' .. plate .. ' | ' .. vehicleName .. ' | ' .. _U('loc_pound')  .. ' |'
				end

				table.insert(elements, {label = labelvehicle, vehicle = json.decode(v.vehicle), stored = v.stored, plate = v.plate, damage = json.decode(v.health_vehicles)})
			end
		end
	end)
end


RegisterNUICallback('string', function(data, cb)

	ESX.TriggerServerCallback(GetCurrentResourceName()..':getOutOwnedCars', function(ownedCars)
		if #ownedCars == 0 then
			-- ESX.ShowNotification(_U('garage_nocars'))
			exports['mythic_notify']:SendAlert('error', 'คุณไม่มีรถในการาจ ! ! !', 3000)
		else
			for _,v in pairs(ownedCars) do
				local hashVehicule = json.decode(v.vehicle).model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName = GetLabelText(aheadVehName)
				local labelvehicle
				local plate = v.plate
				ESX.TriggerServerCallback(GetCurrentResourceName() .. ':checkMoney', function(hasEnoughMoney)
					if hasEnoughMoney then
							if not status then
								if data.item == json.decode(v.vehicle).plate then

									TriggerServerEvent(GetCurrentResourceName() .. ':payCar2', { price = Config.PricePound})
									TriggerServerEvent(GetCurrentResourceName() .. ':deletePoundCars_SV', v.plate)
									Config.SpawnPoundWait();
									if Config.Fz then
										Citizen.Wait(50)
										SpawnVehicle2(json.decode(v.vehicle) , v.plate, json.decode(v.health_vehicles))
										Citizen.Wait(50)
										Handw()
										Hanluehe = true
										Citizen.Wait(Config.Checkcar *1000)
										Hanluehe = false
										ClearPedTasks(ped)
									else
										Citizen.Wait(200)
										SpawnVehicle(json.decode(v.vehicle) , v.plate, json.decode(v.health_vehicles))
										Citizen.Wait(50)
										Handw()
										Hanluehe = true
										Citizen.Wait(Config.Checkcar *1000)
										Hanluehe = false
										ClearPedTasks(ped)
									end
									
								end
							end
					else
						TriggerEvent("mythic_notify:client:SendAlert", {
							text = 'คุณมีไม่เงินเพียงพอ',
							type = "error",
							timeout = 3000,
							layout = "bottomCenter",
							queue = "global"
						})		
					end
				end, Config.Price)
			end
		end
	end)
end)

function GetHeli()
	ESX.TriggerServerCallback(GetCurrentResourceName()..':getOutHeli', function(ownedCars)
		local elements = {}
		if #ownedCars == 0 then
			-- ESX.ShowNotification(_U('garage_nocars'))
			exports['mythic_notify']:SendAlert('error', 'คุณไม่มีรถในการาจ ! ! !', 3000)
		else
			SendNUIMessage({
				clear = true,
			})

			SetNuiFocus(true, true)

			SendNUIMessage({
				display = true,
			})

			for k,v in pairs(ownedCars) do
				local hashVehicule = json.decode(v.vehicle).model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName = GetLabelText(aheadVehName)
				local labelvehicle
				local plate = k..'. '..v.plate
				local plate2 = v.plate
				local enginpersen = json.decode(v.health_vehicles).health_engine
                local bodypersen = json.decode(v.health_vehicles).health_body
                local fuelpersen = json.decode(v.health_vehicles).fuel
                local fuel = tostring(math.ceil(GetVehicleFuelLevel(fuelpersen)))
                local engine = tostring(math.ceil(GetVehicleFuelLevel(enginpersen)))
                local body = tostring(math.ceil(GetVehicleFuelLevel(bodypersen)))


				SendNUIMessage({
					garage = 'police',
					model = aheadVehName,
					plate2 = plate2,
					plate = plate,
					fuel  = fuel,
					engine = engine,
					body = body,
				})

				if v.stored then
					labelvehicle = '| ' .. plate .. ' | ' .. vehicleName .. ' | ' .. _U('loc_garage') .. ' |'
				else
					labelvehicle = '| ' .. plate .. ' | ' .. vehicleName .. ' | ' .. _U('loc_pound')  .. ' |'
				end

				table.insert(elements, {label = labelvehicle, vehicle = json.decode(v.vehicle), stored = v.stored, plate = v.plate, damage = json.decode(v.health_vehicles)})
			end
		end
	end)
end


RegisterNUICallback('stue', function(data, cb)

	ESX.TriggerServerCallback(GetCurrentResourceName()..':getOutHeli', function(ownedCars)
		if #ownedCars == 0 then
			-- ESX.ShowNotification(_U('garage_nocars'))
			exports['mythic_notify']:SendAlert('error', 'คุณไม่มีรถในการาจ ! ! !', 3000)
		else
			for _,v in pairs(ownedCars) do
				local hashVehicule = json.decode(v.vehicle).model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName = GetLabelText(aheadVehName)
				local labelvehicle
				local plate = v.plate
				if data.item == json.decode(v.vehicle).plate then
					TriggerServerEvent(GetCurrentResourceName() .. ':deletePoundCars_SV', v.plate)
					Citizen.Wait(50)
					SpawnVehicle2(json.decode(v.vehicle) , v.plate)
					Citizen.Wait(50)
					Handw()
					Hanluehe = true
					Citizen.Wait(Config.Checkcar *1000)
					Hanluehe = false
					ClearPedTasks(ped)
				end
			end
		end
	end)
end)


function GetAm()
	ESX.TriggerServerCallback(GetCurrentResourceName()..':getOutAm', function(ownedCars)
		local elements = {}
		if #ownedCars == 0 then
			-- ESX.ShowNotification(_U('garage_nocars'))
			exports['mythic_notify']:SendAlert('error', 'คุณไม่มีรถในการาจ ! ! !', 3000)
		else
			SendNUIMessage({
				clear = true,
			})

			SetNuiFocus(true, true)

			SendNUIMessage({
				display = true,
			})

			for k,v in pairs(ownedCars) do
				local hashVehicule = json.decode(v.vehicle).model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName = GetLabelText(aheadVehName)
				local labelvehicle
				local plate = k..'. '..v.plate
				local plate2 = v.plate
				local enginpersen = json.decode(v.health_vehicles).health_engine
                local bodypersen = json.decode(v.health_vehicles).health_body
                local fuelpersen = json.decode(v.health_vehicles).fuel
                local fuel = tostring(math.ceil(GetVehicleFuelLevel(fuelpersen)))
                local engine = tostring(math.ceil(GetVehicleFuelLevel(enginpersen)))
                local body = tostring(math.ceil(GetVehicleFuelLevel(bodypersen)))


				SendNUIMessage({
					garage = 'ambulance',
					plate2 = plate2,
					model = aheadVehName,
					plate = plate,
					fuel  = fuel,
					engine = engine,
					body = body,
				})

				if v.stored then
					labelvehicle = '| ' .. plate .. ' | ' .. vehicleName .. ' | ' .. _U('loc_garage') .. ' |'
				else
					labelvehicle = '| ' .. plate .. ' | ' .. vehicleName .. ' | ' .. _U('loc_pound')  .. ' |'
				end

				table.insert(elements, {label = labelvehicle, vehicle = json.decode(v.vehicle), stored = v.stored, plate = v.plate, damage = json.decode(v.health_vehicles)})
			end
		end
	end)
end


RegisterNUICallback('step', function(data, cb)

	ESX.TriggerServerCallback(GetCurrentResourceName()..':getOutAm', function(ownedCars)
		if #ownedCars == 0 then
			-- ESX.ShowNotification(_U('garage_nocars'))
			exports['mythic_notify']:SendAlert('error', 'คุณไม่มีรถในการาจ ! ! !', 3000)
		else
			for _,v in pairs(ownedCars) do
				local hashVehicule = json.decode(v.vehicle).model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName = GetLabelText(aheadVehName)
				local labelvehicle
				local plate = v.plate
				if data.item == json.decode(v.vehicle).plate then
					TriggerServerEvent(GetCurrentResourceName() .. ':deletePoundCars_SV', v.plate)
					Citizen.Wait(50)
					SpawnVehicle2(json.decode(v.vehicle) , v.plate)
					Citizen.Wait(50)
					Handw()
					Hanluehe = true
					Citizen.Wait(Config.Checkcar *1000)
					Hanluehe = false
					ClearPedTasks(ped)
				end
			end
		end
	end)
end)


function Handw()
	Citizen.CreateThread(function()
		while true do
			local player = GetPlayerFromServerId(k)
        	local Fz = GetPlayerPed(player)
        	local coords = GetEntityCoords(Fz)
			local ped = PlayerPedId()
			Citizen.Wait(0)
			if Hanluehe then
				DisableControlAction(0, 63, true) -- veh turn left
        		DisableControlAction(0, 64, true) -- veh turn right
        		DisableControlAction(0, 71, true) -- veh forward
        		DisableControlAction(0, 72, true) -- veh backwards
        		DisableControlAction(0, 75, true) -- disable exit vehicle
			else
				Citizen.Wait(500)
			end
		
		end
	end)
end

function Handw()
	Citizen.CreateThread(function()
		while true do
			local player = GetPlayerFromServerId(k)
        	local Fz = GetPlayerPed(player)
        	local coords = GetEntityCoords(sek)
			local ped = PlayerPedId()
			Citizen.Wait(0)
			if Hanluehe then
				DisableControlAction(0, 63, true) -- veh turn left
        		DisableControlAction(0, 64, true) -- veh turn right
        		DisableControlAction(0, 71, true) -- veh forward
        		DisableControlAction(0, 72, true) -- veh backwards
        		DisableControlAction(0, 75, true) -- disable exit vehicle
			else
				Citizen.Wait(500)
			end
		
		end
	end)
end


function PlayEffect(pdict, pname, posx, posy, posz, size)   
    UseParticleFxAssetNextCall(pdict)
    local PlayerPed = GetPlayerPed(-1)
    local pfx = StartParticleFxLoopedAtCoord(pname, posx, posy, posz, 20.0, 20.0, GetEntityHeading(PlayerPedId()), size, true, true, true, false)
    Citizen.Wait(100)
    StopParticleFxLooped(pfx, 0)
end

