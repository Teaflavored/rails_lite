require_relative 'controller_base.rb'
require_relative '../Model/user.rb'
require 'webrick'
require 'byebug'

class SessionsController < ControllerBase
	def new
		render :new
	end

	def create
		@user = User.find_by_credentials(params["user"]["username"], params["user"]["password"])
		if @user.nil?
			redirect_to "/session/new"
		else
			@user.reset_session_token
			session["session_token"] = @user.session_token
			redirect_to "/users/#{@user.id}"
		end
	end

	def logout
		current_user.reset_session_token
		session["session_token"] = nil
		redirect_to "/session/new"
	end
end

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
    	@user.reset_session_token
			session["session_token"] = @user.session_token
    	redirect_to user_url(@user)
    else
    	redirect_to "/users/new"
    end
  end

  def show
  	@user = User.find_by(id: params["user_id"].to_i)
  	if !current_user.nil? && @user.id == current_user.id
   	# @user = User.find(params["user_id"])
   		render :show
   	else
   		redirect_to users_url 
   	end
  end
end

router = Router.new
router.draw do
  get Regexp.new("^/users$"), UsersController, :index #users_url
  get Regexp.new("^/users/new$"), UsersController, :new 
  get Regexp.new("^/session/new$"), SessionsController, :new 
  post Regexp.new("^/session$"), SessionsController, :create
  post Regexp.new("^/users$"), UsersController, :create 
  get Regexp.new("^/users/(?<user_id>\\d+)$"), UsersController, :show
  get Regexp.new("^/sessionlogout$"), SessionsController, :logout
end



server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
