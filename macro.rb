class MacroCommand
	def initialize

	end
	def do

	end
	def undo

	end
end
class Macro
	def initialize
		
	end

end
class MacroDB
	def initialize(database)
		@database = database
		@mainStack = Stack.new
		@commandStack = Stack.new
		@objtable = Hash.new
	end
	def round(num)
		return @database.round(num)
	end
	def setRound(num)
		return @database.setRound(num)
	end
	def getMain
		return @mainStack
	end
	def getRealMain
		return @database.getMain
	end
	def getCommand
		return @commandStack
	end
	def getRealCommand
		return @database.getCommand
	end
	def emptyObjtable

	end
	def isVariable(name)

	end
	def setVariable(name, value)

	end
	def getVariable(name)

	end
	def objtable
		
	end
end
class Alias

end
