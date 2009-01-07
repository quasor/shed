class LoginController < ApplicationController
# GET /login?username=
# http://ham64:8080/?rurl=http://localhost:3000/login?u=
	def login
	  if !params[:lkey].blank?
	    @user = User.find(:first, :conditions => {:loginkey => params[:lkey]})
	    username = @user.name unless @user.nil?
			session[:user] = nil
			session[:username] = username
			session[:user_id] = @user.id
  		redirect_to "/"
	  elsif params[:u].blank? || params[:challenge] != "mttpowerful"
			redirect_to "http://ham64:8080/?rurl=http://#{request.env['HTTP_HOST']}/login?u="
		else
		  username = /[a-z,\\\-\_,0-9]+/.match(params[:u].gsub("SEA\\",""))
			unless username.blank?
				logger.info username[0]
				session[:user] = nil
				session[:username] = username[0] 
				session[:user_id] = User.find_or_create_by_login(username[0]).id
			else
				logger.warn 'unable to get username'
			end
  		redirect_to "/"
		end
	end

	def logout
		session.delete
		redirect_to "/"
	end
end
