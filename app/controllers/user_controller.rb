require 'responseMessage.rb'

class UserController < ApplicationController
    attr_accessor :user, :important_params
    def init_params()
      @important_params = ['userName', 'userEmail', 'userPassword']
    end


    def is_parameter_valid(param_name, param, regexp = nil)
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

    def fill_user
      item = {}
      item['userName'] = @user[:name]
      item['userId'] = @user[:id]
      item['avatar'] = @user[:avatar]
      item
    end

    def get_user_by_name()
        userName = params['userName']
        check_user_name = is_parameter_valid 'userName', userName, nil
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

        user = fill_user
        render :json => {'respMsg': 'Ok', 'user': user}
    end


    def get_user_by_id()
        id = params[:id]
        check_id = is_parameter_valid 'id', id, /^\d+$/
        if check_id != true
            return render :json => {:respMsg => check_id}, :status => 400
        end

        begin
            @user = User.find_by_id(id)
            if @user == nil
                responseMessage = ResponseMessage.new("No such user")
                return render :json => responseMessage, :status => 404
            end
        rescue
            responseMessage = ResponseMessage.new("Database error")
            return render :json => responseMessage, :status => 500
        end

        user = fill_user
        render :json => {'respMsg': 'Ok', 'user': user}
    end

    def create_user()
      init_params
      @important_params.each do |key|
        if key == "userEmail"
          check = is_parameter_valid key, params[key], /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
        else
          check = is_parameter_valid key, params[key]
        end
        if check != true
          return render :json => {:respMsg => check}, :status => 400
        end
      end

      @user = User.new(:name => params[:userName], :email => params[:userEmail],
         :password => params[:userPassword], :avatar => params[:userAvatar])
      if @user.valid?
          begin
            @user.save()
            responseMessage = ResponseMessage.new("Ok")
            return render :json => {:respMsg => "Ok"}, :status => 201
          rescue
              responseMessage = ResponseMessage.new("Database error")
              return render :json => responseMessage, :status => 500
          end
      else
        if @user.errors.messages[:name].size > 0
          return render :json => {:respMsg => "userName already occupied"}, status: 409
        else
          return render :json => {:respMsg => "userEmail already exist"}, status: 409
        end
      end
    end

    def status()
      render :json => {:respMsg => "alive"}, status: 200
    end

    def index()
        @user = User.new(:name=>'joe', :email=>'em', :password=>'p')
        render :json => @user
    end
end

# skip_before_filter :verify_authenticity_token, :only => :create
# protect_from_forgery with: :null_session
