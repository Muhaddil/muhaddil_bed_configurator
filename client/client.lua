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
local snapToSurface = false
local surfaceNormal = nil
local lastValidPosition = nil
local positionHistory = {}
local maxHistorySize = 10
local showDebugInfo = false
local gridSnapEnabled = false
local gridSize = 0.1
local manualRotation = 0.0
local manualPitch = 0.0

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
            label_fine_height = _L('label_fine_height'),
            control_fine_height_desc = _L('control_fine_height_desc'),
            label_snap_surface = _L('label_snap_surface'),
            control_snap_surface_key = _L('control_snap_surface_key'),
            label_grid_snap = _L('label_grid_snap'),
            control_grid_snap_key = _L('control_grid_snap_key'),
            label_debug_info = _L('label_debug_info'),
            control_debug_info_key = _L('control_debug_info_key'),
            debug_pos = _L('debug_pos'),
            debug_head = _L('debug_head'),
            debug_rot = _L('debug_rot'),
            debug_snap = _L('debug_snap'),
            debug_grid = _L('debug_grid'),
            debug_history = _L('debug_history'),
            debug_normal = _L('debug_normal'),
            status_on = _L('status_on'),
            status_off = _L('status_off'),
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

local function SavePositionToHistory(coords, heading)
    table.insert(positionHistory, {
        coords = coords,
        heading = heading,
        timestamp = GetGameTimer()
    })

    if #positionHistory > maxHistorySize then
        table.remove(positionHistory, 1)
    end
end

local function UndoLastPosition(entity)
    if #positionHistory > 1 then
        table.remove(positionHistory)
        local lastPos = positionHistory[#positionHistory]

        if lastPos then
            SetEntityCoords(entity, lastPos.coords.x, lastPos.coords.y, lastPos.coords.z, false, false, false, true)
            SetEntityHeading(entity, lastPos.heading)
            ShowNotification('info', 'Config Tool', 'Position restored (Undo)')
            return true
        end
    end

    ShowNotification('warning', 'Config Tool', 'No previous position available')
    return false
end

local function DrawDebugInfo(entity, surfaceInfo)
    if not showDebugInfo then
        SendNUIMessage({
            action = 'updateDebug',
            debugData = nil
        })
        return
    end

    local coords = GetEntityCoords(entity)
    local heading = GetEntityHeading(entity)
    local rotation = GetEntityRotation(entity, 2)

    SendNUIMessage({
        action = 'updateDebug',
        debugData = {
            coords = { x = coords.x, y = coords.y, z = coords.z },
            heading = heading,
            rotation = { x = rotation.x, y = rotation.y, z = rotation.z },
            snapToSurface = snapToSurface,
            gridSnapEnabled = gridSnapEnabled,
            historyCount = #positionHistory,
            maxHistory = maxHistorySize,
            surfaceNormal = surfaceInfo and { x = surfaceInfo.x, y = surfaceInfo.y, z = surfaceInfo.z } or nil
        }
    })

    local camCoords = GetGameplayCamCoord()
    DrawLine(camCoords.x, camCoords.y, camCoords.z, coords.x, coords.y, coords.z, 0, 255, 0, 150)

    DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.1, 0.1, 0, 255, 0, 100, false,
        false, 2, false, nil, nil, false)

    if surfaceInfo then
        local normalEnd = vector3(
            coords.x + surfaceInfo.x * 0.5,
            coords.y + surfaceInfo.y * 0.5,
            coords.z + surfaceInfo.z * 0.5
        )
        DrawLine(coords.x, coords.y, coords.z, normalEnd.x, normalEnd.y, normalEnd.z, 255, 0, 0, 200)
    end
end

