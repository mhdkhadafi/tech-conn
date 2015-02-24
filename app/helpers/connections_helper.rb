require 'oauth2'
require 'json'

module ConnectionsHelper

	API_KEY = '75gvg079vwjmq0'
  	SECRET_KEY = '9gQSY7Csv6w9CoO2'

	def self.set_whenever_time
  		@whenevertime = "Updated time is: " + Time.now.inspect
#     puts "Updated time is: " + Time.now.inspect
  	end
  
  	def self.get_whenever_time
    	@whenevertime
  	end

  	def self.get_connection_database
  		if (@tokens.nil? or @tokens == ["bla", "bla"])
  			@tokens = ["bla", "bla"]
  		else
  			@tokens
  		end
  		
  	end

  	def self.remove_connection_database
  		Connection.delete_all
  	end

  	# def client
   #  	OAuth2::Client.new(
   #     		API_KEY, 
   #     		SECRET_KEY, 
   #     		:authorize_url => "/uas/oauth2/authorization?response_type=code", #LinkedIn's authorization path
   #     		:token_url => "/uas/oauth2/accessToken", #LinkedIn's access token path
   #     		:site => "https://www.linkedin.com"
   #   		)
  	# end

  	def self.set_connection_database

  		Connection.delete_all

  		a = AccessToken.select(:token)
  		@tokens = JSON.parse(a.to_json)

  		client = OAuth2::Client.new(
       		API_KEY, 
       		SECRET_KEY, 
       		:authorize_url => "/uas/oauth2/authorization?response_type=code", #LinkedIn's authorization path
       		:token_url => "/uas/oauth2/accessToken", #LinkedIn's access token path
       		:site => "https://www.linkedin.com"
     		)

  		@tokens.each do |token|
  			access_token = OAuth2::AccessToken.new(client, token["token"], { :mode => :header, :header_format => 'Bearer %s'})
 
		    #Use the access token to make an authenticated API call
		    connections = access_token.get('https://api.linkedin.com/v1/people/~/connections:(site_standard_profile_request,first-name,last-name,positions,id)?format=json') 
		    connections_json = JSON.parse connections.body
		    profile = access_token.get('https://api.linkedin.com/v1/people/~?format=json')
		    profile_json = JSON.parse profile.body
		    
		    
		    ffirstname = profile_json["firstName"]
		    flastname = profile_json["lastName"]
		    ftoken = token["token"]
		    
		    @faculty = { :ffirstname => ffirstname, :flastname => flastname, :ftoken => ftoken }
		
		    @arrconn = []
		    connections_json["values"].each do |conn|
		      unless conn["id"] == 'private'
            if conn["positions"]["values"].nil?
              # hash = { :cfirstname => conn["firstName"], :clastname => conn["lastName"], :id => conn["id"], :company => 'No current company', :title => 'No current positions', :url => conn["siteStandardProfileRequest"]["url"] }
              # @arrconn.push(hash)
              next
            end
            conn["positions"]["values"].each do |company|
              if company["company"]["name"].nil?
                next
              end

              hash = { :cfirstname => conn["firstName"], :clastname => conn["lastName"], :id => conn["id"], :company => company["company"]["name"], :title => company["title"], :url => conn["siteStandardProfileRequest"]["url"] }
              @arrconn.push(hash)

              #Insert connection to the database
              r = Connection.find_or_initialize_by(:pfirstname => ffirstname, :plastname => flastname, :cfirstname => conn["firstName"], :clastname => conn["lastName"], :company => company["company"]["name"], :position => company["title"])
              r.update_attributes(:lurl => conn["siteStandardProfileRequest"]["url"])

            end
          end
		    end
  		end
  		
  	end
  	
end
