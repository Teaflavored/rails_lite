require_relative 'actioncontroller.rb'

class Cat
  attr_accessor :name

  def self.all
    ObjectSpace.each_object(self).to_a
  end

  def initialize(name = nil)
    @name = name
  end

  def self.find_by(name)
    self.all.each do |cat|
      return cat if cat.name == "Auster"
    end
  end
end

cat = Cat.new("Auster")
cat2 = Cat.new("hi")

class CatsController < ControllerBase
  def index
    @cats = Cat.all
    render :index
  end

  def new
    @cat = Cat.new
    render :new
  end

  def create
    @cat = Cat.new(params["cat"]["name"])
    flash[:success] = "Successful create"
    redirect_to("/cats/#{@cat.name}")
  end

  def show
    @cat = Cat.find_by(params[:name])
    flash[:success2] = "omg it works here too"
    render :show
  end
end


router = Router.new
router.draw do
  get Regexp.new("^/cats$"), CatsController, :index #cats_url
  get Regexp.new("^/cats/new$"), CatsController, :new
  post Regexp.new("^/cats$"), CatsController, :create
  get Regexp.new("^/cats/(?<name>\\w+)$"), CatsController, :show #cats_url
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
