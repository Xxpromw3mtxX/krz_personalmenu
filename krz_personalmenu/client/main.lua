ESX = nil

local PersonalMenu = {
	ItemSelected = {},
	ItemIndex = {},
	WeaponData = {},
	WalletIndex = {},
	WalletList = {_U('wallet_option_give'), _U('wallet_option_drop')},
	BillData = {},
	ClothesButtons = {'torso', 'pants', 'shoes', 'bag', 'bproof'},
	AccessoriesButtons = {'Ears', 'Glasses', 'Helmet', 'Mask'},
	DoorState = {
		FrontLeft = false,
		FrontRight = false,
		BackLeft = false,
		BackRight = false,
		Hood = false,
		Trunk = false
	},
	DoorIndex = 1,
	DoorList = {_U('vehicle_door_frontleft'), _U('vehicle_door_frontright'), _U('vehicle_door_backleft'), _U('vehicle_door_backright')},
}

Player = {
	isDead = false,
	inAnim = false,
	crouched = false,
	handsup = false,
	pointing = false,
	noclip = false,
	godmode = false,
	ghostmode = false,
	showCoords = false,
	showName = false,
	gamerTags = {},
	group = 'user'
}

local societymoney, societymoney2 = nil, nil
local SimTab = {}
local number = {}
local NumberSelected = {}
local myPhoneNumber = ''

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()

	while actualSkin == nil do
		TriggerEvent('skinchanger:getSkin', function(skin) actualSkin = skin end)
		Citizen.Wait(100)
	end

	RefreshMoney()

	PersonalMenu.WeaponData = ESX.GetWeaponList()

	for i = 1, #PersonalMenu.WeaponData, 1 do
		if PersonalMenu.WeaponData[i].name == 'WEAPON_UNARMED' then
			PersonalMenu.WeaponData[i] = nil
		else
			PersonalMenu.WeaponData[i].hash = GetHashKey(PersonalMenu.WeaponData[i].name)
		end
	end

	RMenu.Add('rageui', 'personal', RageUI.CreateMenu(Config.MenuTitle, _U('mainmenu_subtitle'), 1450, 450, 'customheader', 'interaction_bgd', 255, 255, 255, 255))

	RMenu.Add('personal', 'wallet', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), _U('wallet_title'), _U('wallet_title'), 1450, 600))
	RMenu.Add('personal', 'documents', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), _U('documents_title')))
	RMenu.Add('personal', 'simmenu', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), _U('sim_management'), _U('sim_management'), 0, 0))
	RMenu.Add('personal', 'loadout', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), _U('loadout_title'), _U('loadout_title'), 0, 0))
	RMenu.Add('personal', 'components', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), 'Smonta componenti', 'Smonta componenti', 0, 0))
	RMenu.Add('personal', 'billing', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), _U('bills_title'), _U('bills_title'), 0, 0))
	RMenu.Add('personal', 'clothes', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), _U('clothes_title'), _U('clothes_title'), 0, 0))
	RMenu.Add('personal', 'accessories', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), _U('accessories_title'), _U('accessories_title'), 0, 0))
	RMenu.Add('personal', 'vehicle', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), _U('vehicle_title'), _U('vehicle_title'), 0, 0), function()
		if IsPedSittingInAnyVehicle(plyPed) then
			if (GetPedInVehicleSeat(GetVehiclePedIsIn(plyPed, false), -1) == plyPed) then
				return true
			end
		end

		return false
	end)

	RMenu.Add('personal', 'boss', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), _U('bossmanagement_title'), _U('bossmanagement_title'), 0, 0), function()
		if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
			return true
		end

		return false
	end)

	RMenu.Add('personal', 'admin', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), _U('admin_title'), _U('admin_title'), 1450, 450), function()
		if Player.group ~= nil and (Player.group == 'mod' or Player.group == 'admin' or Player.group == 'superadmin' or Player.group == 'owner' or Player.group == '_dev') then
			return true
		end

		return false
	end)

	RMenu.Add('loadout', 'actions', RageUI.CreateSubMenu(RMenu.Get('personal', 'loadout'), _U('loadout_actions_title')))
	RMenu.Get('loadout', 'actions').Closed = function()
		PersonalMenu.ItemSelected = nil
	end

	RMenu.Add('simmenu', 'actions', RageUI.CreateSubMenu(RMenu.Get('personal', 'loadout'), _U('sim_actions_title')))
	RMenu.Get('simmenu', 'actions').Closed = function()
		NumberSelected = nil
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.TriggerServerCallback("dqP:getSim", function(result2)
		SimTab = result2
	end)
end)

-- Sim
RegisterNetEvent('dqP:syncSim')
AddEventHandler('dqP:syncSim', function()
	ESX.TriggerServerCallback("dqP:getSim", function(result)
    	SimTab = result
	end)
end)

AddEventHandler('esx:onPlayerDeath', function()
	Player.isDead = true
	RageUI.CloseAll()
	ESX.UI.Menu.CloseAll()
end)

