require_relative 'actioncontroller.rb'
require_relative 'user.rb'
require 'byebug'

class UsersController < ControllerBase
  def index
    @users = User.all
    render :index
  end

  def new
    @user = User.new
    render :new
  end

  def create
    @user = User.new(username: params["user"]["username"], password: params["user"]["password"])
    if @user.save
    	redirect_to "/users/#{@user.id}" 
    else
    	redirect_to "/users/new"
    end
  end

  def show
  	@user = User.find(params["user_id"].to_i)
   	# @user = User.find(params["user_id"])
   	render :show
  end
end

router = Router.new
router.draw do
  get Regexp.new("^/users$"), UsersController, :index #cats_url
  get Regexp.new("^/users/new$"), UsersController, :new #new_cat_url
  post Regexp.new("^/users$"), UsersController, :create #cats_url
  get Regexp.new("^/users/(?<user_id>\\d+)$"), UsersController, :show
end



server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
