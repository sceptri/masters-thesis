-- Hide echoed code with this function if the target format is LaTeX.
-- to show the code in the PDF, add
-- #| tags: 
-- #|   - show-in-pdf
if FORMAT:match 'latex' then
	function Div(el)
  		if el.classes:includes("cell") then
			local show_code = false
			if type(el.attributes.tags) == "string" then
				local el_tags = pandoc.json.decode(el.attributes.tags)
				show_code = el_tags:includes("show-in-pdf")
			end

			if (el.content[1].t == "CodeBlock" and not show_code) then
				el.content:remove(1)
			end
  		end
  		return el
	end
end