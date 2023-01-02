ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) 
    ESX = obj 
end)

RegisterNetEvent('lowkey_delivery:giveReward')
AddEventHandler('lowkey_delivery:giveReward', function(amount)
    local player = ESX.GetPlayerFromId(source); 

    player.addMoney(amount); 
end)