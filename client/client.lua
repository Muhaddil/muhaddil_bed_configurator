local configMode = false
local configType = nil
local spawnedNPC = nil
local originalCoords = nil
local rotationSpeed = Config.rotationSpeed
local verticalOffset = 0.0
local moveSpeed = Config.moveSpeed
local bedLocked = false
local spawnedMonitor = nil
local placingMonitor = false
local tempBedData = nil
local placingMonitorType = nil
local spawnedPager = nil
local placingPagerScreen = false

local animationData = {
    bed = {
        dict = "anim@gangops@morgue@table@",
        anim = "body_search",
        flag = 1,
        description = _L('anim_bed')
    },
}

local function ShowHUD(type, title)
    SendNUIMessage({
        action = 'showHUD',
        type = type,
        title = title,
    })
end

local function updateLocales()
    SendNUIMessage({
        action = 'updateLocales',
        locales = {
            command_configbed = _L('command_configbed'),
            command_configpager = _L('command_configpager'),
            command_confighelp = _L('command_confighelp'),

            already_configuring = _L('already_configuring'),
            no_permission = _L('no_permission'),
            config_started = _L('config_started'),
            config_cancelled = _L('config_cancelled'),
            config_saved = _L('config_saved'),
            config_copied = _L('config_copied'),

            instructions_camera = _L('instructions_camera'),
            instructions_controls = _L('instructions_controls'),
            instructions_place_monitor = _L('instructions_place_monitor'),
            instructions_place_pager = _L('instructions_place_pager'),

            bed_save_title = _L('bed_save_title'),
            bed_normal = _L('bed_normal'),
            bed_normal_desc = _L('bed_normal_desc'),
            bed_locked = _L('bed_locked'),
            bed_locked_desc = _L('bed_locked_desc'),
            bed_xray = _L('bed_xray'),
            bed_xray_desc = _L('bed_xray_desc'),
            bed_ecg = _L('bed_ecg'),
            bed_ecg_desc = _L('bed_ecg_desc'),

            monitor_saved = _L('monitor_saved'),
            monitor_cancelled = _L('monitor_cancelled'),
            pager_saved = _L('pager_saved'),
            pager_cancelled = _L('pager_cancelled'),

            help_title = _L('help_title'),
            help_available = _L('help_available'),

            anim_bed = _L('anim_bed'),

            hud_camera_follow = _L('hud_camera_follow'),
            hud_coords = _L('hud_coords'),
            hud_monitor = _L('hud_monitor'),
            hud_pager = _L('hud_pager'),

            label_coordinates = _L('label_coordinates'),
            label_controls = _L('label_controls'),
            label_camera = _L('label_camera'),
            label_wheel_arrows = _L('label_wheel_arrows'),
            label_up_down = _L('label_up_down'),
            label_enter = _L('label_enter'),
            label_esc = _L('label_esc'),

            control_camera_desc = _L('control_camera_desc'),
            control_rotate_desc = _L('control_rotate_desc'),
            control_height_desc = _L('control_height_desc'),
            control_save_desc = _L('control_save_desc'),
            control_cancel_desc = _L('control_cancel_desc'),
        }
    })
end

local function HideHUD()
    SendNUIMessage({
        action = 'hideHUD'
    })
end

local function UpdateHUDCoords(x, y, z, h)
    SendNUIMessage({
        action = 'updateCoords',
        x = x,
        y = y,
        z = z,
        h = h
    })
end

local function ShowNotification(type, title, message)
    SendNUIMessage({
        action = 'showNotification',
        type = type,
        title = title,
        message = message
    })
end

function LoadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(50)
    end
end

