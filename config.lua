Config = {}; 

Config.Plate = "LOWKEY";
Config.StartLocation = vector3(-232.39743041992188, -915.6007690429688, 32.31082153320312); 

Config.Deliveries = {
    [1] = {
        ['label'] = 'Polisen', -- Namn på platsen
        ['coords'] = vector3(437.3401794433594, -979.3493041992188, 30.68960380554199), -- Koordinater för leveransen
        ['worth'] = 5, -- Hur mycket denna leveransen är värd
    }, 

    [2] = {
        ['label'] = 'Bilbolaget', 
        ['coords'] = vector3(-25.66366577148437, -1086.5687255859375, 26.57325172424316), 
        ['worth'] = 10, 
    },

    [3] = {
        ['label'] = 'Sjukhuset', 
        ['coords'] = vector3(299.9954223632813, -579.0023803710938, 43.26083374023437), 
        ['worth'] = math.random(5, 10), -- Ger en random summa mellan 5 och 10 
    },
}

Config.Vehicle = {
    ['model'] = 'boxville2', 
    ['spawn'] = vector3(-229.30502319335935, -890.8104858398438, 29.81134033203125), 
    ['heading'] = 247.39691162109375,
}

-- [[ Function ]]
Config.Notification = function(text)
    ESX.ShowNotification(text)
end