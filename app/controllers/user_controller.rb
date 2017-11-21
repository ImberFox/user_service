require 'responseMessage.rb'

class UserController < ApplicationController
    attr_accessor :user
    # skip_before_filter :verify_authenticity_token, :only => :create
    # protect_from_forgery with: :null_session

    def get_user()
        userName = params['userName']
        check_user_name = is_parameter_valid params, 'userName', nil
        if check_user_name != true
            return render :json => {:respMsg => check_user_name}, :status => 400
        end

        begin
            @user = User.find_by_name(params[:userName])
            if @user == nil
                responseMessage = ResponseMessage.new("No such user")
                return render :json => responseMessage, :status => 404
            end
        rescue
            responseMessage = ResponseMessage.new("Database error")
            return render :json => responseMessage, :status => 500
        end
        render :json => @user, :only => ['id', "avatar"]
    end

    def is_parameter_valid(params, param_name, regexp)
        param = params[param_name]
        if param == nil || param == ""
            return param_name + " is Empty"
        end
        if regexp
            if !regexp.match? param
                return param_name + " is invalid"
            end
        end
        true
    end

    def create_user()
        check_user_name = is_parameter_valid params, 'userName', nil
        if check_user_name != true
            return render :json => {:respMsg => check_user_name}, :status => 400
        end

        check_user_email = is_parameter_valid params, 'userEmail', /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
        if check_user_email != true
            return render :json => {:respMsg => check_user_email}, :status => 400
        end

        check_user_password = is_parameter_valid params, 'userPassword', nil
        if check_user_password != true
            return render :json => {:respMsg => check_user_password}, :status => 400
        end

        @user = User.new(:name => params[:userName], :email => params[:userEmail],
           :password => params[:userPassword], :avatar => params[:userAvatar])
        if @user.valid?
            begin
                @user.save()
                responseMessage = ResponseMessage.new("Ok")
                return render :json => {:respMsg => "Ok"}, :status => 200
            rescue
                responseMessage = ResponseMessage.new("Database error")
                return render :json => responseMessage, :status => 500
            end
        else
            message = String.new
            @user.errors.each do |attr, error|
                message += "user".capitalize + " " + attr.to_s + " " + error.to_s + " "
            end
            return render :json => {:respMsg => message}, status: 409
        end
    end

    def index()
        @user = User.new(:name=>'joe', :email=>'em', :password=>'p')
        p user
        render :json => @user
    end
end
