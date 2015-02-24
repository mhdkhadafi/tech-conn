require 'linkedin'
require 'json'
require 'oauth2'

class ConnectionsController < ApplicationController
  respond_to :html
  API_KEY = '75gvg079vwjmq0'
  SECRET_KEY = '9gQSY7Csv6w9CoO2'

  REDIRECT_URI = 'https://tech-conn.herokuapp.com/linkedin/main/' 
  STATE = SecureRandom.hex(15)

  LINKEDIN_CONFIGURATION = {
    :site => 'https://api.linkedin.com',
    :authorize_path => '/uas/oauth/authenticate',
    :request_token_path => '/uas/oauth/requestToken?scope=r_basicprofile+r_fullprofile+r_emailaddress+r_network+r_contactinfo',
    :access_token_path => '/uas/oauth/accessToken'
    }
  def index
    #@connections = Connection.all
    c=Connection.select(:company, :plastname, :pfirstname).distinct
    @connections=c.group(:company).count(:plastname)
  end

  def detail
    @companies = params[:conn_ids]
    if (@companies.is_a?(String)) 
      @companies = [@companies]
    end
    facultyids = params[:at_ids]
    unless facultyids.nil?
      @faculties = AccessToken.find(facultyids)
    end

    if @companies.nil?
      @companies = ["-----------"]
    end

    all_ids = []

    @companies.each do |company|
      c = Connection.where(:company=>company).pluck(:id)
      all_ids = Connection.where("id in (?) OR id in (?)", c, all_ids).pluck(:id)
    end

    unless facultyids.nil?
      @faculties.each do |faculty|
        f = Connection.where(:pfirstname => faculty.firstname, :plastname => faculty.lastname).pluck(:id)
        all_ids = Connection.where("id in (?) OR id in (?)", f, all_ids).pluck(:id)
      end
    end

    @connections = Connection.find(all_ids)
    # render :plain => params[:submitted]
  end

  def display
    @connections=Connection.all
    respond_with(@connections)
  end

  def admin
    c=Connection.select(:company, :plastname, :pfirstname).distinct
    @connections=c.group(:company).count(:plastname)
    faculty = Connection.select(:plastname, :pfirstname).distinct.to_json
    @faculty_json = JSON.parse faculty
  end

  ##### My test codes (DAFI)
  def dafistests
  
    @timenow = ConnectionsHelper.get_whenever_time
    # a = AccessToken.select(:token)
    # @alltokens = a.to_json
    # @json_tokens = JSON.parse(@alltokens)

    # render :json => @alltokens
    @alltokens = ConnectionsHelper.get_connection_database

  end


  def init_client
    @linkedin_client = LinkedIn::Client.new(API_KEY, SECRET_KEY, LINKEDIN_CONFIGURATION)
  end

  def main
    code = params[:code] 
    state = params[:state]

    #Get token object, passing in the authorization code from the previous step 
    token = client.auth_code.get_token(code, :redirect_uri => REDIRECT_URI)
   
    access_token = OAuth2::AccessToken.new(client, token.token, { :mode => :header, :header_format => 'Bearer %s'})
 
    #Use the access token to make an authenticated API call
    connections = access_token.get('https://api.linkedin.com/v1/people/~/connections:(site_standard_profile_request,first-name,last-name,positions,id)?format=json') 
    connections_json = JSON.parse connections.body
    profile = access_token.get('https://api.linkedin.com/v1/people/~?format=json')
    profile_json = JSON.parse profile.body
    
# #     render :json => profile.last_name
#     @arrconn = []
    
    
    ffirstname = profile_json["firstName"]
    flastname = profile_json["lastName"]
    ftoken = token.token
    
    @faculty = { :ffirstname => ffirstname, :flastname => flastname, :ftoken => ftoken }
    
    #Store accesstoken into database
    atoken = AccessToken.find_or_initialize_by(:firstname => ffirstname, :lastname => flastname)
    atoken.update_attributes(:token=> ftoken)
 

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
        
    
#     render :plain => @faculty
  end

  def authentication
    if current_user.present?
      authorize
    else
      redirect_to '/admin'
    end
  end

  def client
    OAuth2::Client.new(
       API_KEY, 
       SECRET_KEY, 
       :authorize_url => "/uas/oauth2/authorization?response_type=code", #LinkedIn's authorization path
       :token_url => "/uas/oauth2/accessToken", #LinkedIn's access token path
       :site => "https://www.linkedin.com"
     )
  end
 
  def authorize
    #Redirect your user in order to authenticate
    redirect_to client.auth_code.authorize_url(:scope => 'r_fullprofile r_emailaddress r_network', 
                                               :state => STATE, 
                                               :redirect_uri => REDIRECT_URI)
  end

  def auth
    init_client
    request_token = @linkedin_client.request_token(:oauth_callback => "https://#{request.host_with_port}/linkedin/callback")
    session[:rtoken] = request_token.token
    session[:rsecret] = request_token.secret
    redirect_to @linkedin_client.request_token.authorize_url
  end

  def callback
    init_client
    if session[:atoken].nil?
      pin = params[:oauth_verifier]
      atoken, asecret = @linkedin_client.authorize_from_request(session[:rtoken], session[:rsecret], pin)
      session[:atoken]=atoken
      session[:asecret] = asecret
    else
      @linkedin_client.authorize_from_access(session[:atoken], session[:asecret])
    end

    c = @linkedin_client
    conns = c.connections(:fields => [ "api_standard_profile_request", "first-name", "last-name", "positions", "id" ])
    profile = c.profile
    
#     render :json => profile.last_name
    @arrconn = []
    
    conns.all.each do |conn|
      unless conn.id == 'private'
        if (defined?(conn.positions.all[0])).nil?
          hash = { :ffirstname => profile.first_name, :flastname => profile.last_name, :cfirstname => conn.first_name, :clastname => conn.last_name, :id => conn.id, :company => 'null', :title => 'null', :url => 'null' }
          @arrconn.push(hash)


        else
          conn.positions.all.each do |company|
            hash = { :ffirstname => profile.first_name, :flastname => profile.last_name, :cfirstname => conn.first_name, :clastname => conn.last_name, :id => conn.id, :company => company.company.name, :title => company.title, :url => conn.api_standard_profile_request.url }
            @arrconn.push(hash)

          end
        end
      end
    end


  end

#   def parse_json(connection_json)
#     connections_array = JSON.parse(connection_json)["all"]
#     connections_array
#   end

end