function SpawnConfigNPC(configType)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)

    originalCoords = vector3(coords.x, coords.y, coords.z)
    verticalOffset = 0.0

    local spawnCoords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 2.0, 0.0)

    RequestModel(Config.NPCModel)
    while not HasModelLoaded(Config.NPCModel) do
        Citizen.Wait(500)
    end

    spawnedNPC = CreatePed(4, Config.NPCModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, heading, false, true)

    SetEntityInvincible(spawnedNPC, true)
    FreezeEntityPosition(spawnedNPC, true)
    SetBlockingOfNonTemporaryEvents(spawnedNPC, true)
    SetEntityCollision(spawnedNPC, false, false)
    SetPedCanRagdoll(spawnedNPC, false)
    SetPedCanBeTargetted(spawnedNPC, false)
    SetPedCanBeKnockedOffVehicle(spawnedNPC, 1)
    SetPedFleeAttributes(spawnedNPC, 0, false)
    SetPedCombatAttributes(spawnedNPC, 17, true)
    SetPedSeeingRange(spawnedNPC, 0.0)
    SetPedHearingRange(spawnedNPC, 0.0)
    SetPedAlertness(spawnedNPC, 0)
    SetPedKeepTask(spawnedNPC, true)
    TaskSetBlockingOfNonTemporaryEvents(spawnedNPC, true)

    local animData = animationData[configType]
    LoadAnimDict(animData.dict)
    TaskPlayAnim(spawnedNPC, animData.dict, animData.anim, 8.0, -8.0, -1, animData.flag, 0, false, false, false)

    ShowHUD('bed', string.format(_L('config_started'), animData.description))
    ShowNotification('info', 'Config Tool', _L('instructions_camera'))
end

function HandleNPCMovement()
    if not spawnedNPC or not DoesEntityExist(spawnedNPC) then
        return
    end

    local hit, coords = GetCameraWorldPosition(spawnedNPC)
    if hit and coords then
        SetEntityCoords(spawnedNPC, coords.x, coords.y, coords.z + verticalOffset, false, false, false, true)
    end

    local heading = GetEntityHeading(spawnedNPC)

    if IsControlPressed(0, 241) then -- Mouse Wheel Up
        SetEntityHeading(spawnedNPC, heading + rotationSpeed)
    end
    if IsControlPressed(0, 242) then -- Mouse Wheel Down
        SetEntityHeading(spawnedNPC, heading - rotationSpeed)
    end

    if IsControlPressed(0, 172) then -- Up Arrow
        verticalOffset = verticalOffset + moveSpeed
    end
    if IsControlPressed(0, 173) then -- Down Arrow
        verticalOffset = verticalOffset - moveSpeed
    end

    if IsControlPressed(0, 174) then -- Left Arrow
        SetEntityHeading(spawnedNPC, heading - rotationSpeed)
    end
    if IsControlPressed(0, 175) then -- Right Arrow
        SetEntityHeading(spawnedNPC, heading + rotationSpeed)
    end

    if IsControlJustPressed(0, 191) then -- ENTER
        SaveConfiguration()
    end
    if IsControlJustPressed(0, 322) then -- ESC
        CancelConfiguration()
    end

    local entityCoords = GetEntityCoords(spawnedNPC)
    UpdateHUDCoords(entityCoords.x, entityCoords.y, entityCoords.z, heading)
end

function GetCameraWorldPosition(entity, distance)
    distance = distance or 100.0
    
    local camCoords = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)
    
    if not camCoords or not camRot then
        return false, nil
    end
    
    local rotX = math.rad(camRot.x)
    local rotZ = math.rad(camRot.z)
    
    local dirX = -math.sin(rotZ) * math.cos(rotX)
    local dirY = math.cos(rotZ) * math.cos(rotX)
    local dirZ = math.sin(rotX)
    
    local rayEnd = vector3(
        camCoords.x + dirX * distance,
        camCoords.y + dirY * distance,
        camCoords.z + dirZ * distance
    )
    
    if not entity then 
        return false, nil 
    end
    
    if not DoesEntityExist(entity) then
        return false, nil
    end
    
    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(
        camCoords.x, camCoords.y, camCoords.z,
        rayEnd.x, rayEnd.y, rayEnd.z,
        511,
        entity,
        7
    )
    
    local _, hit, endCoords, _, materialHash, entityHit = GetShapeTestResultIncludingMaterial(rayHandle)
    
    if hit == 1 then
        return true, endCoords
    else
        local foundGround, groundZ = GetGroundZFor_3dCoord(rayEnd.x, rayEnd.y, rayEnd.z + 100.0, false)
        
        if foundGround then
            return true, vector3(rayEnd.x, rayEnd.y, groundZ)
        else
            local safeZ = camCoords.z - 1.0
            
            for i = 0, 50, 10 do
                foundGround, groundZ = GetGroundZFor_3dCoord(rayEnd.x, rayEnd.y, camCoords.z + i, false)
                if foundGround then
                    safeZ = groundZ
                    break
                end
            end
            
            return true, vector3(rayEnd.x, rayEnd.y, safeZ)
        end
    end