AddEventHandler('playerSpawned', function()
	Player.isDead = false
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
	RefreshMoney()
end)

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job2)
	ESX.PlayerData.job2 = job2
	RefreshMoney2()
end)

RegisterNetEvent('esx_addonaccount:setMoney')
AddEventHandler('esx_addonaccount:setMoney', function(society, money)
	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' and 'society_' .. ESX.PlayerData.job.name == society then
		societymoney = ESX.Math.GroupDigits(money)
	end

	if ESX.PlayerData.job2 ~= nil and ESX.PlayerData.job2.grade_name == 'boss' and 'society_' .. ESX.PlayerData.job2.name == society then
		societymoney2 = ESX.Math.GroupDigits(money)
	end
end)

-- Weapon Menu --
RegisterNetEvent('KorioZ-PersonalMenu:Weapon_addAmmoToPedC')
AddEventHandler('KorioZ-PersonalMenu:Weapon_addAmmoToPedC', function(value, quantity)
	local weaponHash = GetHashKey(value)

	if HasPedGotWeapon(plyPed, weaponHash, false) and value ~= 'WEAPON_UNARMED' then
		AddAmmoToPed(plyPed, value, quantity)
	end
end)

-- Admin Menu --
RegisterNetEvent('KorioZ-PersonalMenu:Admin_BringC')
AddEventHandler('KorioZ-PersonalMenu:Admin_BringC', function(plyCoords)
	SetEntityCoords(plyPed, plyCoords)
end)

function RefreshMoney()
	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
		ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
			societymoney = ESX.Math.GroupDigits(money)
		end, ESX.PlayerData.job.name)
	end
end

function RefreshMoney2()
	if ESX.PlayerData.job2 ~= nil and ESX.PlayerData.job2.grade_name == 'boss' then
		ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
			societymoney2 = ESX.Math.GroupDigits(money)
		end, ESX.PlayerData.job2.name)
	end
end

--Message text joueur
function Text(text)
	SetTextColour(186, 186, 186, 255)
	SetTextFont(0)
	SetTextScale(0.378, 0.378)
	SetTextWrap(0.0, 1.0)
	SetTextCentre(false)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 205)
	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(0.5, 0.03)
end

function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
	AddTextEntry(entryTitle, textEntry)
	DisplayOnscreenKeyboard(1, entryTitle, '', inputText, '', '', '', maxLength)

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end

	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		return result
	else
		Citizen.Wait(500)
		return nil
	end
end

function getCamDirection()
	local heading = GetGameplayCamRelativeHeading() + GetEntityPhysicsHeading(plyPed)
	local pitch = GetGameplayCamRelativePitch()
	local coords = vector3(-math.sin(heading * math.pi / 180.0), math.cos(heading * math.pi / 180.0), math.sin(pitch * math.pi / 180.0))
	local len = math.sqrt((coords.x * coords.x) + (coords.y * coords.y) + (coords.z * coords.z))

	if len ~= 0 then
		coords = coords / len
	end

	return coords
end

function startAttitude(lib, anim)
	ESX.Streaming.RequestAnimSet(anim, function()
		SetPedMotionBlur(plyPed, false)
		SetPedMovementClipset(plyPed, anim, true)
		RemoveAnimSet(anim)
	end)
end

function startAnim(lib, anim)
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(plyPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
		RemoveAnimDict(lib)
	end)
end

function startAnimAction(lib, anim)
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(plyPed, lib, anim, 8.0, 1.0, -1, 49, 0, false, false, false)
		RemoveAnimDict(lib)
	end)
end

function setUniform(value, plyPed)
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
		TriggerEvent('skinchanger:getSkin', function(skina)
			if value == 'torso' then
				startAnimAction('clothingtie', 'try_tie_neutral_a')
				Citizen.Wait(1000)
				Player.handsup, Player.pointing = false, false
				ClearPedTasks(plyPed)

				if skin.torso_1 ~= skina.torso_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['torso_1'] = skin.torso_1, ['torso_2'] = skin.torso_2, ['tshirt_1'] = skin.tshirt_1, ['tshirt_2'] = skin.tshirt_2, ['arms'] = skin.arms})
				else
					TriggerEvent('skinchanger:loadClothes', skina, {['torso_1'] = 15, ['torso_2'] = 0, ['tshirt_1'] = 15, ['tshirt_2'] = 0, ['arms'] = 15})
				end
			elseif value == 'pants' then
				if skin.pants_1 ~= skina.pants_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['pants_1'] = skin.pants_1, ['pants_2'] = skin.pants_2})
				else
					if skin.sex == 0 then
						TriggerEvent('skinchanger:loadClothes', skina, {['pants_1'] = 61, ['pants_2'] = 1})
					else
						TriggerEvent('skinchanger:loadClothes', skina, {['pants_1'] = 15, ['pants_2'] = 0})
					end
				end
			elseif value == 'shoes' then
				if skin.shoes_1 ~= skina.shoes_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['shoes_1'] = skin.shoes_1, ['shoes_2'] = skin.shoes_2})
				else
					if skin.sex == 0 then
						TriggerEvent('skinchanger:loadClothes', skina, {['shoes_1'] = 34, ['shoes_2'] = 0})
					else
						TriggerEvent('skinchanger:loadClothes', skina, {['shoes_1'] = 35, ['shoes_2'] = 0})
					end
				end
			elseif value == 'bag' then
				if skin.bags_1 ~= skina.bags_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['bags_1'] = skin.bags_1, ['bags_2'] = skin.bags_2})
				else
					TriggerEvent('skinchanger:loadClothes', skina, {['bags_1'] = 0, ['bags_2'] = 0})
				end
			elseif value == 'bproof' then
				startAnimAction('clothingtie', 'try_tie_neutral_a')
				Citizen.Wait(1000)
				Player.handsup, Player.pointing = false, false
				ClearPedTasks(plyPed)

				if skin.bproof_1 ~= skina.bproof_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['bproof_1'] = skin.bproof_1, ['bproof_2'] = skin.bproof_2})
				else
					TriggerEvent('skinchanger:loadClothes', skina, {['bproof_1'] = 0, ['bproof_2'] = 0})
				end
			end
		end)
	end)
