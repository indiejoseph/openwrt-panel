#!/usr/bin/env lua

if type(cgilua) == "table" then
	cgilua.htmlheader()
else
	print "Content-Type: text/html"
end

print [[
<html>
<head>
  <title>Hello World</title>
</head>
<body>
  <strong>Hello World!</strong>
</body>
</html>]]