end

local function GetClosestObject(coords, radius)
    local handle, object = FindFirstObject()
    local success
    local closestObj, closestDist = nil, radius

    repeat
        if DoesEntityExist(object) then
            local objCoords = GetEntityCoords(object)
            local dist = #(coords - objCoords)
            if dist < closestDist then
                closestObj = object
                closestDist = dist
            end
        end
        success, object = FindNextObject(handle)
    until not success
    EndFindObject(handle)

    return closestObj, closestObj and GetEntityModel(closestObj) or nil
end

function SaveConfiguration()
    if not spawnedNPC or not DoesEntityExist(spawnedNPC) then
        return
    end

    local coords = GetEntityCoords(spawnedNPC)
    local heading = GetEntityHeading(spawnedNPC)

    local obj, objModel = GetClosestObject(coords, 2.0)

    lib.registerContext({
        id = 'bed_save_menu',
        title = _L('bed_save_title'),
        options = {
            {
                title = _L('bed_normal'),
                description = _L('bed_normal_desc'),
                icon = 'bed',
                onSelect = function()
                    bedLocked = false
                    PrintBedConfig(coords, heading, objModel)
                    CleanupConfiguration()
                end
            },
            {
                title = _L('bed_locked'),
                description = _L('bed_locked_desc'),
                icon = 'ban',
                onSelect = function()
                    bedLocked = true
                    PrintBedConfig(coords, heading, objModel)
                    CleanupConfiguration()
                end
            },
            {
                title = _L('bed_xray'),
                description = _L('bed_xray_desc'),
                icon = 'tv',
                onSelect = function()
                    bedLocked = true
                    StartPlacingGenericMonitor(coords, heading, objModel, Config.xrayModel, "xray")
                end
            },
            {
                title = _L('bed_ecg'),
                description = _L('bed_ecg_desc'),
                icon = 'tv',
                onSelect = function()
                    bedLocked = true
                    StartPlacingGenericMonitor(coords, heading, objModel, Config.StationaryECGProp, "ecg")
                end
            },
        }
    })

    lib.showContext('bed_save_menu')
end

function StartPlacingGenericMonitor(bedCoords, bedHeading, bedModel, monitorModel, type)
    placingMonitorType = type
    configMode = false

    if not IsModelInCdimage(monitorModel) then
        print("^1El modelo no existe: " .. monitorModel .. "^0")
    end

    RequestModel(monitorModel)
    while not HasModelLoaded(monitorModel) do
        Citizen.Wait(50)
    end

    spawnedMonitor = CreateObject(monitorModel, bedCoords.x, bedCoords.y + 1.0, bedCoords.z, true, true, true)
    SetEntityHeading(spawnedMonitor, bedHeading)

    SetEntityAsMissionEntity(spawnedMonitor, true, true)
    SetEntityCollision(spawnedMonitor, false, false)
    SetEntityDynamic(spawnedMonitor, false)
    FreezeEntityPosition(spawnedMonitor, true)
    if spawnedNPC and DoesEntityExist(spawnedNPC) then
        SetEntityNoCollisionEntity(spawnedMonitor, spawnedNPC, true)
    end

    ShowHUD('monitor', type:upper() .. ' MONITOR')
    ShowNotification('info', 'Config Tool', _L('instructions_place_monitor'))

    tempBedData = {
        coords = bedCoords,
        heading = bedHeading,
        model = bedModel
    }
end

local function _restoreMonitorPhysics()
    if spawnedMonitor and DoesEntityExist(spawnedMonitor) then
        FreezeEntityPosition(spawnedMonitor, false)
        SetEntityDynamic(spawnedMonitor, true)
        SetEntityCollision(spawnedMonitor, true, true)
    end
