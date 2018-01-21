require 'responseMessage.rb'
require 'bcrypt'
class UserController < ApplicationController
    attr_accessor :user, :important_params
    @@sault = "fucking_sault"
    @@important_params = ['userName', 'userEmail', 'userPassword']
    @@all_params = ['userName', 'userEmail', 'userPassword', 'userAvatar']
    @@hash_local_and_global = {'userId' => 'id', 'userName'=>'name', 'userEmail'=>'email',
      'userPassword'=>'password', 'userAvatar'=>'avatar'}
    @@int_regexp = /^\d+$/
    @@email_regexp = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i



    def check_token_valid(token)
      # p token
      if AccessApplication.exists?(:appSecret => token)
        # p 'here'
        data = AccessApplication.where(:appSecret => token).first
        now = Time.now.to_i
        # p now
        created = data['created'].to_i
        # p created
        if now - created > data['life']
          return false
        end
        return true

      else
        return false
      end
    end

    def get_new_token()
      appName = params['appId']
      if appRec = AccessApplication.where(:appName => appName).first
        token = SecureRandom.hex#SecureRandom.base64 #=> "6BbW0pxO0YENxn38HMUbcQ=="
        created = Time.now
        life = 60
        appRec.update(:appSecret => token, :created => created, :life => life)
        render :json => {:token => token}, status: 200
      else
        render :json => {:respMsg => "Cant uderstand service"}, :status => 401
      end
    end

    def login_get
      if !check_token_valid params[:appSecret]
        return render :json => {:respMsg => "Not authoeized"}, status: 401
      end
      @user = User.new
      @err = Array.new()
      @redirect = params[:redirect_url]
      p @redirect
      render "user/login", :status => 200
    end

    def login_post
      # if !check_token_valid params[:appSecret]
      #   return render :json => {:respMsg => "Not authoeized"}, status: 401
      # end

      redirect_to params[:redirect_url]
      # render :json => {:msg => "Ok"}, status: 200
    end

    def add_password_sault(password)
      return "#{@@sault}#{password}#{@@sault}"
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

    def get_request_user()
      user = {}
      temp = @user.slice(:id, :name, :password, :avatar)
      temp.each do |key, value|
        user[@@hash_local_and_global.key(key)] = value
      end
      user
    end

    def params_to_db_params(params)
      db_params = {}
      @@all_params.each do |key|
        db_params[@@hash_local_and_global[key]] = params[key]
      end
      db_params
    end

    def get_user_by_name()
        if !check_token_valid params[:appSecret]
          return render :json => {:respMsg => "Not authoeized"}, status: 401
        end
        logger.debug "get_user_by_name #{params}"

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
        user = get_request_user
        render :json => {'respMsg': 'Ok', 'user': user}
    end

    def get_user_by_id()
        if !check_token_valid params[:appSecret]
          return render :json => {:respMsg => "Not authoeized"}, status: 401
        end

        logger.debug "get_user_by_id #{params}"
        id = params[:id]
        check_id = is_parameter_valid 'id', id, @@int_regexp
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
        user = get_request_user
        render :json => {'respMsg': 'Ok', 'user': user}
    end


    def create_user()
      if !check_token_valid params[:appSecret]
        return render :json => {:respMsg => "Not authoeized"}, status: 401
      end
      
      logger.debug "create_user #{params}"
      @@important_params.each do |key|
        if key == "userEmail"
          check = is_parameter_valid key, params[key], @@email_regexp
        else
          check = is_parameter_valid key, params[key]
        end
        if check != true
          return render :json => {:respMsg => check}, :status => 400
        end
      end

      db_params = params_to_db_params(params)
      db_params['password'] = BCrypt::Password.create(add_password_sault(db_params['password']))

      @user = User.new db_params
      if @user.valid?
      begin
        @user.save()
        return render :json => {:respMsg => "Ok", :data => @user.id}, :status => 201
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

    #
    # def create_user()
    #   logger.debug "create_user #{params}"
    #   @@important_params.each do |key|
    #     if key == "userEmail"
    #       check = is_parameter_valid key, params[key], @@email_regexp
    #     else
    #       check = is_parameter_valid key, params[key]
    #     end
    #     if check != true
    #       # logger.debug(key + "is invalid")
    #       return render :json => {:respMsg => check}, :status => 400
    #     end
    #   end


    #
    #   @user = User.new(params_to_db_params(params))
    #   if @user.valid?
    #   begin
    #     @user.save()
    #     return render :json => {:respMsg => "Ok", :data => @user.id}, :status => 201
    #   rescue
    #       responseMessage = ResponseMessage.new("Database error")
    #       return render :json => responseMessage, :status => 500
    #   end
    #   else
    #     if @user.errors.messages[:name].size > 0
    #       return render :json => {:respMsg => "userName already occupied"}, status: 409
    #     else
    #       return render :json => {:respMsg => "userEmail already exist"}, status: 409
    #     end
    #   end
    # end

    def status()
      render :json => {:respMsg => "alive"}, status: 200
    end

    def index()
        @user = User.new(:name=>'joe', :email=>'em', :password=>'p')
        render :json => @user
    end
end
