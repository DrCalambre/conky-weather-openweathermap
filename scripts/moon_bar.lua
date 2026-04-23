require 'cairo'
-- ==============================
-- FUNCIÓN AUXILIAR: Rectángulo redondeado
-- ==============================
function rounded_rect(cr, x, y, w, h, r)
    cairo_new_sub_path(cr)
    cairo_arc(cr, x + w - r, y + r, r, -math.pi/2, 0)
    cairo_arc(cr, x + w - r, y + h - r, r, 0, math.pi/2)
    cairo_arc(cr, x + r, y + h - r, r, math.pi/2, math.pi)
    cairo_arc(cr, x + r, y + r, r, math.pi, 3*math.pi/2)
    cairo_close_path(cr)
end
-- ==============================
-- FUNCIÓN PRINCIPAL
-- ==============================
function conky_draw_moon_bar()
    if conky_window == nil then return end
    
    local cs = cairo_xlib_surface_create(
        conky_window.display,
        conky_window.drawable,
        conky_window.visual,
        conky_window.width,
        conky_window.height
    )
    local cr = cairo_create(cs)
    
    -- ==============================
    -- CONFIGURACIÓN DE HEMISFERIO
    -- ==============================
    local hemisphere = "s"  -- "s" para Sur, "n" para Norte
    
    -- ==============================
    -- Leer datos desde cache
    -- ==============================
    local f = io.open(os.getenv("HOME") .. "/.cache/raw", "r")
    local illumination = 0
    local phase_text = ""
    if f then
        local line_num = 0
        for line in f:lines() do
            line_num = line_num + 1
        
            -- Línea 2: nombre de la fase
            if line_num == 2 then
                phase_text = line
            end
        
            -- Línea 3: iluminación
            local val = line:match("Illumination:%s*(%d+)%%")
            if val then 
                illumination = tonumber(val)
            end
        end
        f:close()
    end
    -- ==============================
    -- Detectar tipo de fase
    -- ==============================
    local phase_lower = phase_text:lower()
    -- Detección de fases específicas en español
    local is_new = phase_lower:match("luna nueva")
    local is_full = phase_lower:match("luna llena")
    local is_first_quarter = phase_lower:match("cuarto creciente")
    local is_last_quarter = phase_lower:match("cuarto menguante")
    local is_waxing_crescent = phase_lower:match("luna creciente")
    local is_waxing_gibbous = phase_lower:match("gibosa creciente")
    local is_waning_crescent = phase_lower:match("creciente menguante")
    local is_waning_gibbous = phase_lower:match("gibosa menguante")
    -- Detección genérica (fallback)
    local is_waxing = is_waxing_crescent or is_waxing_gibbous or is_first_quarter
    local is_waning = is_waning_crescent or is_waning_gibbous or is_last_quarter
    
    -- ==============================
    -- CONFIGURACIÓN VISUAL
    -- ==============================
    local x = 6
    local y = 616
    local width = 130
    local height = 12
    local radius = 6  -- Radio para bordes redondeados
    
    -- ==============================
    -- Sombra exterior (profundidad)
    -- ==============================
    cairo_set_source_rgba(cr, 0, 0, 0, 0.4)
    rounded_rect(cr, x + 1, y + 2, width, height, radius)
    cairo_fill(cr)
    
    -- ==============================
    -- Fondo (barra vacía) con gradiente sutil
    -- ==============================
    local bg_pat = cairo_pattern_create_linear(x, y, x, y + height)
    cairo_pattern_add_color_stop_rgba(bg_pat, 0, 0.15, 0.15, 0.15, 0.6)
    cairo_pattern_add_color_stop_rgba(bg_pat, 1, 0.25, 0.25, 0.25, 0.6)
    cairo_set_source(cr, bg_pat)
    rounded_rect(cr, x, y, width, height, radius)
    cairo_fill(cr)
    cairo_pattern_destroy(bg_pat)
    
    -- ==============================
    -- Color dinámico según fase
    -- ==============================
    local r, g, b, a = 1, 1, 0, 0.9  -- default amarillo
    
    if is_full then
        r, g, b = 1.0, 0.95, 0.6  -- dorado brillante
    elseif is_new then
        r, g, b = 0.4, 0.4, 0.6  -- gris azulado oscuro
    elseif is_waxing then
        r, g, b = 0.9, 0.85, 0.5  -- amarillo cálido
    elseif is_waning then
        r, g, b = 0.6, 0.7, 0.9  -- azul pálido
    end
    
    -- Efecto de pulsación sutil
    local pulse = math.sin(os.clock() * 2) * 0.05 + 0.95
    r, g, b = r * pulse, g * pulse, b * pulse
    
    -- ==============================
    -- Barra principal con gradiente
    -- ==============================
    local fill_width = width * (illumination / 100)
    
    if fill_width > 0 then
        local pat = cairo_pattern_create_linear(x, y, x + fill_width, y)
        cairo_pattern_add_color_stop_rgba(pat, 0, r * 1.2, g * 1.2, b * 1.2, a)
        cairo_pattern_add_color_stop_rgba(pat, 0.5, r, g, b, a)
        cairo_pattern_add_color_stop_rgba(pat, 1, r * 0.7, g * 0.7, b * 0.7, a)
        cairo_set_source(cr, pat)
        rounded_rect(cr, x, y, fill_width, height, radius)
        cairo_fill(cr)
        cairo_pattern_destroy(pat)
        
        -- ==============================
        -- Efecto de brillo interno (parte superior)
        -- ==============================
        local shine = cairo_pattern_create_linear(x, y, x, y + height/3)
        cairo_pattern_add_color_stop_rgba(shine, 0, 1, 1, 1, 0.25)
        cairo_pattern_add_color_stop_rgba(shine, 1, 1, 1, 1, 0)
        cairo_set_source(cr, shine)
        rounded_rect(cr, x, y, fill_width, height/3, radius)
        cairo_fill(cr)
        cairo_pattern_destroy(shine)
    end
    
    -- ==============================
    -- Indicador de porcentaje (marcador vertical)
    -- ==============================
    if illumination > 2 and illumination < 98 then
        local marker_x = x + fill_width
        
        -- Línea vertical brillante
        cairo_set_source_rgba(cr, 1, 1, 1, 0.7)
        cairo_set_line_width(cr, 2)
        cairo_move_to(cr, marker_x, y)
        cairo_line_to(cr, marker_x, y + height)
        cairo_stroke(cr)
        
        -- Triángulo superior
        cairo_set_source_rgba(cr, 1, 1, 1, 0.8)
        cairo_move_to(cr, marker_x, y - 3)
        cairo_line_to(cr, marker_x - 3, y)
        cairo_line_to(cr, marker_x + 3, y)
        cairo_close_path(cr)
        cairo_fill(cr)
        
        -- Triángulo inferior
        cairo_move_to(cr, marker_x, y + height + 3)
        cairo_line_to(cr, marker_x - 3, y + height)
        cairo_line_to(cr, marker_x + 3, y + height)
        cairo_close_path(cr)
        cairo_fill(cr)
    end
    
    -- ==============================
    -- Borde exterior con brillo
    -- ==============================
    cairo_set_source_rgba(cr, 1, 1, 1, 0.3)
    cairo_set_line_width(cr, 1.5)
    rounded_rect(cr, x, y, width, height, radius)
    cairo_stroke(cr)
    
    -- ==============================
    -- Texto de porcentaje dentro de la barra
    -- ==============================
    cairo_select_font_face(cr, "Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
    cairo_set_font_size(cr, 9)
    
    local percent_text = illumination .. "%"
    local extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, percent_text, extents)
    
    local text_x = x + (width - extents.width) / 2
    local text_y = y + (height + extents.height) / 2 - 1
    
    -- Sombra del texto
    cairo_set_source_rgba(cr, 0, 0, 0, 0.6)
    cairo_move_to(cr, text_x + 1, text_y + 1)
    cairo_show_text(cr, percent_text)
    
    -- Texto principal
    cairo_set_source_rgba(cr, 1, 1, 1, 0.95)
    cairo_move_to(cr, text_x, text_y)
    cairo_show_text(cr, percent_text)
    
    -- ==============================
    -- Icono de fase lunar CON CORRECCIÓN POR HEMISFERIO
    -- ==============================
    local phase_icon = "🌕"  -- default (luna llena)
    
    if hemisphere == "s" then
        -- HEMISFERIO SUR (emojis invertidos)
        if is_new then
            phase_icon = "🌑"  -- Luna Nueva (igual en ambos hemisferios)
        elseif is_full then
            phase_icon = "🌕"  -- Luna Llena (igual en ambos hemisferios)
        elseif is_first_quarter then
            phase_icon = "🌗"  -- Cuarto Creciente visto desde el Sur
        elseif is_last_quarter then
            phase_icon = "🌓"  -- Cuarto Menguante visto desde el Sur
        elseif is_waxing_crescent then
            phase_icon = "🌘"  -- Luna Creciente vista desde el Sur
        elseif is_waxing_gibbous then
            phase_icon = "🌖"  -- Gibosa Creciente vista desde el Sur
        elseif is_waning_gibbous then
            phase_icon = "🌔"  -- Gibosa Menguante vista desde el Sur
        elseif is_waning_crescent then
            phase_icon = "🌒"  -- Creciente Menguante vista desde el Sur
        end
    else
        -- HEMISFERIO NORTE (emojis normales)
        if is_new then
            phase_icon = "🌑"  -- Luna Nueva
        elseif is_full then
            phase_icon = "🌕"  -- Luna Llena
        elseif is_first_quarter then
            phase_icon = "🌓"  -- Cuarto Creciente
        elseif is_last_quarter then
            phase_icon = "🌗"  -- Cuarto Menguante
        elseif is_waxing_crescent then
            phase_icon = "🌒"  -- Luna Creciente
        elseif is_waxing_gibbous then
            phase_icon = "🌔"  -- Gibosa Creciente
        elseif is_waning_gibbous then
            phase_icon = "🌖"  -- Gibosa Menguante
        elseif is_waning_crescent then
            phase_icon = "🌘"  -- Creciente Menguante
        end
    end
    
    -- Usar la fuente Noto Color Emoji 
    -- "sudo apt-get install fonts-noto-color-emoji"
    
    cairo_select_font_face(cr, "Noto Color Emoji", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_font_size(cr, 14)
    cairo_set_source_rgba(cr, 1, 1, 1, 0.9)
    cairo_move_to(cr, x + width + 6, y + height - 2)
    cairo_show_text(cr, phase_icon)
    
    -- ==============================
    -- Limpieza
    -- ==============================
    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end