end

function setAccessory(accessory)
	ESX.TriggerServerCallback('esx_accessories:get', function(hasAccessory, accessorySkin)
		local _accessory = (accessory):lower()

		if hasAccessory then
			TriggerEvent('skinchanger:getSkin', function(skin)
				local mAccessory = -1
				local mColor = 0

				if _accessory == 'ears' then
					startAnimAction('mini@ears_defenders', 'takeoff_earsdefenders_idle')
					Citizen.Wait(250)
					Player.handsup, Player.pointing = false, false
					ClearPedTasks(plyPed)
				elseif _accessory == 'glasses' then
					mAccessory = 0
					startAnimAction('clothingspecs', 'try_glasses_positive_a')
					Citizen.Wait(1000)
					Player.handsup, Player.pointing = false, false
					ClearPedTasks(plyPed)
				elseif _accessory == 'helmet' then
					startAnimAction('missfbi4', 'takeoff_mask')
					Citizen.Wait(1000)
					Player.handsup, Player.pointing = false, false
					ClearPedTasks(plyPed)
				elseif _accessory == 'mask' then
					mAccessory = 0
					startAnimAction('missfbi4', 'takeoff_mask')
					Citizen.Wait(850)
					Player.handsup, Player.pointing = false, false
					ClearPedTasks(plyPed)
				end

				if skin[_accessory .. '_1'] == mAccessory then
					mAccessory = accessorySkin[_accessory .. '_1']
					mColor = accessorySkin[_accessory .. '_2']
				end

				local accessorySkin = {}
				accessorySkin[_accessory .. '_1'] = mAccessory
				accessorySkin[_accessory .. '_2'] = mColor
				TriggerEvent('skinchanger:loadClothes', skin, accessorySkin)
			end)
		else
			if _accessory == 'ears' then
				ESX.ShowNotification(_U('accessories_no_ears'))
			elseif _accessory == 'glasses' then
				ESX.ShowNotification(_U('accessories_no_glasses'))
			elseif _accessory == 'helmet' then
				ESX.ShowNotification(_U('accessories_no_helmet'))
			elseif _accessory == 'mask' then
				ESX.ShowNotification(_U('accessories_no_mask'))
			end
		end
	end, accessory)
end

function CheckQuantity(number)
	number = tonumber(number)

	if type(number) == 'number' then
		number = ESX.Math.Round(number)

		if number > 0 then
			return true, number
		end
	end

	return false, number
end

function RenderPersonalMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		for i = 1, #RMenu['personal'], 1 do
			local buttonLabel = RMenu['personal'][i].ButtonLabel or RMenu['personal'][i].Menu.Title

			if type(RMenu['personal'][i].Restriction) == 'function' then
				if RMenu['personal'][i].Restriction() then
					RageUI.Button(buttonLabel, nil, {RightLabel = "→→→"}, true, function() end, RMenu['personal'][i].Menu)
				else
					RageUI.Button(buttonLabel, nil, {RightBadge = RageUI.BadgeStyle.Lock}, false, function() end, RMenu['personal'][i].Menu)
				end
			else
				RageUI.Button(buttonLabel, nil, {RightLabel = "→→→"}, true, function() end, RMenu['personal'][i].Menu)
			end
		end
	end)
end

