# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'b82e2c5c2c0db4469ef45a24ed35131a'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  def authorized
	  admin?
  end
  def login_required
	  authenticate
  end
  def admin?
  	if current_user.nil?
  		false
  	else
  		%(acoldham).include? current_user
  	end
  end

  def current_user
    unless session[:user_id].nil?
      session[:user] ||= User.find session[:user_id]
    else
      nil
    end
  end

  private
	  USER_NAME = 'sandy'
	  PASSWORD = 'mttpower'
	def authenticate
		session[:attempted_auth] = false
		if current_user.nil? and session[:attempted_auth] == false
			session[:attempted_auth] = true
			redirect_to login_path
		else
			#authenticate_or_request_with_http_basic do |user_name, password|
			#  session[:admin] = user_name == USER_NAME && password == PASSWORD
			#  username == USER_NAME && password == PASSWORD
			#end
		end
	end

end
