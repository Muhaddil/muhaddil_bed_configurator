Config = {}

Config.Locale = "en" -- "en" for English, "es" for Spanish
Config.rotationSpeed = 5.0
Config.moveSpeed = 0.01
Config.NPCModel = "s_m_m_doctor_01"
Config.xrayModel = "prop_monitor_w_large" -- The prop used for the xray in the official config
Config.scale = 0.042 -- The scale of the screen on the xray screenX, adjust if you use a different prop
Config.PagerScreen = "xm_prop_x17_tv_ceiling_01"
Config.StationaryECGProp = 'v_med_cor_ceilingmonitor'
Config.FrameWork = "auto" -- auto, esx, qb
Config.RestricToAdmins = true -- Restrict usage to admins only
Config.AllowedGroups = {
    qb = { "admin", "god" },         -- QBCore roles
    esx = { "admin", "superadmin" }, -- ESX groups
    ace = { "bedconfigurator" }      -- ACE permissions
}

Config.cornerOffsetRight = 0.35 
Config.cornerOffsetBack = 0.0
Config.cornerOffsetTop = 0.6

Config.ECGRotationOrder = 2
Config.XRAYRotationOrder = 2