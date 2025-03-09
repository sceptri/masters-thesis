local current_width = nil

function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function Div(elem)
    -- Check if the Div contains the width parameter
    if elem.classes:includes("cell") and elem.attributes.width then
        current_width = elem.attributes.width
        -- Process the contents of the Div and reset the width after processing
        local processed_contents = pandoc.walk_block(elem, { Image = Image })
        current_width = nil
        return pandoc.Div(processed_contents, elem.attr)
    end

    return nil
end

function Image(elem)
    if FORMAT:match 'latex' then
        if has_value(elem.classes, 'final') then
            return elem
        end

        -- Use the width from the current surrounding Div if available
        if current_width then
            elem.attributes.width = current_width
        else
            elem.attributes.width = '98%'
        end
        elem.attributes.height = nil

        -- Surround the image with LaTeX for centering
        return {
            pandoc.RawInline('latex', '\\hfill\\break{\\centering'),
            elem,
            pandoc.RawInline('latex', '\\par}')
        }
    end

    return nil
end