function RenderActionsMenu(type)
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		if type == 'loadout' then
			if HasPedGotWeapon(plyPed, PersonalMenu.ItemSelected.hash, false) then
				RageUI.Button(_U('loadout_give_button'), "", {}, true, function(Hovered, Active, Selected)
					if (Selected) then
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

						if closestDistance ~= -1 and closestDistance <= 3 then
							local closestPed = GetPlayerPed(closestPlayer)

							if IsPedOnFoot(closestPed) then
								local ammo = GetAmmoInPedWeapon(plyPed, PersonalMenu.ItemSelected.hash)
								TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_weapon', PersonalMenu.ItemSelected.name, ammo)
								RageUI.CloseAll()
							else
								ESX.ShowNotification(_U('in_vehicle_give', PersonalMenu.ItemSelected.label))
							end
						else
							ESX.ShowNotification(_U('players_nearby'))
						end
					end
				end)

				RageUI.Button("Smonta", "", {}, true, function(Hovered, Active, Selected)
					if (Selected) then
						local pedAmmo = GetAmmoInPedWeapon(plyPed, PersonalMenu.ItemSelected.hash)
						TriggerServerEvent('smontaarmi', PersonalMenu.ItemSelected.name, pedAmmo)
						Citizen.Wait(800)
						RageUI.CloseAll()
					end
				end)

				RageUI.Button(_U('loadout_givemun_button'), "", {RightBadge = RageUI.BadgeStyle.Ammo}, true, function(Hovered, Active, Selected)
					if (Selected) then
						local post, quantity = CheckQuantity(KeyboardInput('KORIOZ_BOX_AMMO_AMOUNT', _U('dialogbox_amount_ammo'), '', 8))

						if post then
							local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

							if closestDistance ~= -1 and closestDistance <= 3 then
								local closestPed = GetPlayerPed(closestPlayer)

								if IsPedOnFoot(closestPed) then
									local ammo = GetAmmoInPedWeapon(plyPed, PersonalMenu.ItemSelected.hash)

									if ammo > 0 then
										if quantity <= ammo and quantity >= 0 then
											local finalAmmo = math.floor(ammo - quantity)
											SetPedAmmo(plyPed, PersonalMenu.ItemSelected.name, finalAmmo)

											TriggerServerEvent('KorioZ-PersonalMenu:Weapon_addAmmoToPedS', GetPlayerServerId(closestPlayer), PersonalMenu.ItemSelected.name, quantity)
											ESX.ShowNotification(_U('gave_ammo', quantity, GetPlayerName(closestPlayer)))
											RageUI.CloseAll()
										else
											ESX.ShowNotification(_U('not_enough_ammo'))
										end
									else
										ESX.ShowNotification(_U('no_ammo'))
									end
								else
									ESX.ShowNotification(_U('in_vehicle_give', PersonalMenu.ItemSelected.label))
								end
							else
								ESX.ShowNotification(_U('players_nearby'))
							end
						else
							ESX.ShowNotification(_U('amount_invalid'))
						end
					end
				end)

				--[[RageUI.Button(_U('loadout_drop_button'), "", {RightBadge = RageUI.BadgeStyle.Alert}, true, function(Hovered, Active, Selected)
					if (Selected) then
						if IsPedOnFoot(plyPed) then
							TriggerServerEvent('esx:removeInventoryItem', 'item_weapon', PersonalMenu.ItemSelected.name)
							RageUI.CloseAll()
						else
							ESX.ShowNotification(_U('in_vehicle_drop', PersonalMenu.ItemSelected.label))
						end
					end
				end)]]
			else
				RageUI.GoBack()
			end
		elseif type == 'simmenu' then
			RageUI.Button("Usa", "", {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					ESX.TriggerServerCallback('gcphone:getItemAmount', function(qtty)
						if qtty >= 0 then
							TriggerServerEvent("dqP:SetNumber", NumberSelected)	
						else
							ESX.ShowNotification("Non hai un telefono!")
						end
					end, 'phone')
					RageUI.CloseAll()
				end
			end)

			RageUI.Button("Dai", "", {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					local closestPed = GetPlayerPed(closestPlayer)

					if closestPlayer ~= -1 and closestDistance < 3.0 then
						TriggerServerEvent('dqP:GiveNumber', GetPlayerServerId(closestPlayer), NumberSelected)

						table.remove(SimTab, i)
					else
						ESX.ShowNotification("~r~Personne à proximité")
					end
					
					RageUI.CloseAll()
				end
			end)

			RageUI.Button("Butta", "", {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					TriggerServerEvent('dqP:Throw', NumberSelected, NumberSelected)
					table.remove(SimTab, i)
					RageUI.CloseAll()
				end
			end)
		end
	end)
end

function RenderWeaponMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		for i = 1, #PersonalMenu.WeaponData, 1 do
			if HasPedGotWeapon(plyPed, PersonalMenu.WeaponData[i].hash, false) then
				local ammo = GetAmmoInPedWeapon(plyPed, PersonalMenu.WeaponData[i].hash)

				RageUI.Button(PersonalMenu.WeaponData[i].label .. ' [' .. ammo .. ']', nil, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
					if (Selected) then
						PersonalMenu.ItemSelected = PersonalMenu.WeaponData[i]
					end
				end, RMenu.Get('loadout', 'actions'))
			end
		end
	end)
end

function RenderSimMenu()
	result = SimTab
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		for i = 1, #result, 1 do
			table.insert(number, {
				number = result[i].number,
				label = result[i].label,
			})
			RageUI.Button(result[i].label, "", {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					NumberSelected = result[i].number
				end
			end, RMenu.Get('simmenu', 'actions'))
		end
	end)
end

function RenderComponentsMenu()
	local isArmored = false
	local playerArmour = GetPedArmour(GetPlayerPed(-1))
	if playerArmour > 0 then 
		isArmored = true 
	end
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		if isArmored then
			RageUI.Button('Smonta corazza (' .. playerArmour .. ')', "", {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					TriggerServerEvent('atlantis_kevlar:armourRemove', playerArmour)
					RageUI.CloseAll()
				end
			end)
		end
	end)
end

function RenderDocumentsMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		RageUI.CloseAll()
		TriggerEvent('esx_documents:OpenMainMenu')
	end)
