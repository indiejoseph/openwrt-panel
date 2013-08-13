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
				assert(ws:send(tostring(out)..'\r\n'))
			end
			if prompt then
				assert(ws:send(prompt))
			end
		end
	end)
end)

--/api/cards GET
http_server.set_request_handler('GET', '/api/cards', function(method, path, http_params, http_header)
	local cards = {}
	local env = assert (luasql.sqlite3())
	local conn = assert (env:connect('db/openwrt.db'))

	local cur = assert(conn:execute('SELECT * FROM cards'))
	local row = cur:fetch({})

	while row do
		card = { ['id'] = row[1], ['name'] = row[2] }
		table.insert(cards, card)
		row = cur:fetch(row)
	end

	content = json.encode(cards)

	cur:close()
	conn:close()
	env:close()

	return 200, {['Content-Type']='application/json', ['Content-Length']=#content}, content
end)

--/api/cards POST
http_server.set_request_handler('POST', '/api/cards', function(method, path, http_params, http_header)

	local env = assert (luasql.sqlite3())
	local conn = assert (env:connect('db/openwrt.db'))
	
	if http_params['cards']~=nil then
		local cards=http_params['cards']
		for i,card in pairs(cards) do
			local name, inputs={}
			if card['name']~=nil then
				name=card['name']
				print(name)
			end
		end
	end
	
	conn:close()
	env:close()
	
	return 200
end)

--/api/cards PUT
http_server.set_request_handler('PUT', '/api/cards', function(method, path, http_params, http_header)

	local env = assert (luasql.sqlite3())
	local conn = assert (env:connect('db/openwrt.db'))

	conn:close()
	env:close()
	
	return 200
end)

--/api/cards DELETE
http_server.set_request_handler('DELETE', '/api/cards', function(method, path, http_params, http_header)

	local env = assert (luasql.sqlite3())
	local conn = assert (env:connect('db/openwrt.db'))

	conn:close()
	env:close()
	
	return 200
end)

-- Initialize database
env = assert (luasql.sqlite3())
conn = assert (env:connect('db/openwrt.db'))
assert(conn:execute('PRAGMA foreign_keys = ON'))
assert(conn:execute('CREATE TABLE IF NOT EXISTS cards( id INTEGER UNIQUE NOT NULL PRIMARY KEY, name VARCHAR(32) NOT NULL )'))
assert(conn:execute('CREATE TABLE IF NOT EXISTS inputs(	id INTEGER UNIQUE NOT NULL PRIMARY KEY,	name VARCHAR(32) NOT NULL, type VARCHAR(12) NOT NULL, value BLOB NOT NULL, card_id INTEGER NOT NULL, FOREIGN KEY(card_id) REFERENCES cards(id) )'))
-- assert(conn:execute('INSERT INTO cards VALUES (NULL, 'Demo 1')'))
-- assert(conn:execute('INSERT INTO cards VALUES (NULL, 'Demo 2')'))
conn:close()
env:close()

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
