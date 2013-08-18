---
-- A test program for the http server.

--look for packages one folder up.
package.path = package.path .. ";Lumen/?.lua"

luasql = require 'luasql.sqlite3'

require "log".setlevel('ALL', 'HTTP')
--require "log".setlevel('ALL')

--require "strict"

local sched = require "sched"
local json = require "lib/dkjson"
local img_path, script_path, style_path = 'dist/images', 'dist/scripts', 'dist/styles'

require "tasks/selector".init({service='luasocket'})

local http_server = require "tasks/http-server"

http_server.serve_static_content_from_ram('/', 'dist')

if service=='nixio' then
	http_server.serve_static_content_from_stream('/images/', img_path)
	http_server.serve_static_content_from_stream('/scripts/', script_path)
	http_server.serve_static_content_from_stream('/styles/', style_path)
else
	http_server.serve_static_content_from_ram('/images/', img_path)
	http_server.serve_static_content_from_ram('/scripts/', script_path)
	http_server.serve_static_content_from_ram('/styles/', style_path)
end

function print_r(arr, indentLevel)
	local str = ""
	local indentStr = "#"

	if(indentLevel == nil) then
		print(print_r(arr, 0))
		return
	end

	for i = 0, indentLevel do
		indentStr = indentStr.."\t"
	end

	for index,value in pairs(arr) do
		if type(value) == "table" then
			str = str..indentStr..index..": \n"..print_r(value, (indentLevel + 1))
		else 
			str = str..indentStr..index..": "..value.."\n"
		end
	end
	return str
end

sched.sigrun({emitter='*', events={sched.EVENT_DIE}}, print)

http_server.set_websocket_protocol('lumen-shell-protocol', function(ws)
	local shell = require 'tasks/shell' 
	local sh = shell.new_shell()
	
	sched.run(function()
		while true do
			local message,opcode = ws:receive()
			if not message then
				ws:close()
				return
			end
			if opcode == ws.TEXT then
				sh.pipe_in:write('line', message)
			end
		end
	end):attach(sh.task)
	
	sched.run(function()
		while true do
			local _, prompt, out = sh.pipe_out:read()
			if out then 
				assert (ws:send(tostring(out)..'\r\n'))
			end
			if prompt then
				assert (ws:send(prompt))
			end
		end
	end)
end)

