Config = {}

Config.rotationSpeed = 5.0
Config.moveSpeed = 0.01
Config.NPCModel = "s_m_m_doctor_01"
Config.FrameWork = "auto" -- auto, esx, qb
Config.RestricToAdmins = true -- Restrict usage to admins only
Config.AllowedGroups = {
    qb = { "admin", "god" },         -- QBCore roles
    esx = { "admin", "superadmin" }, -- ESX groups
    ace = { "bedconfigurator" }      -- ACE permissions
}