function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end


-- Filter images with this function if the target format is LaTeX.
if FORMAT:match 'latex' then
	function Image (elem)
		if has_value(elem.classes, 'final') then
			return elem
		end

		elem.attributes.width = '98%'
		elem.attributes.height = nil
		-- Surround all images with image-centering raw LaTeX.
		return {
			pandoc.RawInline('latex', '\\hfill\\break{\\centering'),
			elem,
			pandoc.RawInline('latex', '\\par}')
		}
	end
end