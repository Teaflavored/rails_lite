require_relative "../activerecord/SQLObject"
class User < SQLObject
	def self.find_by_credentials(username, password)
		user = User.find_by
	end
	finalize!
end