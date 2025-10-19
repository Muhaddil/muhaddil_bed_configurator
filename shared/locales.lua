Locales = {}

Locales['es'] = {
    ['command_configbed'] = 'Configurar posiciones de camas',
    ['command_configpager'] = 'Configurar posiciones de pantallas de pager',
    ['command_confighelp'] = 'Mostrar ayuda de comandos',
    
    ['already_configuring'] = 'Ya estás en modo configuración! Usa ESC para cancelar.',
    ['no_permission'] = 'No tienes permisos para usar este comando.',
    ['config_started'] = 'Configurando %s - El NPC sigue tu cámara:',
    ['config_cancelled'] = 'Configuración cancelada.',
    ['config_saved'] = 'Configuración guardada! Mira la consola (F8).',
    ['config_copied'] = 'Configuración copiada al portapapeles!',
    
    ['instructions_camera'] = 'CÁMARA: El NPC sigue donde miras | RUEDA RATÓN: Rotar',
    ['instructions_controls'] = 'Flechas: Rotar | Q/E: Ajustar altura | ENTER: Guardar | ESC: Cancelar',
    ['instructions_place_monitor'] = 'Coloca el monitor (ENTER = Guardar, ESC = Cancelar)',
    ['instructions_place_pager'] = 'Coloca la pantalla (ENTER = Guardar, ESC = Cancelar)',
    
    ['bed_save_title'] = 'Guardar configuración de cama',
    ['bed_normal'] = 'Cama normal',
    ['bed_normal_desc'] = 'Usable para check-in',
    ['bed_locked'] = 'Cama bloqueada',
    ['bed_locked_desc'] = 'No se podrá usar para check-in',
    ['bed_xray'] = 'Cama X-Ray',
    ['bed_xray_desc'] = 'Spawnea un monitor para rayos X',
    ['bed_ecg'] = 'Cama ECG',
    ['bed_ecg_desc'] = 'Spawnea un monitor para ECG',
    
    ['monitor_saved'] = 'Configuración %s guardada! (F8 para copiar)',
    ['monitor_cancelled'] = 'Monitor cancelado.',
    ['pager_saved'] = 'Posiciones de pantalla guardadas! (F8 / portapapeles)',
    ['pager_cancelled'] = 'Colocación cancelada.',
    
    ['help_title'] = 'Ayuda del Configurador',
    ['help_available'] = 'Comandos disponibles:',
    
    ['anim_bed'] = 'Posición de Cama',
    
    ['hud_camera_follow'] = 'CÁMARA: Seguir | RUEDA/Flechas: Rotar | Q/E: Altura',
    ['hud_coords'] = 'X: %.3f | Y: %.3f | Z: %.3f | H: %.2f',
    ['hud_monitor'] = 'MONITOR - X: %.3f | Y: %.3f | Z: %.3f | H: %.2f',
    ['hud_pager'] = 'PAGER - X: %.3f | Y: %.3f | Z: %.3f | H: %.2f',
    
    ['label_coordinates'] = 'COORDENADAS',
    ['label_controls'] = 'CONTROLES',
    ['label_camera'] = 'CÁMARA',
    ['label_wheel_arrows'] = 'RUEDA / ← →',
    ['label_up_down'] = '↑ ↓',
    ['label_enter'] = 'ENTER',
    ['label_esc'] = 'ESC',
    ['control_camera_desc'] = 'Seguir posición',
    ['control_rotate_desc'] = 'Rotar objeto',
    ['control_height_desc'] = 'Ajustar altura',
    ['control_save_desc'] = 'Guardar configuración',
    ['control_cancel_desc'] = 'Cancelar',
}

Locales['en'] = {
    ['command_configbed'] = 'Configure bed positions',
    ['command_configpager'] = 'Configure pager screen positions',
    ['command_confighelp'] = 'Show command help',
    
    ['already_configuring'] = 'You are already in configuration mode! Press ESC to cancel.',
    ['no_permission'] = 'You do not have permission to use this command.',
    ['config_started'] = 'Configuring %s - NPC follows your camera:',
    ['config_cancelled'] = 'Configuration cancelled.',
    ['config_saved'] = 'Configuration saved! Check the console (F8).',
    ['config_copied'] = 'Configuration copied to clipboard!',
    
    ['instructions_camera'] = 'CAMERA: NPC follows where you look | MOUSE WHEEL: Rotate',
    ['instructions_controls'] = 'Arrows: Rotate | Q/E: Adjust height | ENTER: Save | ESC: Cancel',
    ['instructions_place_monitor'] = 'Place the monitor (ENTER = Save, ESC = Cancel)',
    ['instructions_place_pager'] = 'Place the screen (ENTER = Save, ESC = Cancel)',
    
    ['bed_save_title'] = 'Save bed configuration',
    ['bed_normal'] = 'Normal bed',
    ['bed_normal_desc'] = 'Usable for check-in',
    ['bed_locked'] = 'Locked bed',
    ['bed_locked_desc'] = 'Cannot be used for check-in',
    ['bed_xray'] = 'X-Ray bed',
    ['bed_xray_desc'] = 'Spawns an X-Ray monitor',
    ['bed_ecg'] = 'ECG bed',
    ['bed_ecg_desc'] = 'Spawns an ECG monitor',
    
    ['monitor_saved'] = 'Configuration %s saved! (F8 to copy)',
    ['monitor_cancelled'] = 'Monitor cancelled.',
    ['pager_saved'] = 'Screen positions saved! (F8 / clipboard)',
    ['pager_cancelled'] = 'Placement cancelled.',
    
    ['help_title'] = 'Configurator Help',
    ['help_available'] = 'Available commands:',
    
    ['anim_bed'] = 'Bed Position',
    
    ['hud_camera_follow'] = 'CAMERA: Follow | WHEEL/Arrows: Rotate | Q/E: Height',
    ['hud_coords'] = 'X: %.3f | Y: %.3f | Z: %.3f | H: %.2f',
    ['hud_monitor'] = 'MONITOR - X: %.3f | Y: %.3f | Z: %.3f | H: %.2f',
    ['hud_pager'] = 'PAGER - X: %.3f | Y: %.3f | Z: %.3f | H: %.2f',
    
    ['label_coordinates'] = 'COORDINATES',
    ['label_controls'] = 'CONTROLS',
    ['label_camera'] = 'CAMERA',
    ['label_wheel_arrows'] = 'WHEEL / ← →',
    ['label_up_down'] = '↑ ↓',
    ['label_enter'] = 'ENTER',
    ['label_esc'] = 'ESC',
    ['control_camera_desc'] = 'Follow position',
    ['control_rotate_desc'] = 'Rotate object',
    ['control_height_desc'] = 'Adjust height',
    ['control_save_desc'] = 'Save configuration',
    ['control_cancel_desc'] = 'Cancel',
}

function _L(key, ...)
    local locale = Config.Locale or 'en'
    local text = Locales[locale] and Locales[locale][key] or key
    local args = { ... }
    if #args > 0 then
        return string.format(text, table.unpack(args))
    else
        return text
    end
end
