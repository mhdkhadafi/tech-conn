namespace :scheduler do
	
  require './app/helpers/connections_helper.rb'
  
#   include 'Connection'
  
  task timeupdate: :environment do
#     puts "" + "Updated time is: " + Time.now.inspect
    ConnectionsHelper.set_whenever_time
  end

  task databaseupdate: :environment do
  	ConnectionsHelper.set_connection_database
  end

  task databaseremove: :environment do
  	ConnectionsHelper.remove_connection_database
  end

end
