-- Not needed right now...
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


-- Unfortunately, Quarto executes when-meta BEFORE the pandoc filter runs and I couldn't get it to work...
-- Still it might prove useful, so I'll leave it here
function Meta (meta)
	local bachelor = "Bc"
	local masters = "Mgr"
	local doctor = "RNDr"

	local thesis_type = pandoc.utils.stringify(meta["thesis"]["type"])

	if (thesis_type == bachelor)
	then
		meta["thesis"]["is_bachelor"] = true
	elseif (thesis_type == masters)
	then
		meta["thesis"]["is_masters"] = true
	elseif (thesis_type == doctor)
	then
		meta["thesis"]["is_doctor"] = true
	end
	
	return meta
end