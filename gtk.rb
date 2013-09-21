require 'gtk3'
require './commands'
require './stack'

class RubyApp < Gtk::Window
	def initialize
		super
		
		set_title "Hello World!"
	
		signal_connect "destroy" do 
			Gtk.main_quit 
		end
	
		@mainStack = Gtk::TextView.new
		mainBuffer = @mainStack.buffer
		@commandStack = Gtk::TextView.new
		@variableTable = Gtk::TextView.new
		
		uiBox = Gtk::Box.new :vertical, 0
		@entry = Gtk::Entry.new
		@entry.signal_connect "activate" do |s,e|
			Commands::CB.parse(@entry.text)
			@entry.text = ""
			
			changeState
		end
		@errorstuff = Gtk::TextView.new
		uiBox.add @entry, :expand => false, :fill => false, :padding => 1
		uiBox.add @errorstuff, :expand => true, :fill => true, :padding => 1
		
		mainTable = Gtk::Table.new 4,3,true
		mainTable.set_row_spacings 1
		mainTable.set_column_spacings 1
		mainTable.attach(@mainStack, 0,1,0,3)
		mainTable.attach(@commandStack, 1,2,0,3)
		mainTable.attach(@variableTable, 2,3,0,3)
		mainTable.attach(uiBox,0,3,3,4)
		changeState	
		add mainTable

		show_all
	end
	def changeState
		#regen buffers and such
		mainBuffer = @mainStack.buffer
		mainBuffer.set_text ""
		textiter = mainBuffer.start_iter
		itter = Stack.S.itter
		
		while itter.done? == false
			mainBuffer.insert(textiter, itter.value.to_s + "\n")
			itter.next
		end
		commandBuffer = @commandStack.buffer
		commandBuffer.set_text ""
		textiter = commandBuffer.start_iter
		itter = Stack.U.itter
		
		while itter.done? == false
			commandBuffer.insert(textiter, itter.value.to_s + "\n")
			itter.next
		end
		
	end
end
Gtk.init
	window = RubyApp.new
Gtk.main