end

-- SIM CARD SECTION
--[[function RenderSimCardMenu()
	result = SimTab
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		for i = 1, #result, 1 do
			table.insert(number, {
				number = result[i].number,
				label = result[i].label,
			})

			RageUI.Button(result[i].label, "", {}, true, function(Hovered, Active, Selected)
			end)

			RageUI.Button("Usa", "", {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					ESX.TriggerServerCallback('gcphone:getItemAmount', function(qtty)
						if qtty >= 0 then
							TriggerServerEvent("dqP:SetNumber", number[i].number)	
						else
							ESX.ShowNotification("Non hai un telefono!")
						end
					end, 'phone')
					RageUI.CloseAll()
				end
			end)

			RageUI.Button("Dai", "", {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					local closestPed = GetPlayerPed(closestPlayer)
  
					if closestPlayer ~= -1 and closestDistance < 3.0 then
						PlayAnim("mp_common", "givetake1_a")
						TriggerServerEvent('dqP:GiveNumber', GetPlayerServerId(closestPlayer), number[i].number)
  
						table.remove(SimTab, i)
					else
						ESX.ShowNotification("~r~Personne à proximité")
					end
					
					RageUI.CloseAll()
				end
			end)

			RageUI.Button("Butta", "", {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					TriggerServerEvent('dqP:Throw', number[i].number,number[i])
					table.remove(SimTab, i)
					RageUI.CloseAll()
				end
			end)
		end
	end)
end]]

RegisterNetEvent("dqP:UpdateNumber")
AddEventHandler("dqP:UpdateNumber", function(_myPhoneNumber)
	myPhoneNumber = _myPhoneNumber
	TriggerServerEvent("gcPhone:allUpdate")
  	SendNUIMessage({event = 'updateMyPhoneNumber', myPhoneNumber = myPhoneNumber})
end)

function RenderWalletMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		RageUI.Button(_U('wallet_job_button', ESX.PlayerData.job.label, ESX.PlayerData.job.grade_label), nil, {}, true, function() end)

		if Config.JSFourIDCard then
			RageUI.Button(_U('wallet_show_idcard_button'), nil, {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestDistance ~= -1 and closestDistance <= 3.0 then
						TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer))
					else
						ESX.ShowNotification(_U('players_nearby'))
					end
				end
			end)

			RageUI.Button(_U('wallet_check_idcard_button'), nil, {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
				end
			end)

			RageUI.Button(_U('wallet_show_driver_button'), nil, {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestDistance ~= -1 and closestDistance <= 3.0 then
						TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer), 'driver')
					else
						ESX.ShowNotification(_U('players_nearby'))
					end
				end
			end)

			RageUI.Button(_U('wallet_check_driver_button'), nil, {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'driver')
				end
			end)

			RageUI.Button(_U('wallet_show_firearms_button'), nil, {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestDistance ~= -1 and closestDistance <= 3.0 then
						TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer), 'weapon')
					else
						ESX.ShowNotification(_U('players_nearby'))
					end
				end
			end)

			RageUI.Button(_U('wallet_check_firearms_button'), nil, {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'weapon')
				end
			end)
		end
	end)
end

function RenderBillingMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		for i = 1, #PersonalMenu.BillData, 1 do
			RageUI.Button(PersonalMenu.BillData[i].label, nil, {RightLabel = '$' .. ESX.Math.GroupDigits(PersonalMenu.BillData[i].amount)}, true, function(Hovered, Active, Selected)
				if (Selected) then
					ESX.TriggerServerCallback('esx_billing:payBill', function()
						ESX.TriggerServerCallback('KorioZ-PersonalMenu:Bill_getBills', function(bills) PersonalMenu.BillData = bills end)
					end, PersonalMenu.BillData[i].id)
				end
			end)
		end
	end)
end

function RenderClothesMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		for i = 1, #PersonalMenu.ClothesButtons, 1 do
			RageUI.Button(_U(('clothes_%s'):format(PersonalMenu.ClothesButtons[i])), nil, {RightBadge = RageUI.BadgeStyle.Clothes}, true, function(Hovered, Active, Selected)
				if (Selected) then
					setUniform(PersonalMenu.ClothesButtons[i], plyPed)
				end
			end)
		end
	end)
end

function RenderAccessoriesMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		for i = 1, #PersonalMenu.AccessoriesButtons, 1 do
			RageUI.Button(_U(('accessories_%s'):format((PersonalMenu.AccessoriesButtons[i]:lower()))), nil, {RightBadge = RageUI.BadgeStyle.Clothes}, true, function(Hovered, Active, Selected)
				if (Selected) then
					setAccessory(PersonalMenu.AccessoriesButtons[i])
				end
			end)
		end
	end)
