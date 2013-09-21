require 'gtk3'

class RubyApp < Gtk::Window
	def initialize
		super
		
		set_title "Hello World!"
	
		signal_connect "destroy" do 
			Gtk.main_quit 
		end
	
		mainStack = Gtk::TextView.new
		commandStack = Gtk::TextView.new
		variableTable = Gtk::TextView.new
		
		uiBox = Gtk::Box.new :vertical, 0
		entry = Gtk::Entry.new
		errorstuff = Gtk::TextView.new
		uiBox.add entry, :expand => false, :fill => false, :padding => 1
		uiBox.add errorstuff, :expand => true, :fill => true, :padding => 1
		
		mainTable = Gtk::Table.new 4,3,true
		mainTable.set_row_spacings 1
		mainTable.set_column_spacings 1
		mainTable.attach(mainStack, 0,1,0,3)
		mainTable.attach(commandStack, 1,2,0,3)
		mainTable.attach(variableTable, 2,3,0,3)
		mainTable.attach(uiBox,0,3,3,4)
		
		add mainTable

		show_all
	end
end
Gtk.init
	window = RubyApp.new
Gtk.main
