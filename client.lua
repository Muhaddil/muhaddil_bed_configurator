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

local animationData = {
    bed = {
        dict = "anim@gangops@morgue@table@",
        anim = "body_search",
        flag = 1,
        description = "Bed Position"
    },
}

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

    local animData = animationData[configType]
    LoadAnimDict(animData.dict)
    TaskPlayAnim(spawnedNPC, animData.dict, animData.anim, 8.0, -8.0, -1, animData.flag, 0, false, false, false)

    ShowInstructions(configType)
end

function ShowInstructions(configType)
    local animData = animationData[configType]
    TriggerEvent('chat:addMessage', {
        color = { 0, 255, 0 },
        multiline = true,
        args = { "Config Tool", string.format("Configuring %s - NPC follows your camera:", animData.description) }
    })
    TriggerEvent('chat:addMessage', {
        color = { 255, 255, 0 },
        multiline = true,
        args = { "Controls", "CAMERA: NPC follows where you look | MOUSE WHEEL: Rotate" }
    })
    TriggerEvent('chat:addMessage', {
        color = { 255, 255, 0 },
        multiline = true,
        args = { "Controls", "Arrow Keys: Rotate | Q/E: Adjust height | ENTER: Save | ESC: Cancel" }
    })
end

function HandleNPCMovement()
    if not spawnedNPC or not DoesEntityExist(spawnedNPC) then
        return
    end

    local hit, coords = GetCameraWorldPosition()
    if hit then
        local camCoords = GetGameplayCamCoord()
        local distanceFromCamera = #(coords - camCoords)

        if distanceFromCamera > 2.0 then
            SetEntityCoords(spawnedNPC, coords.x, coords.y, coords.z + verticalOffset, false, false, false, true)
        end
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
end

function GetCameraWorldPosition()
    local camCoords = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)

    local distance = 100.0
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

    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(
        camCoords.x, camCoords.y, camCoords.z,
        rayEnd.x, rayEnd.y, rayEnd.z,
        1,
        spawnedNPC,
        7
    )

    local _, hit, endCoords, _, _ = GetShapeTestResult(rayHandle)

    if hit ~= 1 then
        local groundZ = 0.0
        local foundGround, groundCoords = GetGroundZFor_3dCoord(rayEnd.x, rayEnd.y, rayEnd.z + 50.0, groundZ, false)
        if foundGround then
            return true, vector3(rayEnd.x, rayEnd.y, groundCoords)
        else
            return true, vector3(rayEnd.x, rayEnd.y, camCoords.z - 1.0)
        end
    end

    return hit == 1, endCoords
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
        title = 'Guardar configuración de cama',
        options = {
            {
                title = 'Cama normal',
                description = 'Usable para check-in',
                icon = 'bed',
                onSelect = function()
                    bedLocked = false
                    PrintBedConfig(coords, heading, objModel)
                    CleanupConfiguration()
                end
            },
            {
                title = 'Cama bloqueada',
                description = 'No se podrá usar para check-in',
                icon = 'ban',
                onSelect = function()
                    bedLocked = true
                    PrintBedConfig(coords, heading, objModel)
                    CleanupConfiguration()
                end
            },
            {
                title = 'Cama X-Ray',
                description = 'Spawnea un monitor para rayos X',
                icon = 'tv',
                onSelect = function()
                    bedLocked = true
                    StartPlacingMonitor(coords, heading, objModel)
                end
            },
        }
    })

    lib.showContext('bed_save_menu')
end

function StartPlacingMonitor(bedCoords, bedHeading, bedModel)
    placingMonitor = true
    configMode = false

    RequestModel(Config.xrayModel)
    while not HasModelLoaded(Config.xrayModel) do
        Citizen.Wait(50)
    end

    spawnedMonitor = CreateObject(Config.xrayModel, bedCoords.x, bedCoords.y + 1.0, bedCoords.z, true, true, true)
    SetEntityHeading(spawnedMonitor, bedHeading)

    TriggerEvent('chat:addMessage', {
        color = { 0, 200, 255 },
        args = { "Config Tool", "Coloca el monitor (ENTER = Guardar, ESC = Cancelar)" }
    })

    tempBedData = {
        coords = bedCoords,
        heading = bedHeading,
        model = bedModel
    }
end

function HandleMonitorPlacement()
    if not placingMonitor or not spawnedMonitor or not DoesEntityExist(spawnedMonitor) then return end

    local hit, coords = GetCameraWorldPosition()
    if hit then
        SetEntityCoords(spawnedMonitor, coords.x, coords.y, coords.z + verticalOffset, false, false, false, true)
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

    if IsControlJustPressed(0, 191) then -- ENTER
        SaveXrayConfig()
    end
    if IsControlJustPressed(0, 322) then -- ESC
        CancelMonitorPlacement()
    end
end

