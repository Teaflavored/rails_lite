require_relative "../activerecord/SQLObject"
class User < SQLObject
	def initialize(params = {} )
		super(params)
		self.session_token ||= SecureRandom.urlsafe_base64
	end

	def self.find_by_credentials(username, password)
		user = User.find_by(username: username)
		return nil unless user.password == password
		return user
	end

	def reset_session_token
		self.session_token = SecureRandom.urlsafe_base64
		self.update

		self.session_token
	end
	finalize!
end