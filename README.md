#Rails Lite combined with ActiveRecord

Features meta programming to create a stripped down version of active record and rails router/controller.
Stripped down version of rails/activerecord actually can create/view users from database

##To Run

* Clone this repo, navigate to rails_lite folder
* Run `ruby controller_base/users_controller.rb` and navigate to localhost:3000/users in your browser


##Features

* extensive meta programming in activerecord to persist and retrieve things from database
* use of webrick server and regex to monitor route changes and fire appropriate controller action
* controller grabs data from database
* HTML is displayed by controller
