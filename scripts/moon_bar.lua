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

-- ============================================================
-- BARRA LUNAR (horizontal, ya existente, adaptada)
-- ============================================================
function draw_moon_bar(cr)
    -- Leer datos desde cache
    local f = io.open(os.getenv("HOME") .. "/.cache/raw", "r")
    local illumination = 0
    local phase_text = ""
    if f then
        local line_num = 0
        for line in f:lines() do
            line_num = line_num + 1
            if line_num == 2 then
                phase_text = line
            end
            local val = line:match("Illumination:%s*(%d+)%%")
            if val then
                illumination = tonumber(val)
            end
        end
        f:close()
    end

    -- Detectar tipo de fase
    local phase_lower = phase_text:lower()
    local is_new = phase_lower:match("luna nueva")
    local is_full = phase_lower:match("luna llena")
    local is_first_quarter = phase_lower:match("cuarto creciente")
    local is_last_quarter = phase_lower:match("cuarto menguante")
    local is_waxing_crescent = phase_lower:match("luna creciente")
    local is_waxing_gibbous = phase_lower:match("gibosa creciente")
    local is_waning_crescent = phase_lower:match("creciente menguante")
    local is_waning_gibbous = phase_lower:match("gibosa menguante")
    local is_waxing = is_waxing_crescent or is_waxing_gibbous or is_first_quarter
    local is_waning = is_waning_crescent or is_waning_gibbous or is_last_quarter

    -- Configuración visual
    local x = 6
    local y = 616
    local width = 130
    local height = 12
    local radius = 6
    local hemisphere = "s"  -- "s" para Sur

    -- Sombra
    cairo_set_source_rgba(cr, 0, 0, 0, 0.4)
    rounded_rect(cr, x + 1, y + 2, width, height, radius)
    cairo_fill(cr)

    -- Fondo
    local bg_pat = cairo_pattern_create_linear(x, y, x, y + height)
    cairo_pattern_add_color_stop_rgba(bg_pat, 0, 0.15, 0.15, 0.15, 0.6)
    cairo_pattern_add_color_stop_rgba(bg_pat, 1, 0.25, 0.25, 0.25, 0.6)
    cairo_set_source(cr, bg_pat)
    rounded_rect(cr, x, y, width, height, radius)
    cairo_fill(cr)
    cairo_pattern_destroy(bg_pat)

    -- Color dinámico según fase
    local r, g, b, a = 1, 1, 0, 0.9
    if is_full then
        r, g, b = 1.0, 0.95, 0.6
    elseif is_new then
        r, g, b = 0.4, 0.4, 0.6
    elseif is_waxing then
        r, g, b = 0.9, 0.85, 0.5
    elseif is_waning then
        r, g, b = 0.6, 0.7, 0.9
    end

    -- Efecto de pulsación sutil
    local pulse = math.sin(os.clock() * 2) * 0.05 + 0.95
    r, g, b = r * pulse, g * pulse, b * pulse

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

        -- Brillo interno superior
        local shine = cairo_pattern_create_linear(x, y, x, y + height/3)
        cairo_pattern_add_color_stop_rgba(shine, 0, 1, 1, 1, 0.25)
        cairo_pattern_add_color_stop_rgba(shine, 1, 1, 1, 1, 0)
        cairo_set_source(cr, shine)
        rounded_rect(cr, x, y, fill_width, height/3, radius)
        cairo_fill(cr)
        cairo_pattern_destroy(shine)
    end

    -- Marcador vertical
    if illumination > 2 and illumination < 98 then
        local marker_x = x + fill_width
        cairo_set_source_rgba(cr, 1, 1, 1, 0.7)
        cairo_set_line_width(cr, 2)
        cairo_move_to(cr, marker_x, y)
        cairo_line_to(cr, marker_x, y + height)
        cairo_stroke(cr)
        cairo_set_source_rgba(cr, 1, 1, 1, 0.8)
        cairo_move_to(cr, marker_x, y - 3)
        cairo_line_to(cr, marker_x - 3, y)
        cairo_line_to(cr, marker_x + 3, y)
        cairo_close_path(cr)
        cairo_fill(cr)
        cairo_move_to(cr, marker_x, y + height + 3)
        cairo_line_to(cr, marker_x - 3, y + height)
        cairo_line_to(cr, marker_x + 3, y + height)
        cairo_close_path(cr)
        cairo_fill(cr)
    end

    -- Borde
    cairo_set_source_rgba(cr, 1, 1, 1, 0.3)
    cairo_set_line_width(cr, 1.5)
    rounded_rect(cr, x, y, width, height, radius)
    cairo_stroke(cr)

    -- Texto de porcentaje
    cairo_select_font_face(cr, "Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
    cairo_set_font_size(cr, 9)
    local percent_text = illumination .. "%"
    local extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, percent_text, extents)
    local text_x = x + (width - extents.width) / 2
    local text_y = y + (height + extents.height) / 2 - 1
    cairo_set_source_rgba(cr, 0, 0, 0, 0.6)
    cairo_move_to(cr, text_x + 1, text_y + 1)
    cairo_show_text(cr, percent_text)
    cairo_set_source_rgba(cr, 1, 1, 1, 0.95)
    cairo_move_to(cr, text_x, text_y)
    cairo_show_text(cr, percent_text)

    -- Emoji según hemisferio
    local phase_icon = "🌕"
    if hemisphere == "s" then
        if is_new then phase_icon = "🌑"
        elseif is_full then phase_icon = "🌕"
        elseif is_first_quarter then phase_icon = "🌗"
        elseif is_last_quarter then phase_icon = "🌓"
        elseif is_waxing_crescent then phase_icon = "🌘"
        elseif is_waxing_gibbous then phase_icon = "🌖"
        elseif is_waning_gibbous then phase_icon = "🌔"
        elseif is_waning_crescent then phase_icon = "🌒"
        end
    else
        if is_new then phase_icon = "🌑"
        elseif is_full then phase_icon = "🌕"
        elseif is_first_quarter then phase_icon = "🌓"
        elseif is_last_quarter then phase_icon = "🌗"
        elseif is_waxing_crescent then phase_icon = "🌒"
        elseif is_waxing_gibbous then phase_icon = "🌔"
        elseif is_waning_gibbous then phase_icon = "🌖"
        elseif is_waning_crescent then phase_icon = "🌘"
        end
    end
    cairo_select_font_face(cr, "Noto Color Emoji", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_font_size(cr, 14)
    cairo_set_source_rgba(cr, 1, 1, 1, 0.9)
    cairo_move_to(cr, x + width + 6, y + height - 2)
    cairo_show_text(cr, phase_icon)
end

-- ============================================================
-- TERMÓMETRO VERTICAL
-- ============================================================
function draw_thermometer_vertical(cr, x, y, width, height)

    -- ==============================
    -- Leer temperatura
    -- ==============================
    local f = io.open(os.getenv("HOME") .. "/.cache/current_temp", "r")
    local temp = 0
    if f then
        temp = tonumber(f:read("*line")) or 0
        f:close()
    end

    -- ==============================
    -- Parámetros
    -- ==============================
    local min_temp = -20
    local max_temp = 50
    local percent = (temp - min_temp) / (max_temp - min_temp)
    percent = math.max(0, math.min(1, percent))

    -- ==============================
    -- Geometría
    -- ==============================
    local bulb_radius = width * 0.45
    local tube_width = width * 0.7
    local tube_x = x + (width - tube_width) / 2
    -- el tubo arranca arriba
	local tube_y = y + 1
	-- el tubo termina justo en el centro del bulbo
	local overlap = bulb_radius * 2.1   -- cuánto entra el tubo en el bulbo
    local tube_height = (y + height - overlap) - tube_y

    local bulb_cx = x + width/2
    local bulb_cy = y + height - bulb_radius

    -- ==============================
    -- SOMBRA SUAVE (fake blur)
    -- ==============================
    for i = 1, 6 do
        cairo_set_source_rgba(cr, 0, 0, 0, 0.05)
        cairo_arc(cr, bulb_cx + i, bulb_cy + i, bulb_radius + i, 0, 2*math.pi)
        cairo_fill(cr)

        rounded_rect(cr, tube_x + i, tube_y + i, tube_width, tube_height, 5)
        cairo_fill(cr)
    end

    -- ==============================
    -- VIDRIO (cuerpo)
    -- ==============================
    -- Bulbo
    cairo_arc(cr, bulb_cx, bulb_cy, bulb_radius, 0, 2*math.pi)
    local pat = cairo_pattern_create_radial(
        bulb_cx - bulb_radius*0.3, bulb_cy - bulb_radius*0.3, 2,
        bulb_cx, bulb_cy, bulb_radius
    )
    cairo_pattern_add_color_stop_rgba(pat, 0, 0.9, 0.9, 0.95, 0.8)
    cairo_pattern_add_color_stop_rgba(pat, 1, 0.3, 0.3, 0.35, 0.8)
    cairo_set_source(cr, pat)
    cairo_fill(cr)
    cairo_pattern_destroy(pat)

    -- Tubo
    rounded_rect(cr, tube_x, tube_y, tube_width, tube_height, 5)
    pat = cairo_pattern_create_linear(tube_x, tube_y, tube_x + tube_width, tube_y)
    cairo_pattern_add_color_stop_rgba(pat, 0, 0.85, 0.85, 0.95, 0.6)
    cairo_pattern_add_color_stop_rgba(pat, 1, 0.25, 0.25, 0.35, 0.6)
    cairo_set_source(cr, pat)
    cairo_fill(cr)
    cairo_pattern_destroy(pat)

    -- ==============================
    -- FLUIDO
    -- ==============================
    local fill_height = percent * tube_height
    local fill_y = tube_y + tube_height - fill_height

    -- Color dinámico
    local r, g, b
    if temp < 10 then
        -- Azul medio	Frío, hielo, agua helada
        r, g, b = 0.2, 0.5, 1.0
    elseif temp < 20 then
		--  Verde vivo	Templado, fresco, naturaleza
        r, g, b = 0.2, 0.8, 0.2
    elseif temp < 30 then
        -- Naranja Cálido, verano, agradable calidez
        r, g, b = 1.0, 0.6, 0.2
    else
		-- Rojo intenso	Calor extremo, alerta, peligro
        r, g, b = 1.0, 0.2, 0.2
    end

    -- Tubo (fluido)
    if fill_height > 0 then
        cairo_save(cr)
        rounded_rect(cr, tube_x, fill_y, tube_width, fill_height, 5)
        cairo_clip(cr)

        local patf = cairo_pattern_create_linear(tube_x, fill_y, tube_x, fill_y + fill_height)
        cairo_pattern_add_color_stop_rgba(patf, 0, r*0.8, g*0.8, b*0.8, 0.95)
        cairo_pattern_add_color_stop_rgba(patf, 1, r, g, b, 0.95)
        cairo_set_source(cr, patf)
        cairo_rectangle(cr, tube_x, fill_y, tube_width, fill_height)
        cairo_fill(cr)
        cairo_pattern_destroy(patf)

        -- Highlight lateral (volumen)
        cairo_set_source_rgba(cr, 1, 1, 1, 0.15)
        cairo_rectangle(cr, tube_x + 2, fill_y, tube_width * 0.25, fill_height)
        cairo_fill(cr)

        -- Menisco (detalle pro)
        cairo_set_source_rgba(cr, 1, 1, 1, 0.25)
        cairo_move_to(cr, tube_x, fill_y)
        cairo_curve_to(cr,
            tube_x + tube_width*0.25, fill_y - 2,
            tube_x + tube_width*0.75, fill_y - 2,
            tube_x + tube_width, fill_y)
        cairo_stroke(cr)

        cairo_restore(cr)
    end

    -- Bulbo (fluido)
    if percent > 0 then
        cairo_arc(cr, bulb_cx, bulb_cy, bulb_radius - 2, 0, 2*math.pi)
        local patb = cairo_pattern_create_radial(
            bulb_cx, bulb_cy, 1,
            bulb_cx, bulb_cy, bulb_radius
        )
        cairo_pattern_add_color_stop_rgba(patb, 0, r, g, b, 0.95)
        cairo_pattern_add_color_stop_rgba(patb, 1, r*0.4, g*0.4, b*0.4, 0.95)
        cairo_set_source(cr, patb)
        cairo_fill(cr)
        cairo_pattern_destroy(patb)
    end

    -- ==============================
    -- REFLEJOS (vidrio)
    -- ==============================
    cairo_set_line_width(cr, 1.2)

    -- Bordes
    cairo_set_source_rgba(cr, 1, 1, 1, 0.4)
    cairo_arc(cr, bulb_cx, bulb_cy, bulb_radius, 0, 2*math.pi)
    cairo_stroke(cr)

    rounded_rect(cr, tube_x, tube_y, tube_width, tube_height, 5)
    cairo_stroke(cr)

    -- Brillo vertical
    cairo_set_source_rgba(cr, 1, 1, 1, 0.25)
    cairo_move_to(cr, tube_x + 3, tube_y + 5)
    cairo_line_to(cr, tube_x + 3, tube_y + tube_height - 5)
    cairo_stroke(cr)

    -- Brillo fuerte bulbo
    cairo_set_source_rgba(cr, 1, 1, 1, 0.35)
    cairo_arc(cr,
        bulb_cx - bulb_radius*0.3,
        bulb_cy - bulb_radius*0.4,
        bulb_radius*0.25,
        0, 2*math.pi)
    cairo_fill(cr)

    -- ==============================
    -- ESCALA
    -- ==============================
    cairo_set_source_rgba(cr, 1, 1, 1, 0.7)
    cairo_set_font_size(cr, 8)
    cairo_select_font_face(cr, "Sans", 0, 0)

    local scale_x = x + width + 8

    for t = min_temp, max_temp, 10 do
        local y_pos = tube_y + tube_height - (t - min_temp)/(max_temp - min_temp)*tube_height

        cairo_move_to(cr, scale_x - 3, y_pos)
        cairo_line_to(cr, scale_x, y_pos)
        cairo_stroke(cr)

        cairo_move_to(cr, scale_x + 2, y_pos + 3)
        cairo_show_text(cr, t .. "°")
    end

    -- ==============================
    -- TEXTO
    -- ==============================
    cairo_set_font_size(cr, 16)
    cairo_select_font_face(cr, "Sans", 0, 1)
    cairo_set_source_rgba(cr, 1, 1, 1, 0.95)

    local txt = string.format("%.0f°C", temp)
    cairo_move_to(cr, bulb_cx - 10, bulb_cy + bulb_radius + 14)
    cairo_show_text(cr, txt)

end

-- ============================================================
-- FUNCIÓN PRINCIPAL (llamada por Conky)
-- ============================================================
function conky_draw()
    if conky_window == nil then return end

    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable,
        conky_window.visual, conky_window.width, conky_window.height)
    local cr = cairo_create(cs)

    -- Dibujar barra lunar (sus coordenadas están fijas dentro de la función)
    draw_moon_bar(cr)

    -- Dibujar termómetro vertical (ajusta x, y, ancho, alto a tu gusto)
    draw_thermometer_vertical(cr, 215, 10, 20, 90)

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end
