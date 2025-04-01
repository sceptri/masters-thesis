function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function Div(el)
	if FORMAT:match 'latex' then
		if has_value(el.classes, 'floatbox') then
			return {
				pandoc.RawBlock("latex", "\\begin{floatbox}"),
				el,
				pandoc.RawBlock("latex", "\\end{floatbox}")
			}
		end
	end

	return el
end