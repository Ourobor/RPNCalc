module Infix

class RailYard
	def initialize
		@OQ = Array.new
		@OS = Array.new
		@rules = Hash.new
	end
	def addRule(name, prec, leftassoc)
		if leftassoc
			@rules[name] = {:prec => prec, :assoc => :left}	
		else
			@rules[name] = {:prec => prec, :assoc => :right}	
		end
	end
	def parse(string)
		parts = string.split(" ")
		parts.each do |symbol|
			if !(@rules.has_key?(symbol))
				#symbol is a number
				@OQ.push(symbol)	
			else
				#symbol is an operator
				while !(@OS.empty?) && ((@rules[@OS.first][:prec] == @rules[symbol][:prec]) && (@rules[symbol][:assoc] == :left) || @rules[@OS.first][:prec] > @rules[symbol][:prec])
					@OQ.push(@OS.pop)
				end
				@OS.push(symbol)
			end
		end
		@OS.reverse_each do |symbol|
			@OQ.push(symbol)
		end
	end
	def print
		p @OQ
	end
	def empty!
		@OS = Array.new
		@OQ = Array.new
	end
end
STATION = RailYard.new
end