end

function SaveMonitorConfig()
    if not spawnedMonitor or not DoesEntityExist(spawnedMonitor) then return end
    if not tempBedData then return end

    local monitorCoords = GetEntityCoords(spawnedMonitor)

    local cfg
    if placingMonitorType == "xray" then
        local monitorRot = GetEntityRotation(spawnedMonitor, 2)
        local adjustedRotZ = monitorRot.z % 360

        local scale = Config.scale

        cfg = string.format(
            "{ coords = vector4(%.4f, %.4f, %.4f, %.4f), taken = false, model = '%s', getOutOffset = 1.3, xray = true, xrayMonitor = vector3(%.4f, %.4f, %.4f), xrayMonitorRot = vector3(%.1f, %.1f, %.1f), screenScale = %s, lockedBed = true },",
            tempBedData.coords.x, tempBedData.coords.y, tempBedData.coords.z - 1.0, tempBedData.heading,
            tempBedData.model,
            monitorCoords.x, monitorCoords.y, monitorCoords.z,  -- SIN ajustes
            monitorRot.x, monitorRot.y, adjustedRotZ,
            scale
        )

        print("\n=== XRAY CONFIGURATION ===")
        print("Copy this config to your beds table:")
        print(cfg)
        print("==========================\n")

        if lib and lib.setClipboard then
            lib.setClipboard(cfg)
        end
    elseif placingMonitorType == "ecg" then
        local bedCfg = string.format(
            "{ coords = vector4(%.4f, %.4f, %.4f, %.4f), taken = false, model = '%s', getOutOffset = 1.3, lockedBed = true },",
            tempBedData.coords.x, tempBedData.coords.y, tempBedData.coords.z - 1.0, tempBedData.heading,
            tempBedData.model
        )

        local monitorCfg = string.format(
            "{\n" ..
            "    coords = vector4(%.4f, %.4f, %.4f, %.4f),\n" ..
            "    bedcoords = vector3(%.4f, %.4f, %.4f),\n" ..
            "    name = 'ICU 1'\n" ..
            "},",
            monitorCoords.x, monitorCoords.y, monitorCoords.z, monitorRot.z,
            tempBedData.coords.x, tempBedData.coords.y, tempBedData.coords.z - 1.0
        )

        cfg = "-- BED CONFIGURATION:\n" .. bedCfg .. "\n\n-- ECG MONITOR CONFIGURATION:\n" .. monitorCfg

        print("\n=== ECG CONFIGURATION ===")
        print("Copy this bed config to your beds table:")
        print(bedCfg)
        print("\nCopy this monitor config to your ECGMonitor table:")
        print(monitorCfg)
        print("========================\n")
    end

    if lib and lib.setClipboard then
        lib.setClipboard(cfg)
    end

    ShowNotification('success', 'Config Tool', string.format(_L('monitor_saved'), placingMonitorType:upper()))

    _restoreMonitorPhysics()
    CleanupConfiguration()
    if spawnedMonitor then
        DeleteEntity(spawnedMonitor)
    end
    spawnedMonitor, placingMonitorType = nil, nil
end