--/api/cards GET
http_server.set_request_handler('GET', '/api/cards', function(method, path, http_params, http_header)

	init_db()
	
	local cards = {}, input
	local env = assert (luasql.sqlite3())
	local conn = assert (env:connect('db/openwrt.db'))

	local cur = assert (conn:execute('SELECT * FROM cards'))
	local row = cur:fetch({})

	-- fetch cards
	while row do
		card = { ['id'] = row[1], ['name'] = row[2], ['inputs'] = {} }
		table.insert(cards, card)
		row = cur:fetch(row)
	end

	for i,card in pairs(cards) do
		-- get fetched inputs by card id
		cur = assert (conn:execute(string.format([[
			SELECT * FROM inputs WHERE id = %i
		]], card['id'])))

		-- fetch inputs
		row = cur:fetch({})
		while row do
			input = { ['id'] = row[1], ['name'] = row[2], ['type'] = row[3], ['value'] = row[4], ['card_id'] = row[5] }
			table.insert(cards[i]['inputs'], input)
			row = cur:fetch(row)
		end
	end

	content = json.encode(cards)

	cur:close()
	conn:close()
	env:close()

	return 200, {['Content-Type']='application/json', ['Content-Length']=#content}, content
end)

--/api/cards POST
http_server.set_request_handler('POST', '/api/cards', function(method, path, http_params, http_header)

	init_db()
	
	local env = assert (luasql.sqlite3())
	local conn = assert (env:connect('db/openwrt.db'))
	local cur
	
	if http_params['cards']~=nil then
		-- get cards params
		local cards=http_params['cards']
		for i,card in pairs(cards) do
			if card['name']~=nil then
				local name = conn:escape(card['name'])
				-- insert cards
				cur = assert (conn:execute(string.format([[
					INSERT INTO cards('name') VALUES ('%s')
				]], name)))
				-- get last insert row id
				local card_id = conn:getlastautoid()
				-- insert inputs
				if card['inputs']~=nil then
					local inputs = card['inputs']
					for j,input in pairs(inputs) do
						if input['name']~=nil and input['type']~=nil and input['value']~=nil then
							local input_name = conn:escape(input['name'])
							local input_type = conn:escape(input['type'])
							local input_value = conn:escape(input['value'])
							cur = assert (conn:execute(string.format([[
								INSERT INTO inputs('name', 'type', 'value', 'card_id') VALUES('%s', '%s', '%s', %d)
							]], input_name, input_type, input_value, card_id)))
						end
					end
				end
			end
		end
	end
	
	conn:close()
	env:close()
	
	return 200
end)

--/api/cards PUT
http_server.set_request_handler('PUT', '/api/cards', function(method, path, http_params, http_header)

	init_db()
	
	local env = assert (luasql.sqlite3())
	local conn = assert (env:connect('db/openwrt.db'))
	local cur

	if http_params['cards']~=nil then
		-- get cards params
		local cards=http_params['cards']
		for i,card in pairs(cards) do
			if card['id']~=nil and card['name']~=nil then
				local id = conn:escape(card['id'])
				-- insert cards
				cur = assert (conn:execute(string.format([[
					SELECT * FROM cards WHERE id = %d
				]], id)))

				-- update cards
				row = cur:fetch({})
				if row['id']~=nil then
					cur = assert (conn:execute(string.format([[
						UPDATE cards SET name = '%s' WHERE id = $d
					]], name, id)))
				end

				-- update inputs by cards
				local ids = {}

				if card['inputs']~=nil then
					local inputs = card['inputs']
					for j,input in pairs(inputs) do
						-- update input
						if input['id']~=nil then

							-- add to ids array for clean up all inputs
							table.insert(ids, input['id'])

							cur = assert (conn:execute(string.format([[
								SELECT * FROM inputs WHERE id = %d
							]], id)))

							row = cur:fetch({})
							if row['id']~=nil then
								local input_name = row[2]
								local input_type = row[3]
								local input_value = row[4]
								if input['name'] then input_name = conn:escape(input['name']) end
								if input['type'] then input_type = conn:escape(input['type']) end
								if input['value'] then input_value = conn:escape(input['value']) end
								cur = assert (conn:execute(string.format([[
									UPDATE inputs SET name = '%s', type = '%s', value = '%s' WHERE id = $d
								]], name, type, value, id)))
							end
						-- insert new input
						else
							if input['name']~=nil and input['type']~=nil and input['value']~=nil then
								local input_name = conn:escape(input['name'])
								local input_type = conn:escape(input['type'])
								local input_value = conn:escape(input['value'])
								cur = assert (conn:execute(string.format([[
									INSERT INTO inputs('name', 'type', 'value', 'card_id') VALUES('%s', '%s', '%s', %d)
								]], input_name, input_type, input_value, card_id)))
							end
						end
					end
				end

				-- delete all removed inputs by cards
				cur = assert (conn:execute(string.format([[
					DELETE FROM inputs WHERE id NOT IN %s
				]], table.concat(ids, ","))))
			end
		end
	end

	conn:close()
	env:close()
	
	return 200
end)

--/api/cards DELETE
http_server.set_request_handler('DELETE', '/api/cards', function(method, path, http_params, http_header)

	init_db()

	local env = assert (luasql.sqlite3())
	local conn = assert (env:connect('db/openwrt.db'))

	conn:close()
	env:close()
	
	return 200
end)

function init_db()
	-- Initialize database
	env = assert (luasql.sqlite3())
	conn = assert (env:connect('db/openwrt.db'))

	conn:execute([[PRAGMA foreign_keys = ON]])

	conn:execute([[CREATE TABLE IF NOT EXISTS cards
	(
		"id" INTEGER UNIQUE NOT NULL PRIMARY KEY,
		"name" VARCHAR(32) NOT NULL
	)]])

	conn:execute([[CREATE TABLE IF NOT EXISTS inputs
	(
		"id" INTEGER UNIQUE NOT NULL PRIMARY KEY,
		"name" VARCHAR(32) NOT NULL,
		"type" VARCHAR(12) NOT NULL,
		"value" VARCHAR(255) NOT NULL,
		"card_id" INTEGER NOT NULL,
		FOREIGN KEY(card_id) REFERENCES cards(id)
	)]])

	-- assert (conn:execute('INSERT INTO cards VALUES (NULL, 'Demo 1')'))
	-- assert (conn:execute('INSERT INTO cards VALUES (NULL, 'Demo 2')'))
	conn:close()
	env:close()
end

local conf = {
	ip='0.0.0.0', 
	port=8080,
	ws_enable = true,
	max_age = {ico=5, css=60},
}
http_server.init(conf)

print ('http server listening on', conf.ip, conf.port)
for _, h in pairs (http_server.request_handlers) do
	print ('url:', h.pattern)
end

sched.go()
