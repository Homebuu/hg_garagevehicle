-- ██╗  ██╗ ██████╗     ██████╗ ███████╗██╗   ██╗███████╗██╗      ██████╗ ██████╗ ███████╗██████╗ 
-- ██║  ██║██╔════╝     ██╔══██╗██╔════╝██║   ██║██╔════╝██║     ██╔═══██╗██╔══██╗██╔════╝██╔══██╗
-- ███████║██║  ███╗    ██║  ██║█████╗  ██║   ██║█████╗  ██║     ██║   ██║██████╔╝█████╗  ██████╔╝
-- ██╔══██║██║   ██║    ██║  ██║██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║     ██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗
-- ██║  ██║╚██████╔╝    ██████╔╝███████╗ ╚████╔╝ ███████╗███████╗╚██████╔╝██║     ███████╗██║  ██║
-- ╚═╝  ╚═╝ ╚═════╝     ╚═════╝ ╚══════╝  ╚═══╝  ╚══════╝╚══════╝ ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝

Config.LoadingGarage = function()
	exports['mythic_progbar']:Progress({
		name = "Garage",
		duration = Config.Checkcar * 1000, 
		label = 'กำลังเก็บรถ',
		useWhileDead = false,
		canCancel = false,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		}
	})
end 

GarageStore = function()
	exports["hg.textui"]:AppleNotific("Press ~INPUT_CONTEXT~ To Open Garage") 
end

StoreCar = function()
	exports["hg.textui"]:AppleNotific("Press ~INPUT_CONTEXT~ Enter To Garage") 
end

PoundStore = function()
	exports["hg.textui"]:AppleNotific("Press ~INPUT_CONTEXT~ To Open Pound") 
end
