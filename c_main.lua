ESX = nil

Delivery = { 
    state = 1; 
    delivery = {};
    reward = false
};

TriggerEvent('esx:getSharedObject', function(obj) 
    ESX = obj 
end)

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(Config.StartLocation)

	SetBlipSprite(blip, 67)
	SetBlipScale(blip, 0.7)
	SetBlipColour(blip, 0)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName("Post OP")
	EndTextCommandSetBlipName(blip)

    while true do 
        local player, interval = PlayerPedId(), 0; 
        local playerCoords = GetEntityCoords(player);
        
        local distance = #(playerCoords - Config.StartLocation);

        if distance < 5.0 then 
            interval = 0; 

            ESX.Game.Utils.DrawText3D(Config.StartLocation, '[~g~E~s~] - Starta leverans', 0.4); 

            if distance < 1.0 then 
                if IsControlJustReleased(0, 38) then 
                    if Delivery.inMission then 
                        Delivery:EndMission()
                    else
                        Delivery:StartMission(); 
                    end
                end
            end
        end

        Citizen.Wait(interval); 
    end
end)

-- [[ Functions ]]
function Delivery:StartMission()
    self.vehicle = self:CreateVehicle(); 
    self.inMission = not self.inMission; 

    self.delivery = Config.Deliveries[self.state];

    SetNewWaypoint(self.delivery.coords.x, self.delivery.coords.y);

    if self.inMission then 
        self:RunThread(); 
    end
end

function Delivery:RunThread()
    while true do 
        local playerPed = PlayerPedId(); 
            
        local distance = #(GetEntityCoords(playerPed) - self.delivery.coords);

        if not IsPedInVehicle(playerPed, self.vehicle, false) and distance < 40.0 and not IsEntityAttachedToEntity(self.box, playerPed) then 
            local vehicleBoneCoords = GetWorldPositionOfEntityBone(self.vehicle, GetEntityBoneIndexByName(self.vehicle, "taillight_l"));
            local dst = #(GetEntityCoords(playerPed) - vehicleBoneCoords);

            if dst < 5.0 then 
                ESX.Game.Utils.DrawText3D(vehicleBoneCoords - vector3(0.0, 0.90, 0.0), '[~g~E~s~] - Ta paket', 0.4); 

                if dst < 2.0 then 
                    if IsControlJustReleased(0, 38) then 
                        SetVehicleDoorOpen(self.vehicle, 2, false, false); 
                        SetVehicleDoorOpen(self.vehicle, 3, false, false); 

                        Citizen.Wait(2000); 

                        while not HasAnimDictLoaded("anim@heists@box_carry@") do
                            Citizen.Wait(0)
                
                            RequestAnimDict("anim@heists@box_carry@")
                        end

                        TaskPlayAnim(playerPed, "anim@heists@box_carry@", "idle", 8.0, 8.0, -1, 50, 0, false, false, false)

                        self.box = self:CreateBox();

                        AttachEntityToEntity(self.box, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true);

                        SetVehicleDoorShut(self.vehicle, 2, false);
                        SetVehicleDoorShut(self.vehicle, 3, false);
                    end
                end
            end
        end

        if IsEntityAttachedToEntity(self.box, playerPed) then 
            Utils:DrawScreenText({
                text = 'Lämna paketet.',
            }); 
        else
            Utils:DrawScreenText({
                text = ('Åk och leverera ett paket till ~y~%s'):format(self.delivery.label),
            }); 
        end

        if distance < 5.0 and IsEntityAttachedToEntity(self.box, playerPed) then 
            ESX.Game.Utils.DrawText3D(self.delivery.coords, '[~g~E~s~] - Leverera paket', 0.4); 

            if distance < 1.0 then 
                if IsControlJustReleased(0, 38) then 
                    self:DeliverPackage(); break
                end
            end
        end

        Citizen.Wait(0); 
    end
end

function Delivery:DeliverPackage()
    local playerPed = PlayerPedId(); 

    DeleteObject(self.box);
    ClearPedTasksImmediately(playerPed); 

    if self.state == #Config.Deliveries then 
        self:EndMission(); 
    else
        TriggerServerEvent('lowkey_delivery:giveReward', self.delivery.worth)

        Config.Notification(('Du fick %s kr för leveransen.'):format(self.delivery.worth))

        self.state = self.state + 1;
        self.delivery = Config.Deliveries[self.state];

        SetNewWaypoint(self.delivery.coords.x, self.delivery.coords.y);

        self:RunThread();
    end
end

function Delivery:EndMission()
    self.inMission = not self.inMission; 

    self.delivery = nil; 
    self.state = 1; 
    
    self.reward = not self.reward;

    SetNewWaypoint(Config.StartLocation.x, Config.StartLocation.y);
    
    while self.reward do 
        local playerPed = PlayerPedId();
        local distance = #(GetEntityCoords(playerPed) - Config.StartLocation);

        Utils:DrawScreenText({
            text = 'Åk och lämna tillbaka ditt fordon och avsluta leveransen.';
        }); 

        if distance < 5.0 and self.reward then 
            ESX.Game.Utils.DrawText3D(Config.StartLocation, '[~g~E~s~] - Avsluta', 0.4); 

            if distance < 1.0 then 
                if IsControlJustReleased(0, 38) then 
                    self.reward = false; 
                    
                    if self.vehicle ~= nil then 
                        SetEntityAsMissionEntity(self.vehicle, false, false); 
                        DeleteVehicle(self.vehicle); 
                    end break
                end
            end
        end

        Citizen.Wait(0); 
    end
end

function Delivery:CreateVehicle()
    if not DoesEntityExist(vehicle) then 
        RequestModel(Config.Vehicle.model); 

        while not HasModelLoaded(Config.Vehicle.model) do 
            Citizen.Wait(0); 
        end

        vehicle = CreateVehicle(Config.Vehicle.model, Config.Vehicle.spawn, Config.Vehicle.heading, true, false);
    end

    return vehicle
end

function Delivery:CreateBox()
    RequestModel('prop_paper_box_01'); 

    while not HasModelLoaded('prop_paper_box_01') do 
        Citizen.Wait(0); 
    end

    box = CreateObject('prop_paper_box_01', GetEntityCoords(PlayerPedId()), true, false);

    return box
end

-- [[ Utils ]]
Utils = {}; 

function Utils:DrawScreenText(data)
    SetTextFont(8)
    SetTextProportional(0)
    SetTextScale(0.4, 0.4)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    if(outline)then
      SetTextOutline()
  end
    SetTextEntry("STRING")
    AddTextComponentString(data.text)
    DrawText(0.82 - 1.0/2, 0.604 - 1.0/2 + 0.005)
end

-- [[ Events ]]
AddEventHandler('onResourceStop', function(resourcename)
    if not resourcename == GetCurrentResourceName() then return end; 

    if Delivery.vehicle ~= nil then 
        SetEntityAsMissionEntity(Delivery.vehicle, false, false); 
        DeleteVehicle(Delivery.vehicle); 
    end

    if Delivery.box ~= nil then 
        SetEntityAsMissionEntity(Delivery.box, false, false); 
        DeleteObject(Delivery.box); 
    end
end)