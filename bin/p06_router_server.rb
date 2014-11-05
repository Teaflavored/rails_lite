require 'webrick'
require_relative '../lib/phase6/controller_base'
require_relative '../lib/phase6/router'


# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPRequest.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPResponse.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/Cookie.html

$cats = [
  { id: 1, name: "Curie" },
  { id: 2, name: "Markov" }
]

$statuses = [
  { id: 1, cat_id: 1, text: "Curie loves string!" },
  { id: 2, cat_id: 2, text: "Markov is mighty!" },
  { id: 3, cat_id: 1, text: "Curie is cool!" }
]

class StatusesController < Phase6::ControllerBase
  def index
    statuses = $statuses.select do |s|
      s[:cat_id] == Integer(params[:cat_id])
    end


    render_content(statuses.to_s, "text/text")
  end
end

Cat = Struct.new(:name, :id, :owner)

class CatsController < Phase6::ControllerBase
  def index
    render :index
  end

  def new
    flash[:errors] = "hihi"
    @cat = Cat.new("gizmo1", 1, "ned")
    redirect_to("/cats")
  end

  def create
    flash[:errors] = "success"
    redirect_to :index
  end

end

#every request is a new instance of the catscontroller
# in index we first call flash, which will initialize a new flash object, give it some kind of key-val pair to store
# we need to carry this over to the next request, so we store it in the cookie
# when it initializes it should be initialized with life of 1
# after the second request, we need to grab the life from the cookie when initializing, if there is a life in there,
# we need to clear the flash and update the cookie to reflect that
# when the content is to be rendered, flash will be called and the value will be taken from the already built flash
# only on the next request does it grab it from the cookie
# def render_content(content, type)
#   session.store_session(@res)
#   flash.store_flash(@res)

#   super
# end

router = Phase6::Router.new
router.draw do
  get Regexp.new("^/cats$"), CatsController, :index #cats_url
  get Regexp.new("^/cats/new$"), CatsController, :new #new_cat_url
  post Regexp.new("^/cats$"), CatsController, :create #cats_url
  get Regexp.new("^/cats/(?<cat_id>\\d+)/statuses$"), StatusesController, :index
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
