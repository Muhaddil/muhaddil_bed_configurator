Config = {}

Config.rotationSpeed = 5.0
Config.moveSpeed = 0.01
Config.NPCModel = "s_m_m_doctor_01"
Config.xrayModel = "prop_monitor_w_large" -- The prop used for the xray in the official config
Config.verticalOffsetXray = -0.5 -- Vertical offset for the xray when placing it
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

-- You should not need to change anything below this line
Config.backOffset = 0.2 -- How far back the xray is placed from the monitor
Config.leftOffset = 0.3 -- How far left the xray is placed from the monitor