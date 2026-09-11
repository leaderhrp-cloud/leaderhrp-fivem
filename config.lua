Config = {}

Config.PedModel = 'mp_m_securoguard_01'
Config.PedCoords = vector4(461.8498, -981.0677, 30.6896, 91.5892)
Config.PedScenario = 'WORLD_HUMAN_COP_IDLES'

-- 👮‍♂️ تفعيل لجميع رتب الشرطة بدون تقييد برتبة معينة
Config.RequiredJob = "police"
Config.PricePerItem = 1

Config.Items = {
    ["armor"]       = { label = "درع واقي رئاسي", max = 12 },
    ["rifle_ammo"]  = { label = "مخزن ذخيرة رشاش", max = 20 },
    ["handcuffs"]   = { label = "كلبشات عسكرية", max = 10 },
    ["evidence"]    = { label = "أكياس جمع أدلة", max = 10 }
}