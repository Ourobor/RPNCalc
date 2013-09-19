require 'green_shoes'
Shoes.app do
	stack height: 1.0 do
		flow do
			stack height: 0.8 do
				para "hello"
			end 
		end
		stack do
			@line = edit_line
		end
	end
end