function SaveXrayConfig()
    if not spawnedMonitor or not DoesEntityExist(spawnedMonitor) then return end
    if not tempBedData then return end

    local monitorCoords = GetEntityCoords(spawnedMonitor)
    local monitorRot = GetEntityRotation(spawnedMonitor, 2)

    local cfg = string.format(
        "{ coords = vector4(%.4f, %.4f, %.4f, %.4f), taken = false, model = '%s', getOutOffset = 1.3, xray = true, xrayMonitor = vector3(%.4f, %.4f, %.4f), xrayMonitorRot = vector3(%.1f, %.1f, %.1f), screenScale = 0.042, lockedBed = true },",
        tempBedData.coords.x, tempBedData.coords.y, tempBedData.coords.z - 1.0, tempBedData.heading,
        tempBedData.model,
        monitorCoords.x, monitorCoords.y, monitorCoords.z,
        monitorRot.x, monitorRot.y, monitorRot.z
    )

    print(cfg)
    if lib and lib.setClipboard then lib.setClipboard(cfg) end

    TriggerEvent('chat:addMessage', {
        color = { 0, 255, 0 },
        args = { "Config Tool", "Configuración X-Ray guardada! (F8 para copiar)" }
    })

    CleanupConfiguration()
    if spawnedMonitor then DeleteEntity(spawnedMonitor) end
    spawnedMonitor, placingMonitor = nil, false
end

function CancelMonitorPlacement()
    if spawnedMonitor and DoesEntityExist(spawnedMonitor) then
        DeleteEntity(spawnedMonitor)
    end
    spawnedMonitor, placingMonitor = nil, false
    tempBedData = nil
    TriggerEvent('chat:addMessage', { color = { 255, 0, 0 }, args = { "Config Tool", "Monitor cancelado." } })
end

function PrintBedConfig(coords, heading, modelHash)
    local configText = string.format(
        "{ coords = vector4(%.4f, %.4f, %.4f, %.4f), taken = false, model = '%s', getOutOffset = 1.3%s },",
        coords.x, coords.y, coords.z - 1, heading,
        modelHash,
        bedLocked and ", lockedBed = true" or ""
    )

    print(configText)

    TriggerEvent('chat:addMessage', {
        color = { 0, 255, 0 },
        multiline = true,
        args = { "Config Tool", "Configuración guardada! Mira la consola (F8)." }
    })

    if lib and lib.setClipboard then
        lib.setClipboard(configText)
        TriggerEvent('chat:addMessage', {
            color = { 0, 200, 255 },
            args = { "Config Tool", "Configuración copiada al portapapeles!" }
        })
    end
end

function CancelConfiguration()
    TriggerEvent('chat:addMessage', {
        color = { 255, 0, 0 },
        multiline = true,
        args = { "Config Tool", "Configuration cancelled." }
    })
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
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if configMode then
            HandleNPCMovement()

            SetTextFont(4)
            SetTextScale(0.5, 0.5)
            SetTextColour(255, 255, 255, 255)
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString("CAMERA: Follow | WHEEL/Arrows: Rotate | Q/E: Height")
            DrawText(0.1, 0.1)

            if spawnedNPC and DoesEntityExist(spawnedNPC) then
                local coords = GetEntityCoords(spawnedNPC)
                local heading = GetEntityHeading(spawnedNPC)

                SetTextFont(4)
                SetTextScale(0.4, 0.4)
                SetTextColour(0, 255, 0, 255)
                SetTextOutline()
                SetTextEntry("STRING")
                AddTextComponentString(string.format("X: %.3f | Y: %.3f | Z: %.3f | H: %.2f", coords.x, coords.y,
                    coords.z, heading))
                DrawText(0.1, 0.15)
            end
        elseif placingMonitor and spawnedMonitor and DoesEntityExist(spawnedMonitor) then
            local coords = GetEntityCoords(spawnedMonitor)
            local heading = GetEntityHeading(spawnedMonitor)

            SetTextFont(4)
            SetTextScale(0.4, 0.4)
            SetTextColour(0, 200, 255, 255)
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString(string.format("X: %.3f | Y: %.3f | Z: %.3f | H: %.2f", coords.x, coords.y, coords.z,
                heading))
            DrawText(0.1, 0.15)
            HandleMonitorPlacement()
        else
            Citizen.Wait(500)
        end
    end
end)

RegisterCommand('configbed', function()
    TriggerServerEvent("configTool:tryConfig", "bed")
end)

RegisterNetEvent("configTool:startConfig", function(type)
    if configMode then
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            args = { "Config Tool", "Ya estás en modo configuración! Usa ESC para cancelar." }
        })
        return
    end

    configMode = true
    configType = type
    SpawnConfigNPC(type)
end)

RegisterNetEvent("configTool:denied", function()
    TriggerEvent('chat:addMessage', {
        color = { 255, 0, 0 },
        args = { "Config Tool", "No tienes permisos para usar este comando." }
    })
end)

RegisterCommand('confighelp', function(source, args, rawCommand)
    TriggerServerEvent("configTool:tryHelpCommand", "bed")
end, false)

RegisterNetEvent("configTool:helpCommand", function()
    TriggerEvent('chat:addMessage', {
        color = { 0, 255, 255 },
        multiline = true,
        args = { "Config Tool Help", "Available commands:" }
    })
    TriggerEvent('chat:addMessage', {
        color = { 255, 255, 255 },
        multiline = true,
        args = { "", "/configbed - Configure bed positions" }
    })
    TriggerEvent('chat:addMessage', {
        color = { 255, 255, 255 },
        multiline = true,
        args = { "", "/confighelp - Show this help message" }
    })
end, false)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        CleanupConfiguration()
    end
end)
