require 'webrick'
require 'byebug'
require 'URI'

# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPRequest.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPResponse.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/Cookie.html


server = WEBrick::HTTPServer.new(Port: 3000)
trap("INT") { server.shutdown }


#server logic
server.mount_proc("/") do |request, response|
	response.content_type = "text/text"
	response.body = "request path: #{request.path}\nrequest query_string: #{request.query_string}, #{response.header["location"]}"

end

server.start