function HandleMonitorPlacement()
    if not placingMonitorType or not spawnedMonitor or not DoesEntityExist(spawnedMonitor) then return end

    local hit, coords = GetCameraWorldPosition(spawnedMonitor)
    if hit and coords then
        if placingMonitorType == "xray" then
            local heading = GetEntityHeading(spawnedMonitor)
            local radians = math.rad(heading)
            
            local rightOffset = Config.cornerOffsetRight or 0.25 
            local backOffset = Config.cornerOffsetBack or 0.15
            local topOffset = Config.cornerOffsetTop or 0.4
            
            local offsetX = (rightOffset * math.cos(radians)) - (backOffset * math.sin(radians))
            local offsetY = (rightOffset * math.sin(radians)) + (backOffset * math.cos(radians))
            
            SetEntityCoords(
                spawnedMonitor, 
                coords.x - offsetX, 
                coords.y - offsetY, 
                coords.z - topOffset, 
                false, false, false, true
            )
        else
            SetEntityCoords(spawnedMonitor, coords.x, coords.y, coords.z + verticalOffset, false, false, false, true)
        end
    end

    local heading = GetEntityHeading(spawnedMonitor)

    if IsControlPressed(0, 241) then
        SetEntityHeading(spawnedMonitor, heading + rotationSpeed)
    end
    if IsControlPressed(0, 242) then
        SetEntityHeading(spawnedMonitor, heading - rotationSpeed)
    end

    if IsControlPressed(0, 172) then
        verticalOffset = verticalOffset + moveSpeed
    end
    if IsControlPressed(0, 173) then
        verticalOffset = verticalOffset - moveSpeed
    end

    if IsControlPressed(0, 174) then
        SetEntityHeading(spawnedMonitor, heading - rotationSpeed)
    end
    if IsControlPressed(0, 175) then
        SetEntityHeading(spawnedMonitor, heading + rotationSpeed)
    end

    if IsControlJustPressed(0, 191) then
        SaveMonitorConfig()
    end
    if IsControlJustPressed(0, 322) then
        CancelMonitorPlacement()
    end

    local monitorCoords = GetEntityCoords(spawnedMonitor)
    UpdateHUDCoords(monitorCoords.x, monitorCoords.y, monitorCoords.z, heading)
end

function CancelMonitorPlacement()
    _restoreMonitorPhysics()
    if spawnedMonitor and DoesEntityExist(spawnedMonitor) then
        DeleteEntity(spawnedMonitor)
    end
    spawnedMonitor, placingMonitorType = nil, nil
    tempBedData = nil
    CleanupConfiguration()
    ShowNotification('error', 'Config Tool', _L('monitor_cancelled'))
end

function PrintBedConfig(coords, heading, modelHash)
    local configText = string.format(
        "{ coords = vector4(%.4f, %.4f, %.4f, %.4f), taken = false, model = '%s', getOutOffset = 1.3%s },",
        coords.x, coords.y, coords.z - 1, heading,
        modelHash,
        bedLocked and ", lockedBed = true" or ""
    )

    print(configText)

    ShowNotification('success', 'Config Tool', _L('config_saved'))

    if lib and lib.setClipboard then
        lib.setClipboard(configText)
        ShowNotification('info', 'Config Tool', _L('config_copied'))
    end
end

function CancelConfiguration()
    ShowNotification('error', 'Config Tool', _L('config_cancelled'))
    CleanupConfiguration()
end

function CleanupConfiguration()
    if spawnedNPC and DoesEntityExist(spawnedNPC) then
        DeleteEntity(spawnedNPC)
    end

    spawnedNPC = nil
    configMode = false
    configType = nil
    originalCoords = nil
    verticalOffset = 0.0
    HideHUD()
end

RegisterCommand('configbed', function()
    TriggerServerEvent("configTool:tryConfig", "bed")
end)

RegisterNetEvent("configTool:startConfig", function(type)
    if configMode then
        ShowNotification('warning', 'Config Tool', _L('already_configuring'))
        return
    end

    configMode = true
    configType = type
    SpawnConfigNPC(type)
end)

RegisterNetEvent("configTool:denied", function()
    ShowNotification('error', 'Config Tool', _L('no_permission'))
end)

RegisterCommand('confighelp', function(source, args, rawCommand)
    TriggerServerEvent("configTool:tryHelpCommand", "bed")
end, false)

RegisterNetEvent("configTool:helpCommand", function()
    ShowNotification('info', _L('help_title'),
        _L('help_available') ..
        '\n/configbed - ' ..
        _L('command_configbed') ..
        '\n/configpager - ' .. _L('command_configpager') .. '\n/confighelp - ' .. _L('command_confighelp'))
end, false)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        CleanupConfiguration()
        HideHUD()
    end
end)

RegisterCommand("configpager", function()
    TriggerServerEvent("configTool:tryConfigPager")
end, false)

RegisterNetEvent("configTool:startConfigPager", function(type)
    if configMode then
        ShowNotification('warning', 'Config Tool', _L('already_configuring'))
        return
    end

    configMode = true
    StartPlacingPagerScreen()
end)

