---
-- A test program for the http server.

--look for packages one folder up.
package.path = package.path .. ";Lumen/?.lua"

require "log".setlevel('ALL', 'HTTP')
--require "log".setlevel('ALL')

--require "strict"

local sched = require "sched"
local img_path, script_path, style_path = 'dist/images', 'dist/scripts', 'dist/styles'

require "tasks/selector".init({service='luasocket'})

local http_server = require "tasks/http-server"

http_server.serve_static_content_from_ram('/', 'app')
if service=='nixio' then
	http_server.serve_static_content_from_stream('/images/', img_path)
	http_server.serve_static_content_from_stream('/scripts/', script_path)
	http_server.serve_static_content_from_stream('/styles/', style_path)
else
	http_server.serve_static_content_from_ram('/images/', img_path)
	http_server.serve_static_content_from_ram('/scripts/', script_path)
	http_server.serve_static_content_from_ram('/styles/', style_path)
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
