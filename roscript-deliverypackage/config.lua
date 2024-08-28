Config = {}

Config.blipsShow = true -- TO NOT HAVE A BLIP CHANGE THIS TO FALSE

Config.Locations = {
    [1] = {
        vector = vector3(-554.78, -914.44, 23.88), -- Done 
        text = "Delivery Job", 
        color = 2, 
        sprite = 50, 
        scale = 0.8,
    }
}

Config.StartLocation = vector4(-554.98, -915.1, 22.88, 266.46) 

Config.DeliveryLocations = {  
    vector3(-311.72, 474.93, 111.82),
    vector3(964.43, -595.96, 59.9),
    vector3(1437.56, -1492.08, 63.63),
}

Config.PackageItem = "water_bottle"
Config.MinReward = 50 
Config.MaxReward = 100 
Config.SpecialItem = "coffee" 
Config.SpecialItemChance = 50 
Config.NPCModel = 's_m_m_postal_01' 
Config.RecipientModels = { 
    'a_f_y_business_01',
    'a_m_m_farmer_01',
    'a_f_y_hiker_01',
    'a_m_y_hippy_01'
}
Config.Locale = 'en'  
