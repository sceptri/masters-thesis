function read_file(path)
	local file = io.open(path, "rb") -- r read mode and b binary mode
	if not file then return nil end
		local content = file:read "*a" -- *a or *all reads the whole file
		file:close()
	return content
end

function getMetaValue (keys, meta)
	local value = meta;

	for _id, key in ipairs(keys)
	do
		value = value[key];
	end

	return value;
end

function setMetaValue (val, keys, meta)
	local reversedObjects = {};
	local reversedKeys = {};
	local insert = val;
	local value = meta;

	for _id, key in ipairs(keys)
	do
		if( _id == #keys)
		then
			value[key] = insert;
		else
			table.insert(reversedObjects, 1, value)
			table.insert(reversedKeys, 1, key)
			value = value[key]
		end
	end

	for index, object in ipairs(reversedObjects)
	do
		object[reversedKeys[index]] = value
		value = object
	end

	return value
end

function updateMeta (keys, meta)
	local partial = pandoc.utils.stringify(getMetaValue(keys, meta))
	local filePartial = pandoc.read(read_file(partial));

	meta = setMetaValue(pandoc.utils.blocks_to_inlines(filePartial.blocks), keys, meta)

	return meta
end

function Meta (meta)
	partialMetas = {
		{"thesis", "abstract", "en"},
		{"thesis", "abstract", "cz"},
		{"thesis", "acknowledgement", "cz"},
		{"thesis", "acknowledgement", "en"},
		{"thesis", "declaration", "cz"},
		{"thesis", "declaration", "en"},
	};

	for _id, keys in ipairs(partialMetas)
	do
		meta = updateMeta(keys, meta);
	end

	return meta
end