local function SnapToGrid(value)
    if not gridSnapEnabled then return value end
    return math.floor(value / gridSize + 0.5) * gridSize
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

    local hit, coords, normal, material = GetCameraWorldPosition(spawnedNPC)

    if hit and coords then
        if gridSnapEnabled then
            coords = vector3(
                SnapToGrid(coords.x),
                SnapToGrid(coords.y),
                SnapToGrid(coords.z)
            )
        end

        local finalZ = coords.z + verticalOffset
        SetEntityCoords(spawnedNPC, coords.x, coords.y, finalZ, false, false, false, true)

        if normal then
            surfaceNormal = normal
        end

        lastValidPosition = vector3(coords.x, coords.y, finalZ)
    end

    local heading = GetEntityHeading(spawnedNPC)
    local entityCoords = GetEntityCoords(spawnedNPC)

    if IsControlPressed(0, 241) then
        SetEntityHeading(spawnedNPC, heading + rotationSpeed)
    end
    if IsControlPressed(0, 242) then
        SetEntityHeading(spawnedNPC, heading - rotationSpeed)
    end
    if IsControlPressed(0, 172) then
        verticalOffset = verticalOffset + moveSpeed
    end
    if IsControlPressed(0, 173) then
        verticalOffset = verticalOffset - moveSpeed
    end
    if IsControlPressed(0, 174) then
        SetEntityHeading(spawnedNPC, heading - rotationSpeed)
    end
    if IsControlPressed(0, 175) then
        SetEntityHeading(spawnedNPC, heading + rotationSpeed)
    end

    if IsControlJustPressed(0, 288) then
        snapToSurface = not snapToSurface
        ShowNotification('info', 'Config Tool', 'Snap to Surface: ' .. (snapToSurface and 'ENABLED' or 'DISABLED'))
    end

    if IsControlJustPressed(0, 289) then
        gridSnapEnabled = not gridSnapEnabled
        ShowNotification('info', 'Config Tool', 'Grid Snap: ' .. (gridSnapEnabled and 'ENABLED' or 'DISABLED'))
    end

    if IsControlJustPressed(0, 170) then
        showDebugInfo = not showDebugInfo
        ShowNotification('info', 'Config Tool', 'Debug Info: ' .. (showDebugInfo and 'ENABLED' or 'DISABLED'))
    end

    if IsControlPressed(0, 36) and IsControlJustPressed(0, 20) then
        UndoLastPosition(spawnedNPC)
    end

    if IsControlPressed(0, 10) then
        verticalOffset = verticalOffset + (moveSpeed * 0.1)
    end
    if IsControlPressed(0, 11) then
        verticalOffset = verticalOffset - (moveSpeed * 0.1)
    end

    if IsControlPressed(0, 21) then
        local fastRotation = rotationSpeed * 3
        if IsControlPressed(0, 174) then
            SetEntityHeading(spawnedNPC, heading - fastRotation)
        end
        if IsControlPressed(0, 175) then
            SetEntityHeading(spawnedNPC, heading + fastRotation)
        end
    end

    if GetGameTimer() % 1000 < 50 then
        SavePositionToHistory(entityCoords, heading)
    end

    if IsControlJustPressed(0, 191) then
        SaveConfiguration()
    end
    if IsControlJustPressed(0, 322) then
        CancelConfiguration()
    end

    UpdateHUDCoords(entityCoords.x, entityCoords.y, entityCoords.z, heading)
    DrawDebugInfo(spawnedNPC, surfaceNormal)
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

    local rayHandle = StartShapeTestRay(
        camCoords.x, camCoords.y, camCoords.z,
        rayEnd.x, rayEnd.y, rayEnd.z,
        -1,
        entity,
        7
    )

    local _, hit, endCoords, surfaceNormal, materialHash, entityHit = GetShapeTestResultIncludingMaterial(rayHandle)

    if hit == 1 then
        if surfaceNormal and (surfaceNormal.x ~= 0 or surfaceNormal.y ~= 0 or surfaceNormal.z ~= 0) then
            local offsetAmount = 0.01
            endCoords = vector3(
                endCoords.x + (surfaceNormal.x * offsetAmount),
                endCoords.y + (surfaceNormal.y * offsetAmount),
                endCoords.z + (surfaceNormal.z * offsetAmount)
            )
        end

        return true, endCoords, surfaceNormal, materialHash
    else
        local fallbackDistance = 3.0

        local shortRayHandle = StartShapeTestRay(
            camCoords.x, camCoords.y, camCoords.z,
            camCoords.x + dirX * fallbackDistance,
            camCoords.y + dirY * fallbackDistance,
            camCoords.z + dirZ * fallbackDistance,
            -1,
            entity,
            7
        )

        local _, shortHit, shortCoords = GetShapeTestResult(shortRayHandle)

        if shortHit == 1 then
            return true, shortCoords, nil, nil
        end

        local fallbackCoords = vector3(
            camCoords.x + dirX * fallbackDistance,
            camCoords.y + dirY * fallbackDistance,
            camCoords.z + dirZ * fallbackDistance
        )

        local foundGround, groundZ = GetGroundZFor_3dCoord(
            fallbackCoords.x,
            fallbackCoords.y,
            fallbackCoords.z + 2.0,
            false
        )

        if foundGround then
            return true, vector3(fallbackCoords.x, fallbackCoords.y, groundZ), nil, nil
        end

        return true, fallbackCoords, nil, nil
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
    verticalOffset = 0.0
    manualRotation = 0.0
    manualPitch = 0.0

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
        local monitorRot = GetEntityRotation(spawnedMonitor, Config.XRAYRotationOrder)
        local adjustedRotZ = monitorRot.z % 360

        local scale = Config.scale

        cfg = string.format(
            "{ coords = vector4(%.4f, %.4f, %.4f, %.4f), taken = false, model = '%s', getOutOffset = 1.3, xray = true, xrayMonitor = vector3(%.4f, %.4f, %.4f), xrayMonitorRot = vector3(%.1f, %.1f, %.1f), screenScale = %s, lockedBed = true },",
            tempBedData.coords.x, tempBedData.coords.y, tempBedData.coords.z - 1.0, tempBedData.heading,
            tempBedData.model,
            monitorCoords.x, monitorCoords.y, monitorCoords.z,
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
        local monitorRot = GetEntityRotation(spawnedMonitor, Config.ECGRotationOrder)

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

    local hit, coords, normal, material = GetCameraWorldPosition(spawnedMonitor)

    if hit and coords then
        if gridSnapEnabled then
            coords = vector3(
                SnapToGrid(coords.x),
                SnapToGrid(coords.y),
                SnapToGrid(coords.z)
            )
        end

        if placingMonitorType == "xray" then
            local heading = manualRotation
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
                coords.z - topOffset + verticalOffset,
                false, false, false, true
            )
        else
            SetEntityCoords(spawnedMonitor, coords.x, coords.y, coords.z + verticalOffset, false, false, false, true)
        end

        if normal then
            surfaceNormal = normal
        end
    end

    if snapToSurface and surfaceNormal then
        local normalLength = math.sqrt(surfaceNormal.x * surfaceNormal.x + surfaceNormal.y * surfaceNormal.y +
            surfaceNormal.z * surfaceNormal.z)
        if normalLength > 0.01 then
            local normalizedNormal = vector3(
                surfaceNormal.x / normalLength,
                surfaceNormal.y / normalLength,
                surfaceNormal.z / normalLength
            )

            local pitch = math.deg(math.asin(-normalizedNormal.z)) + manualPitch

            if placingMonitorType == "ecg" and normalizedNormal.z < -0.8 then
                pitch = manualPitch
            end

            SetEntityRotation(spawnedMonitor, pitch, 0.0, manualRotation, 2, true)
        end
    else
        SetEntityRotation(spawnedMonitor, manualPitch, 0.0, manualRotation, 2, true)
    end

    if IsControlPressed(0, 241) then
        manualRotation = manualRotation + rotationSpeed
    end
    if IsControlPressed(0, 242) then
        manualRotation = manualRotation - rotationSpeed
    end

    if IsControlPressed(0, 172) then
        verticalOffset = verticalOffset + moveSpeed
    end
    if IsControlPressed(0, 173) then
        verticalOffset = verticalOffset - moveSpeed
    end

    if IsControlPressed(0, 174) then
        manualRotation = manualRotation - rotationSpeed
    end
    if IsControlPressed(0, 175) then
        manualRotation = manualRotation + rotationSpeed
    end

    if IsControlPressed(0, 21) then
        if IsControlPressed(0, 172) then
            manualPitch = manualPitch + rotationSpeed
        end
        if IsControlPressed(0, 173) then
            manualPitch = manualPitch - rotationSpeed
        end
    end

    if IsControlJustPressed(0, 288) then
        snapToSurface = not snapToSurface
        ShowNotification('info', 'Config Tool', 'Snap to Surface: ' .. (snapToSurface and 'ENABLED' or 'DISABLED'))
    end

    if IsControlJustPressed(0, 289) then
        gridSnapEnabled = not gridSnapEnabled
        ShowNotification('info', 'Config Tool', 'Grid Snap: ' .. (gridSnapEnabled and 'ENABLED' or 'DISABLED'))
    end

    if IsControlJustPressed(0, 170) then
        showDebugInfo = not showDebugInfo
        ShowNotification('info', 'Config Tool', 'Debug Info: ' .. (showDebugInfo and 'ENABLED' or 'DISABLED'))
    end

    if IsControlPressed(0, 10) then
        verticalOffset = verticalOffset + (moveSpeed * 0.1)
    end
    if IsControlPressed(0, 11) then
        verticalOffset = verticalOffset - (moveSpeed * 0.1)
    end

    if IsControlPressed(0, 21) then
        local fastRotation = rotationSpeed * 3
        if IsControlPressed(0, 174) then
            manualRotation = manualRotation - fastRotation
        end
        if IsControlPressed(0, 175) then
            manualRotation = manualRotation + fastRotation
        end
    end

    if IsControlJustPressed(0, 191) then
        SaveMonitorConfig()
    end
    if IsControlJustPressed(0, 322) then
        CancelMonitorPlacement()
    end

    local monitorCoords = GetEntityCoords(spawnedMonitor)
    UpdateHUDCoords(monitorCoords.x, monitorCoords.y, monitorCoords.z, manualRotation)
    DrawDebugInfo(spawnedMonitor, surfaceNormal)
