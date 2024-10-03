-- ██╗  ██╗ ██████╗     ██████╗ ███████╗██╗   ██╗███████╗██╗      ██████╗ ██████╗ ███████╗██████╗ 
-- ██║  ██║██╔════╝     ██╔══██╗██╔════╝██║   ██║██╔════╝██║     ██╔═══██╗██╔══██╗██╔════╝██╔══██╗
-- ███████║██║  ███╗    ██║  ██║█████╗  ██║   ██║█████╗  ██║     ██║   ██║██████╔╝█████╗  ██████╔╝
-- ██╔══██║██║   ██║    ██║  ██║██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║     ██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗
-- ██║  ██║╚██████╔╝    ██████╔╝███████╗ ╚████╔╝ ███████╗███████╗╚██████╔╝██║     ███████╗██║  ██║
-- ╚═╝  ╚═╝ ╚═════╝     ╚═════╝ ╚══════╝  ╚═══╝  ╚══════╝╚══════╝ ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝

ESX = exports['es_extended']:getSharedObject()

PoundList = {}
PoundListAllow = {}

-- Fetch Owned Cars
ESX.RegisterServerCallback(GetCurrentResourceName() .. ':getOwnedCars', function(source, cb)
	local ownedCars = {}

	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND job = @job AND stored = @stored ', {
		['@owner']  = GetPlayerIdentifiers(source)[1],
		['@Type']   = 'car',
		['@job']    = '',
		['@stored'] = true
	}, function(data)
		for _,v in pairs(data) do
			table.insert(ownedCars, v)
		end
		cb(ownedCars)
	end)
end)

-- Store Vehicles
ESX.RegisterServerCallback(GetCurrentResourceName() .. ':storeVehicle', function (source, cb, vehicleProps)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local vehplate = vehicleProps.plate
	local vehiclemodel = vehicleProps.model

	MySQL.Async.fetchAll("SELECT * FROM `owned_vehicles` where `plate`=@plate and `owner`=@identifier",{
		['@plate'] = vehplate, 
		['@identifier'] = xPlayer.identifier
	}, function(result)  
		if result[1] ~= nil then
			local veh = json.decode(result[1].vehicle)
			if veh.model == vehiclemodel then
				local vehprop = json.encode(vehicleProps)
				MySQL.Async.execute("UPDATE `owned_vehicles` SET `vehicle`=@vehprop WHERE plate=@plate",{
					['@vehprop'] = vehprop, 
					['@plate'] = vehplate
				})
				cb(true)
			end	
		else
			cb(false)
		end
	end)
end)

-- Fetch Pounded Cars
ESX.RegisterServerCallback(GetCurrentResourceName() .. ':getOutHeli', function(source, cb)
	local ownedCars = {}
	

	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND job = @job' , {
		['@owner']  = GetPlayerIdentifiers(source)[1],
		['@Type']   = 'car',
		['@job']    = 'police',
	}, function(data)
		for _,v in pairs(data) do
			table.insert(ownedCars, v)
		end
		cb(ownedCars)
	end)
end)

ESX.RegisterServerCallback(GetCurrentResourceName() .. ':getOutAm', function(source, cb)
	local ownedCars = {}
	

	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND job = @job' , {
		['@owner']  = GetPlayerIdentifiers(source)[1],
		['@Type']   = 'car',
		['@job']    = 'ambulance',
	}, function(data)
		for _,v in pairs(data) do
			table.insert(ownedCars, v)
		end
		cb(ownedCars)
	end)
end)

ESX.RegisterServerCallback(GetCurrentResourceName() .. ':getOutOwnedCars', function(source, cb)
	local ownedCars = {}
	

	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND stored = @stored AND job = @job ', {
		['@owner']  = GetPlayerIdentifiers(source)[1],
		['@Type']   = 'car',
		['@job']    = '',
		['@stored'] = false
	}, function(data)
		for _,v in pairs(data) do
			table.insert(ownedCars, v)
		end
		cb(ownedCars)
	end)
end)

-- Check Money for Pounded Cars
ESX.RegisterServerCallback(GetCurrentResourceName() .. ':checkMoney', function(source, cb, money)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.getMoney() >= money then
		cb(true)
	else
		cb(false)
	end
end)

-- Pay for Pounded Cars
RegisterServerEvent(GetCurrentResourceName() .. ':payCar')
AddEventHandler(GetCurrentResourceName() .. ':payCar', function(item)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	xPlayer.removeMoney(item.price)
	-- TriggerClientEvent("pNotify:SendNotification",  {
	-- 	    text =  _U('you_paid') .. item.price,
	-- 	    type = "success",
	-- 	    timeout = 2000,
	-- 	    layout = "centerLeft"
	-- 	})

		TriggerClientEvent("mythic_notify:client:SendAlert", source,{
			text =  _U('you_paid') .. item.price,
			type = "success",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
end)

RegisterServerEvent(GetCurrentResourceName() .. ':payCar2')
AddEventHandler(GetCurrentResourceName() .. ':payCar2', function(item)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	xPlayer.removeMoney(Config.PricePound)
	-- TriggerClientEvent("pNotify:SendNotification", source, {
	-- 	    text =  _U('you_paid') .. Config.PricePound,
	-- 	    type = "success",
	-- 	    timeout = 2000,
	-- 	    layout = "centerLeft"
	-- 	})

		TriggerClientEvent("mythic_notify:client:SendAlert", source,{
		    text =  _U('you_paid') .. Config.PricePound,
			type = "success",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
end)

-- Delete for Pounded Cars
RegisterServerEvent(GetCurrentResourceName() .. ':deletePoundCars_SV')
AddEventHandler(GetCurrentResourceName() .. ':deletePoundCars_SV', function(plates)
	TriggerClientEvent(GetCurrentResourceName() .. ':deletePoundCars_CL', -1, plates)
end)

-- Modift Damage Of Vehicles
RegisterServerEvent(GetCurrentResourceName() .. ':modifyDamage')
AddEventHandler(GetCurrentResourceName() .. ':modifyDamage', function(plate, damage)
	local plate = plate
	local health = json.encode(damage)

	MySQL.Async.execute("UPDATE `owned_vehicles` SET `health_vehicles` = @health WHERE `plate`=@plate", {
		['@plate'] = plate,
		['@health'] = health
	})
end)

-- Modify State of Vehicles
RegisterServerEvent(GetCurrentResourceName() .. ':setVehicleState')
AddEventHandler(GetCurrentResourceName() .. ':setVehicleState', function(plate, state)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.execute('UPDATE owned_vehicles SET stored = @stored WHERE plate = @plate', {
		['@stored'] = state,
		['@plate'] = plate
	}, function(rowsChanged)
		if rowsChanged == 0 then
			print((GetCurrentResourceName() .. ': %s exploited the garage!'):format(xPlayer.identifier))
		end
	end)
end)

Citizen.CreateThread(function()
	Wait(5000)
	print('^5'..GetCurrentResourceName()..' ^1: ^2 Verify Success ^1 | ^4HG DEVELOPER TEAM ')
end)