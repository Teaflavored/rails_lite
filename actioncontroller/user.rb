require_relative "../activerecord/SQLObject"
DBConnection.reset
class User < SQLObject

	finalize!
end