class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

   def after_sign_in_path_for(resource)
  	 	if current_user.username == "Admin"
  	 		return '/admin'
  	 	else
  	 		return '/linkedin/authentication'
  	 	end
   end

  before_action :configure_permitted_parameters, if: :devise_controller?
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
  end

 #  API_KEY = '75gvg079vwjmq0' #Your app's API key
 #  API_SECRET = '9gQSY7Csv6w9CoO2' #Your app's API secret
 #  REDIRECT_URI = '<a class="linkclass" href="https://tech-conn.herokuapp.com/">https://tech-conn.herokuapp.com/</a>' #Redirect users after authentication to this path, ensure that you have set up your routes to handle the callbacks
 #  STATE = SecureRandom.hex(15) #A unique long string that is not easy to guess
   
 #  #Instantiate your OAuth2 client object
 #  def client
 #    OAuth2::Client.new(
 #       API_KEY, 
 #       API_SECRET, 
 #       :authorize_url => "/uas/oauth2/authorization?response_type=code", #LinkedIn's authorization path
 #       :token_url => "/uas/oauth2/accessToken", #LinkedIn's access token path
 #       :site => "<a class="linkclass" href="https://www.linkedin.com">https://www.linkedin.com</a>"
 #     )
 #  end
   
 #  def index
 #    authorize
 #  end
 
 #  def authorize
 #    #Redirect your user in order to authenticate
 #    redirect_to client.auth_code.authorize_url(:scope => 'r_fullprofile r_emailaddress r_network', 
 #                                               :state => STATE, 
 #                                               :redirect_uri => REDIRECT_URI)
 #  end
 
 #  # This method will handle the callback once the user authorizes your application
 #  def accept
 #      #Fetch the 'code' query parameter from the callback
 #          code = params[:code] 
 #          state = params[:state]
           
 #          if !state.eql?(STATE)
 #             #Reject the request as it may be a result of CSRF
 #          else          
 #            #Get token object, passing in the authorization code from the previous step 
 #            token = client.auth_code.get_token(code, :redirect_uri => REDIRECT_URI)
           
 #            #Use token object to create access token for user 
 #            #Note how we're specifying that the access token be passed in the header of the request
 #            access_token = OAuth2::AccessToken.new(client, token.token, {
 #              :mode => :header,
 #              :header_format => 'Bearer %s'
 #              })
 
 #            #Use the access token to make an authenticated API call
 #            response = access_token.get('<a class="linkclass" href="https://api.linkedin.com/v1/people/~">https://api.linkedin.com/v1/people/~</a>')
 
 #            #Print body of response to command line window
 #            puts response.body
 
 #            # Handle HTTP responses
 #            case response
 #              when Net::HTTPUnauthorized
 #                # Handle 401 Unauthorized response
 #              when Net::HTTPForbidden
 #                # Handle 403 Forbidden response
 #            end
 #        end
 #    end
 # end
end
