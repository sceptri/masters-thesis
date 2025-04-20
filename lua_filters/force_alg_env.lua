string.startswith = function(self, str) 
    return self:find('^' .. str) ~= nil
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end


function Callout(el)
	if (el.attr.identifier:startswith('alg')) then
		-- print(el)
		if FORMAT:match 'html' then
			el.type = "algorithm"
		end
	end

	return el
end