function StartPlacingPagerScreen()
    placingPagerScreen = true
    configMode = false
    verticalOffset = 0.0

    RequestModel(Config.PagerScreen)
    while not HasModelLoaded(Config.PagerScreen) do
        Citizen.Wait(50)
    end

    spawnedPager = CreateObject(Config.PagerScreen, GetEntityCoords(PlayerPedId()), true, true, true)
    SetEntityHeading(spawnedPager, GetEntityHeading(PlayerPedId()))

    SetEntityAsMissionEntity(spawnedPager, true, true)
    SetEntityCollision(spawnedPager, false, false)
    SetEntityDynamic(spawnedPager, false)
    FreezeEntityPosition(spawnedPager, true)

    ShowHUD('pager', 'PAGER SCREEN')
    ShowNotification('info', 'Config Tool', _L('instructions_place_pager'))
end

function HandlePagerScreenPlacement()
    if not placingPagerScreen or not spawnedPager or not DoesEntityExist(spawnedPager) then return end

    local hit, coords = GetCameraWorldPosition(spawnedPager)
    if hit and coords then
        SetEntityCoords(spawnedPager, coords.x, coords.y, coords.z + verticalOffset, false, false, false, true)
    end

    local heading = GetEntityHeading(spawnedPager)
    if IsControlPressed(0, 241) then SetEntityHeading(spawnedPager, heading + rotationSpeed) end
    if IsControlPressed(0, 242) then SetEntityHeading(spawnedPager, heading - rotationSpeed) end
    if IsControlPressed(0, 172) then verticalOffset = verticalOffset + moveSpeed end
    if IsControlPressed(0, 173) then verticalOffset = verticalOffset - moveSpeed end

    if IsControlPressed(0, 174) then
        SetEntityHeading(spawnedPager, heading - rotationSpeed)
    end
    if IsControlPressed(0, 175) then
        SetEntityHeading(spawnedPager, heading + rotationSpeed)
    end

    if IsControlJustPressed(0, 191) then
        SavePagerScreenConfig()
    end
    if IsControlJustPressed(0, 322) then
        CancelPagerScreenPlacement()
    end

    local pagerCoords = GetEntityCoords(spawnedPager)
    UpdateHUDCoords(pagerCoords.x, pagerCoords.y, pagerCoords.z, heading)
end

function SavePagerScreenConfig()
    if not spawnedPager or not DoesEntityExist(spawnedPager) then return end

    local coords = GetEntityCoords(spawnedPager)
    local heading = GetEntityHeading(spawnedPager)

    local cfg = string.format([[
IncomingScreenPos = {
    vector4(%.4f, %.4f, %.4f, %.4f),
},

IncomingScreenSoundPos = {
    vector4(%.4f, %.4f, %.4f, %.4f),
},]],
        coords.x, coords.y, coords.z, heading,
        coords.x, coords.y, coords.z, heading
    )

    print(cfg)
    if lib and lib.setClipboard then lib.setClipboard(cfg) end

    ShowNotification('success', 'Config Tool', _L('pager_saved'))

    DeleteEntity(spawnedPager)
    spawnedPager, placingPagerScreen = nil, false
    HideHUD()
end

function CancelPagerScreenPlacement()
    if spawnedPager and DoesEntityExist(spawnedPager) then
        DeleteEntity(spawnedPager)
    end
    spawnedPager, placingPagerScreen = nil, false
    HideHUD()
    ShowNotification('error', 'Config Tool', _L('pager_cancelled'))
end

Citizen.CreateThread(function()
    while true do
        local waitTime = 500

        if configMode then
            waitTime = 0
            HandleNPCMovement()
        elseif placingMonitorType and spawnedMonitor and DoesEntityExist(spawnedMonitor) then
            waitTime = 0
            HandleMonitorPlacement()
        elseif placingPagerScreen and spawnedPager and DoesEntityExist(spawnedPager) then
            waitTime = 0
            HandlePagerScreenPlacement()
        end

        Citizen.Wait(waitTime)
    end
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    Wait(1000)
    updateLocales()
end)