end

function RenderVehicleMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		RageUI.Button(_U('vehicle_engine_button'), nil, {}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if IsPedSittingInAnyVehicle(plyPed) then
					local plyVeh = GetVehiclePedIsIn(plyPed, false)

					if GetIsVehicleEngineRunning(plyVeh) then
						SetVehicleEngineOn(plyVeh, false, false, true)
						SetVehicleUndriveable(plyVeh, true)
					elseif not GetIsVehicleEngineRunning(plyVeh) then
						SetVehicleEngineOn(plyVeh, true, false, true)
						SetVehicleUndriveable(plyVeh, false)
					end
				else
					ESX.ShowNotification(_U('no_vehicle'))
				end
			end
		end)

		RageUI.List(_U('vehicle_door_button'), PersonalMenu.DoorList, PersonalMenu.DoorIndex, nil, {}, true, function(Hovered, Active, Selected, Index)
			if (Selected) then
				if IsPedSittingInAnyVehicle(plyPed) then
					local plyVeh = GetVehiclePedIsIn(plyPed, false)

					if Index == 1 then
						if not PersonalMenu.DoorState.FrontLeft then
							PersonalMenu.DoorState.FrontLeft = true
							SetVehicleDoorOpen(plyVeh, 0, false, false)
						elseif PersonalMenu.DoorState.FrontLeft then
							PersonalMenu.DoorState.FrontLeft = false
							SetVehicleDoorShut(plyVeh, 0, false, false)
						end
					elseif Index == 2 then
						if not PersonalMenu.DoorState.FrontRight then
							PersonalMenu.DoorState.FrontRight = true
							SetVehicleDoorOpen(plyVeh, 1, false, false)
						elseif PersonalMenu.DoorState.FrontRight then
							PersonalMenu.DoorState.FrontRight = false
							SetVehicleDoorShut(plyVeh, 1, false, false)
						end
					elseif Index == 3 then
						if not PersonalMenu.DoorState.BackLeft then
							PersonalMenu.DoorState.BackLeft = true
							SetVehicleDoorOpen(plyVeh, 2, false, false)
						elseif PersonalMenu.DoorState.BackLeft then
							PersonalMenu.DoorState.BackLeft = false
							SetVehicleDoorShut(plyVeh, 2, false, false)
						end
					elseif Index == 4 then
						if not PersonalMenu.DoorState.BackRight then
							PersonalMenu.DoorState.BackRight = true
							SetVehicleDoorOpen(plyVeh, 3, false, false)
						elseif PersonalMenu.DoorState.BackRight then
							PersonalMenu.DoorState.BackRight = false
							SetVehicleDoorShut(plyVeh, 3, false, false)
						end
					end
				else
					ESX.ShowNotification(_U('no_vehicle'))
				end
			end

			PersonalMenu.DoorIndex = Index
		end)

		RageUI.Button(_U('vehicle_hood_button'), nil, {}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if IsPedSittingInAnyVehicle(plyPed) then
					local plyVeh = GetVehiclePedIsIn(plyPed, false)

					if not PersonalMenu.DoorState.Hood then
						PersonalMenu.DoorState.Hood = true
						SetVehicleDoorOpen(plyVeh, 4, false, false)
					elseif PersonalMenu.DoorState.Hood then
						PersonalMenu.DoorState.Hood = false
						SetVehicleDoorShut(plyVeh, 4, false, false)
					end
				else
					ESX.ShowNotification(_U('no_vehicle'))
				end
			end
		end)

		RageUI.Button(_U('vehicle_trunk_button'), nil, {}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if IsPedSittingInAnyVehicle(plyPed) then
					local plyVeh = GetVehiclePedIsIn(plyPed, false)

					if not PersonalMenu.DoorState.Trunk then
						PersonalMenu.DoorState.Trunk = true
						SetVehicleDoorOpen(plyVeh, 5, false, false)
					elseif PersonalMenu.DoorState.Trunk then
						PersonalMenu.DoorState.Trunk = false
						SetVehicleDoorShut(plyVeh, 5, false, false)
					end
				else
					ESX.ShowNotification(_U('no_vehicle'))
				end
			end
		end)
	end)
end

function RenderBossMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		if societymoney ~= nil then
			RageUI.Button(_U('bossmanagement_chest_button'), nil, {RightLabel = '$' .. societymoney}, true, function() end)
		end

		RageUI.Button(_U('bossmanagement_hire_button'), nil, {}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if ESX.PlayerData.job.grade_name == 'boss' then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('players_nearby'))
					else
						TriggerServerEvent('KorioZ-PersonalMenu:Boss_recruterplayer', GetPlayerServerId(closestPlayer), ESX.PlayerData.job.name, 0)
					end
				else
					ESX.ShowNotification(_U('missing_rights'))
				end
			end
		end)

		RageUI.Button(_U('bossmanagement_fire_button'), nil, {}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if ESX.PlayerData.job.grade_name == 'boss' then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('players_nearby'))
					else
						TriggerServerEvent('KorioZ-PersonalMenu:Boss_virerplayer', GetPlayerServerId(closestPlayer))
					end
				else
					ESX.ShowNotification(_U('missing_rights'))
				end
			end
		end)

		RageUI.Button(_U('bossmanagement_promote_button'), nil, {}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if ESX.PlayerData.job.grade_name == 'boss' then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('players_nearby'))
					else
						TriggerServerEvent('KorioZ-PersonalMenu:Boss_promouvoirplayer', GetPlayerServerId(closestPlayer))
					end
				else
					ESX.ShowNotification(_U('missing_rights'))
				end
			end
		end)

		RageUI.Button(_U('bossmanagement_demote_button'), nil, {}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if ESX.PlayerData.job.grade_name == 'boss' then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('players_nearby'))
					else
						TriggerServerEvent('KorioZ-PersonalMenu:Boss_destituerplayer', GetPlayerServerId(closestPlayer))
					end
				else
					ESX.ShowNotification(_U('missing_rights'))
				end
			end
		end)
	end)
end

function RenderBoss2Menu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		if societymoney ~= nil then
			RageUI.Button(_U('bossmanagement2_chest_button'), nil, {RightLabel = '$' .. societymoney2}, true, function() end)
		end

		RageUI.Button(_U('bossmanagement2_hire_button'), nil, {}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if ESX.PlayerData.job2.grade_name == 'boss' then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('players_nearby'))
					else
						TriggerServerEvent('KorioZ-PersonalMenu:Boss_recruterplayer2', GetPlayerServerId(closestPlayer), ESX.PlayerData.job2.name, 0)
					end
				else
					ESX.ShowNotification(_U('missing_rights'))
				end
			end
		end)

		RageUI.Button(_U('bossmanagement2_fire_button'), nil, {}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if ESX.PlayerData.job2.grade_name == 'boss' then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('players_nearby'))
					else
						TriggerServerEvent('KorioZ-PersonalMenu:Boss_virerplayer2', GetPlayerServerId(closestPlayer))
					end
				else
					ESX.ShowNotification(_U('missing_rights'))
				end
			end
		end)

		RageUI.Button(_U('bossmanagement2_promote_button'), nil, {}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if ESX.PlayerData.job2.grade_name == 'boss' then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('players_nearby'))
					else
						TriggerServerEvent('KorioZ-PersonalMenu:Boss_promouvoirplayer2', GetPlayerServerId(closestPlayer))
					end
				else
					ESX.ShowNotification(_U('missing_rights'))
				end
			end
		end)

		RageUI.Button(_U('bossmanagement2_demote_button'), nil, {}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if ESX.PlayerData.job2.grade_name == 'boss' then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('players_nearby'))
					else
						TriggerServerEvent('KorioZ-PersonalMenu:Boss_destituerplayer2', GetPlayerServerId(closestPlayer))
					end
				else
					ESX.ShowNotification(_U('missing_rights'))
				end
			end
		end)
	end)
end

function RenderAdminMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		for i = 1, #Config.Admin, 1 do
			local authorized = false

			for j = 1, #Config.Admin[i].groups, 1 do
				if Config.Admin[i].groups[j] == Player.group then
					authorized = true
				end
			end

			if authorized then
				RageUI.Button(Config.Admin[i].label, nil, {}, true, function(Hovered, Active, Selected)
					if (Selected) then
						Config.Admin[i].command()
					end
				end)
			else
				RageUI.Button(Config.Admin[i].label, nil, {RightBadge = RageUI.BadgeStyle.Lock}, false, function() end)
			end
		end
	end)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if IsControlJustReleased(0, Config.Controls.OpenMenu.keyboard) and not Player.isDead then
			if not RageUI.Visible() then
				ESX.TriggerServerCallback('KorioZ-PersonalMenu:Admin_getUsergroup', function(plyGroup)
					Player.group = plyGroup

					ESX.TriggerServerCallback('KorioZ-PersonalMenu:Bill_getBills', function(bills)
						PersonalMenu.BillData = bills
						ESX.PlayerData = ESX.GetPlayerData()
						RageUI.Visible(RMenu.Get('rageui', 'personal'), true)
					end)
				end)
			end
			ESX.TriggerServerCallback("dqP:getSim", function(result2)
				SimTab = result2
			end)
		end

		if RageUI.Visible(RMenu.Get('rageui', 'personal')) then
			RenderPersonalMenu()
		end

		if RageUI.Visible(RMenu.Get('loadout', 'actions')) then
			RenderActionsMenu('loadout')
		elseif RageUI.Visible(RMenu.Get('simmenu', 'actions')) then
			RenderActionsMenu('simmenu')
		end

		if RageUI.Visible(RMenu.Get('personal', 'loadout')) then
			RenderWeaponMenu()
		end

		if RageUI.Visible(RMenu.Get('personal', 'wallet')) then
			RenderWalletMenu()
		end

		if RageUI.Visible(RMenu.Get('personal', 'documents')) then
			RenderDocumentsMenu()
		end

		if RageUI.Visible(RMenu.Get('personal', 'simmenu')) then
			RenderSimMenu()
		end

		if RageUI.Visible(RMenu.Get('personal', 'components')) then
			RenderComponentsMenu()
		end

		if RageUI.Visible(RMenu.Get('personal', 'documenti')) then
			OpenDocs()
		end

		if RageUI.Visible(RMenu.Get('personal', 'billing')) then
			RenderBillingMenu()
		end

		if RageUI.Visible(RMenu.Get('personal', 'clothes')) then
			RenderClothesMenu()
		end

		if RageUI.Visible(RMenu.Get('personal', 'accessories')) then
			RenderAccessoriesMenu()
		end

		if RageUI.Visible(RMenu.Get('personal', 'vehicle')) then
			if not RMenu.Settings('personal', 'vehicle', 'Restriction')() then
				RageUI.GoBack()
			end
			RenderVehicleMenu()
		end

		if RageUI.Visible(RMenu.Get('personal', 'boss')) then
			if not RMenu.Settings('personal', 'boss', 'Restriction')() then
				RageUI.GoBack()
			end
			RenderBossMenu()
		end

		if RageUI.Visible(RMenu.Get('personal', 'boss2')) then
			if not RMenu.Settings('personal', 'boss2', 'Restriction')() then
				RageUI.GoBack()
			end
			RenderBoss2Menu()
		end

		if RageUI.Visible(RMenu.Get('personal', 'admin')) then
			if not RMenu.Settings('personal', 'admin', 'Restriction')() then
				RageUI.GoBack()
			end
			RenderAdminMenu()
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		plyPed = PlayerPedId()

		if IsControlJustReleased(0, Config.Controls.StopTasks.keyboard) and IsInputDisabled(2) and not Player.isDead then
			Player.handsup, Player.pointing = false, false
			ClearPedTasks(plyPed)
		end

		if IsControlPressed(1, Config.Controls.TPMarker.keyboard1) and IsControlJustReleased(1, Config.Controls.TPMarker.keyboard2) and IsInputDisabled(2) and not Player.isDead then
			ESX.TriggerServerCallback('KorioZ-PersonalMenu:Admin_getUsergroup', function(plyGroup)
				if plyGroup ~= nil and (plyGroup == 'mod' or plyGroup == 'admin' or plyGroup == 'superadmin' or plyGroup == 'owner' or plyGroup == '_dev') then
					local waypointHandle = GetFirstBlipInfoId(8)

					if DoesBlipExist(waypointHandle) then
						Citizen.CreateThread(function()
							local waypointCoords = GetBlipInfoIdCoord(waypointHandle)
							local foundGround, zCoords, zPos = false, -500.0, 0.0

							while not foundGround do
								zCoords = zCoords + 10.0
								RequestCollisionAtCoord(waypointCoords.x, waypointCoords.y, zCoords)
								Citizen.Wait(0)
								foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords.x, waypointCoords.y, zCoords)

								if not foundGround and zCoords >= 2000.0 then
									foundGround = true
								end
							end

							SetPedCoordsKeepVehicle(plyPed, waypointCoords.x, waypointCoords.y, zPos)
							ESX.ShowNotification(_U('admin_tpmarker'))
						end)
					else
						ESX.ShowNotification(_U('admin_nomarker'))
					end
				end
			end)
		end

		if Player.showCoords then
			local plyCoords = GetEntityCoords(plyPed, false)
			Text('~r~X~s~: ' .. ESX.Math.Round(plyCoords.x, 2) .. '\n~b~Y~s~: ' .. ESX.Math.Round(plyCoords.y, 2) .. '\n~g~Z~s~: ' .. ESX.Math.Round(plyCoords.z, 2) .. '\n~y~Angle~s~: ' .. ESX.Math.Round(GetEntityPhysicsHeading(plyPed), 2))
		end

		if Player.noclip then
			local plyCoords = GetEntityCoords(plyPed, false)
			local camCoords = getCamDirection()
			SetEntityVelocity(plyPed, 0.01, 0.01, 0.01)

			if IsControlPressed(0, 32) then
				plyCoords = plyCoords + (Config.NoclipSpeed * camCoords)
			end

			if IsControlPressed(0, 269) then
				plyCoords = plyCoords - (Config.NoclipSpeed * camCoords)
			end

			SetEntityCoordsNoOffset(plyPed, plyCoords, true, true, true)
		end

		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do
		if Player.showName then
			for k, v in ipairs(ESX.Game.GetPlayers()) do
				local otherPed = GetPlayerPed(v)

				if otherPed ~= plyPed then
					if #(GetEntityCoords(plyPed, false) - GetEntityCoords(otherPed, false)) < 5000.0 then
						Player.gamerTags[v] = CreateFakeMpGamerTag(otherPed, ('[%s] %s'):format(GetPlayerServerId(v), GetPlayerName(v)), false, false, '', 0)
					else
						RemoveMpGamerTag(Player.gamerTags[v])
						Player.gamerTags[v] = nil
					end
				end
			end
		end

		Citizen.Wait(100)
	end
end)