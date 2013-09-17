class StringParse
	@@r = 6
	@@s = nil
	@@u = nil
	@@o = nil
	def self.setS(s)
		@@s = s
	end
	def self.setU(u)
		@@u = u
	end
	def self.setO(o)
		@@o = o
	end
	def self.is_a_number?(s)
		s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
	end

	def self.rule(&block)
	#this function is designed to simplify doing any math operation
	#by getting the needed number of things off of the stack and 
	#pushing the result back on the stack
	#ex rule {|a,b| b + a }
	#would result in two numbers being popped off of the stack and passed
	#into the block. The result of the block is returned, captured and
	# pushed onto the stack
		stuff = []
		for x in 0..(block.arity-1)
			new = @@s.pop
			if(new.nil?)
				#if we run out of stuff on the stack to pop off
				#and the rule still needs more, we should push
				#everything back on the stack and bail out
				stuff.each do |a|
					@@s.push(a)
				end
				raise "Stack Empty"
			end
			stuff.push(new)
		end
		#I'm not entirely sure as to why this works the way it does,
		#but apparently if you pass an array to a yield, it passes
		#each element individually? I guess? However if you pass
		#an array with only one element it passes an array? IDK
		if(stuff.length == 1)
			ret = yield(stuff[0])
		else
			ret = yield(stuff)
		end
		p ret
		if !(ret.nil?)
			@@s.push(ret.round(@@r))
		end
	end


	def self.parse(string)
		sections = string.split(" ")
		i = 0
		nopush = false
		begin
		for part in sections
			i += 1
			case part
			when "+"#Add two things
				rule {|a,b| b + a}
			when "-"#Subtract two things
				rule {|a,b| b - a}
			when "*"#multiply two things
				rule {|a,b| b * a}
			when "/"#divide two things
				rule {|a,b| b / a}
			when "q"#quit the program
				exit
			when "^"#exponentiate (raise b to the a power)
				rule {|a,b| b ** a}
			when "s"#swap the two top elements on the stack
				a = @@s.pop
				if a.nil?
					raise "Stack Empty"
				end
                                b = @@s.pop
				if b.nil?
					@@s.push(a)
					raise "Stack Empty"
				end
				@@s.push(a)
				@@s.push(b)	
			when "d"#duplicate the top element
				a = @@s.pop
				if a.nil?
					raise "Stack Empty"
				end
				2.times do  @@s.push(a) end
			when "c"#delete the top element
				@@s.pop
			when "cc"#clear the stack
				@@s.clear
			when "sqrt"#take the square root of the top element
				rule {|a| Math.sqrt(a) }
			when "sin"#take the sine of the top element(assuming radians)
				rule {|a| Math.sin(a) }
			when "sind"#sin in degrees
				rule {|a| Math.sin((a/180)*Math::PI) }
			when "cos"#cos in radians
				rule {|a| Math.cos(a) }
			when "cosd"#cos in degrees
				rule {|a| Math.cos((a/180)*Math::PI) }
			when "tan"#tan in radians
				rule {|a| Math.tan(a) }
			when "tand"#tan in degrees
				rule {|a| Math.tan((a/180)*Math::PI) }
			when "atan"#the arctangent in radians
				rule {|a| Math.atan(a) }
			when "atand"#the arctangent in degrees
				rule {|a| (Math.atan(a) * 180) / Math::PI }
			when "asin"#arcsine in radians
				rule {|a| Math.asin(a) }
			when "asind"#arcsine in degrees
				rule {|a| (Math.asin(a) * 180) / Math::PI }
			when "acos"#arccosine in radians
				rule {|a| Math.acos(a) }
			when "r"#set precision
				@@r = @@s.pop
			when "ckck"#clear everything, including undo stack
				nopush = true
				@@s.clear
				@@u.clear
			when "u"#undo last operation
				nopush = true
				@@u.queuepop
				@@s.clear
				itter = @@u.itter
				@@u.clear
				while !(itter.done?)
					parse(itter.value)
					itter.next
				end
			else#push something onto the stack
				if is_a_number?(part)
					@@s.push(part.to_f.round(@@r))
				else
					raise "Not a number~"
				end
			end
			if(nopush)#some operations shouldn't push to the undo
				#stack, this flag prevents them from being pushed
				nopush = false	
			else
				@@u.queuepush(part)
			end
		end
		rescue RuntimeError => e#this bit handles an exceptions that parse
		#raised and points an arrow at the term in the given string that
		#caused the issue
			@@u.pop
			x = 0
			for y in 0...i
				x += sections[y].length + 1
			end
			message =  string + "\n"
			(x - 2).times { message += " " } 
			message +=  "^" + "\n" + e.message 
			raise message
		end
	end
end
