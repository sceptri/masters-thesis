string.startswith = function(self, str) 
    return self:find('^' .. str) ~= nil
end

if FORMAT:match 'html' then
	function Callout(el)
			
		if (el.attr.identifier:startswith('alg')) then
			el.type = "algorithm"
		end
		
		return el
	end
end