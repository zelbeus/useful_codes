--Show Messages At bottom of the screen
-------------------------
function ShowMsgBottom(msg)--create the function
	local txt = ''--create an empty string
	local size = 1.5 --set the size of the text that will be shown
	if msg ~= nil then --check the message given to the function
		txt = msg --txt variables is now the message
	else
		txt = ' '--if msg was not added, txt is string
	end
    SetTextScale(size, size)--Set the text size
    local str = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", txt, Citizen.ResultAsLong())--create the variable to shown
    Citizen.InvokeNative(0xFA233F8FE190514C, str)--show the string variable
    Citizen.InvokeNative(0xE9990552DEC71600)
end
-------------------------
--Usage Example
-------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		ShowMsgBottom("Hello, I am a message!")--Here is the function
	end
end)
-------------------------
--Check if player is at coords and in distance
-------------------------
function IsPlayerClosetoCoord(v3,distance)--create the function
	if v3 ~= nil then--if first param valid
		if distance == nil then --if distance is 0 then default will be 2.0
			distance = 2.0
		else
			local pcoords = GetEntityCoords(PlayerPedId(),true)--Get the Coords of player
			if (GetDistanceBetweenCoords(pcoords.x, pcoords.y, pcoords.z, v3, true) < distance) then--Checks the 2 coords and distance
				return true --function returns true if the 2 coords are in given/default distance 
			else
				return false--function returns false if the 2 coords are not in given/default distance 
			end
		end
	end
end
-------------------------
--Using example
-------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		if IsPlayerClosetoCoord(vector3(4.0,4.0,4.0),5.0) then
			print("I am close to (4.0,4.0,4.0) in distance 5.0")--every 500ms it will print the message given
		end
	end
end)
-------------------------
--Is key Pushed?
-------------------------
function IsControl(control)
    if Citizen.InvokeNative(0x580417101DDB492F, 0, control) then
        return true
    else
        return false
    end
end
-------------------------
--Using example
-------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		if IsControl(anyControl) then
			print("A controll pressed")
		end
	end
end)
-------------------------
--NPC Spawn with command /npc hash scale - Example - /npc a_c_badger_01 2.0 spawns a double sized badger and freezes in position. Ped will be deleted upon spawning new one with the command
-------------------------
local npc = nil--create a variable, so npc can be deleted
RegisterCommand("npc", function(source, args, raw)--command to spawn
	if args[1] ~= nil and args[2] ~= nil then
		local num = args[1]
		local _scale = tonumber(args[2])
		TriggerEvent("npc:spawn",num, _scale)
	else
		print("Usage: /npc pedmodelname size - /npc a_c_badger_01 2.0")
	end
end,false)

RegisterNetEvent('npc:spawn')
AddEventHandler('npc:spawn', function(num1,num2)
    local pped = PlayerPedId() --Get Player Ped
    local _num1 = tostring(num1) --First Param will be a string
    local _num2 = tonumber(num2) --Second Param is a number
    if _num1 ~= nil then --If model is not nil
        if npc then --If the ped exists
            DeleteEntity(npc)--Delete the existing ped
        end
        local animalHash = GetHashKey(_num1) --Get the Has key of the First param
        if not IsModelValid(animalHash) then --If model is not valid, function returns
            return
        end
        RequestModel(animalHash) --Request the model's hash
        while not HasModelLoaded(animalHash) do --wait till model loads
            Citizen.Wait(0)
        end
		local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(pped, 0.0, 4.0, 0.5)) --Get Coords front of player
        npc = CreatePed(animalHash, x, y, z, GetEntityHeading(pped)+90, 1, 0) --create the npc
        Citizen.InvokeNative(0x283978A15512B2FE, npc, true) --set random outfit
        Citizen.InvokeNative(0x25ACFC650B65C538,npc,_num3) -- set the scale, second param used
		while not Citizen.InvokeNative(0xA0BC8FAED8CFEB3C,npc) do --wait till outfit loads
			Citizen.Wait(0)
		end
		Citizen.InvokeNative(0x704C908E9C405136, npc)
		Citizen.InvokeNative(0xAAB86462966168CE, npc, 1)
        Citizen.Wait(500)
        FreezeEntityPosition(npc, true)--Freeze the npc in position
    else
        print("Model not found.")--debug if first param is not valid
    end
end)
-------------------------
--Object Spawn with command
-------------------------
local object1 = nil--create variable, so object can be deleted
RegisterCommand("object", function(source, args, raw) --create the command, usage: /object objecthash
    local name = args[1]
    TriggerEvent("object:spawn",name)
end,false)

RegisterNetEvent('object:spawn')
AddEventHandler('object:spawn', function(model)
    local pped = PlayerPedId()--Get Player Ped
    local _model = tostring(model)--create string
    if object1 then --if objects exists
        DeleteObject(object1) --delete object
    end
    if _model ~= nil then --if model is valid param
        local animalHash = GetHashKey(_model)--create variable for hash
        if not IsModelValid(animalHash) then--check if model is valid, else return
            return
        end
        RequestModel(animalHash)--request the given model
        while not HasModelLoaded(animalHash) do--wait till model is loaded
            Citizen.Wait(0)
        end
		local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(pped, 0.0, 4.0, 0.5))--get coords front of player
        object1 = CreateObject(animalHash, x,y,z-1, true, true, true)  --create the object
        FreezeEntityPosition(object1 , true) --freeze the object
        SetModelAsNoLongerNeeded(animalHash) --model is no longer needed    
    else
        print("Model not found.")
    end
end)