end

function CancelMonitorPlacement()
    _restoreMonitorPhysics()
    if spawnedMonitor and DoesEntityExist(spawnedMonitor) then
        DeleteEntity(spawnedMonitor)
    end
    spawnedMonitor, placingMonitorType = nil, nil
    tempBedData = nil
    manualRotation = 0.0
    manualPitch = 0.0
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
    positionHistory = {}
    snapToSurface = false
    surfaceNormal = nil
    gridSnapEnabled = false
    showDebugInfo = false
    manualRotation = 0.0
    manualPitch = 0.0
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
        if spawnedMonitor and DoesEntityExist(spawnedMonitor) then
            DeleteEntity(spawnedMonitor)
        end
        if spawnedPager and DoesEntityExist(spawnedPager) then
            DeleteEntity(spawnedPager)
        end
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
    manualRotation = 0.0
    manualPitch = 0.0

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

    local hit, coords, normal, material = GetCameraWorldPosition(spawnedPager)

    if hit and coords then
        if gridSnapEnabled then
            coords = vector3(
                SnapToGrid(coords.x),
                SnapToGrid(coords.y),
                SnapToGrid(coords.z)
            )
        end

        SetEntityCoords(spawnedPager, coords.x, coords.y, coords.z + verticalOffset, false, false, false, true)

        if normal then
            surfaceNormal = normal
        end
    end

    if snapToSurface and surfaceNormal then
        local normalLength = math.sqrt(surfaceNormal.x * surfaceNormal.x + surfaceNormal.y * surfaceNormal.y +
            surfaceNormal.z * surfaceNormal.z)
        if normalLength > 0.01 then
            local normalizedNormal = vector3(
                surfaceNormal.x / normalLength,
                surfaceNormal.y / normalLength,
                surfaceNormal.z / normalLength
            )

            local pitch = math.deg(math.asin(-normalizedNormal.z)) + manualPitch
            SetEntityRotation(spawnedPager, pitch, 0.0, manualRotation, 2, true)
        end
    else
        SetEntityRotation(spawnedPager, manualPitch, 0.0, manualRotation, 2, true)
    end

    if IsControlPressed(0, 241) then
        manualRotation = manualRotation + rotationSpeed
    end
    if IsControlPressed(0, 242) then
        manualRotation = manualRotation - rotationSpeed
    end
    if IsControlPressed(0, 172) then
        verticalOffset = verticalOffset + moveSpeed
    end
    if IsControlPressed(0, 173) then
        verticalOffset = verticalOffset - moveSpeed
    end

    if IsControlPressed(0, 174) then
        manualRotation = manualRotation - rotationSpeed
    end
    if IsControlPressed(0, 175) then
        manualRotation = manualRotation + rotationSpeed
    end

    if IsControlPressed(0, 21) then
        if IsControlPressed(0, 172) then
            manualPitch = manualPitch + rotationSpeed
        end
        if IsControlPressed(0, 173) then
            manualPitch = manualPitch - rotationSpeed
        end
    end

    if IsControlJustPressed(0, 288) then
        snapToSurface = not snapToSurface
        ShowNotification('info', 'Config Tool', 'Snap to Surface: ' .. (snapToSurface and 'ENABLED' or 'DISABLED'))
    end

    if IsControlJustPressed(0, 289) then
        gridSnapEnabled = not gridSnapEnabled
        ShowNotification('info', 'Config Tool', 'Grid Snap: ' .. (gridSnapEnabled and 'ENABLED' or 'DISABLED'))
    end

    if IsControlJustPressed(0, 170) then
        showDebugInfo = not showDebugInfo
        ShowNotification('info', 'Config Tool', 'Debug Info: ' .. (showDebugInfo and 'ENABLED' or 'DISABLED'))
    end

    if IsControlPressed(0, 10) then
        verticalOffset = verticalOffset + (moveSpeed * 0.1)
    end
    if IsControlPressed(0, 11) then
        verticalOffset = verticalOffset - (moveSpeed * 0.1)
    end

    if IsControlPressed(0, 21) then
        local fastRotation = rotationSpeed * 3
        if IsControlPressed(0, 174) then
            manualRotation = manualRotation - fastRotation
        end
        if IsControlPressed(0, 175) then
            manualRotation = manualRotation + fastRotation
        end
    end

    if IsControlJustPressed(0, 191) then
        SavePagerScreenConfig()
    end
    if IsControlJustPressed(0, 322) then
        CancelPagerScreenPlacement()
    end

    local pagerCoords = GetEntityCoords(spawnedPager)
    UpdateHUDCoords(pagerCoords.x, pagerCoords.y, pagerCoords.z, manualRotation)
    DrawDebugInfo(spawnedPager, surfaceNormal)
end

function SavePagerScreenConfig()
    if not spawnedPager or not DoesEntityExist(spawnedPager) then return end

    local coords = GetEntityCoords(spawnedPager)

    local cfg = string.format([[
IncomingScreenPos = {
    vector4(%.4f, %.4f, %.4f, %.4f),
},

IncomingScreenSoundPos = {
    vector4(%.4f, %.4f, %.4f, %.4f),
},]],
        coords.x, coords.y, coords.z, manualRotation,
        coords.x, coords.y, coords.z, manualRotation
    )

    print(cfg)
    if lib and lib.setClipboard then lib.setClipboard(cfg) end

    ShowNotification('success', 'Config Tool', _L('pager_saved'))

    DeleteEntity(spawnedPager)
    spawnedPager, placingPagerScreen = nil, false
    manualRotation = 0.0
    manualPitch = 0.0
    HideHUD()
end

function CancelPagerScreenPlacement()
    if spawnedPager and DoesEntityExist(spawnedPager) then
        DeleteEntity(spawnedPager)
    end
    spawnedPager, placingPagerScreen = nil, false
    manualRotation = 0.0
    manualPitch = 0.0
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
