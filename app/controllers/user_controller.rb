require 'responseMessage.rb'
require 'bcrypt'
require 'securerandom'

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
      if token == nil
        return false
      end
      data = token.split(' ')

      appSecret = data[1]
      p data
      if rec = AccessApplication.where(:token => appSecret).first#:appName => appId, :appSecret => appSecret).first
        p rec
        now = Time.now.to_i
        created = rec['created'].to_i
        if now - created > rec['life']
          return false
        end
        return true
      else
        return 'uncknown'
      end
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

    def params_to_db_params(params)
      db_params = {}
      @@all_params.each do |key|
        db_params[@@hash_local_and_global[key]] = params[key]
      end
      db_params
    end


    def get_request_user()
      user = {}
      temp = @user.slice(:id, :name, :password, :avatar)
      temp.each do |key, value|
        user[@@hash_local_and_global.key(key)] = value
      end
      user
    end

    def update_oauth_token()

    end

    def get_oauth_code()

    end

    def check_oauth_token()
      if token == nil
        return false
      end
    end

################################################
############ controllers
#############################################

  def get_oauth_tokens()
    code = params['code']
    if code == nil
      return render :json => {:respMsg => "Invalid code"}, :status => 401
    end

    if rec = User.where(:code => code).first
      acc_token = SecureRandom.hex
      ref_token = SecureRandom.hex

      rec.update(:accessToken => acc_token, :refreshToken => ref_token)
      return render :json => {:tokens => {:access_token => acc_token,
                                          :refresh_token => ref_token}},
                                          :status => 200
    end
    render :json => {:respMsg => "Invalid code"}, :status => 401
  end

  def get_new_token()
    token = request.headers['Authorization']
    p token
    data = token.split(' ')
    data = data[1].split(':')

    appId = data[0]
    appSecret = data[1]
    p appSecret

    if appRec = AccessApplication.where(:appName => appId, :appSecret => appSecret)
      token = SecureRandom.hex#SecureRandom.base64 #=> "6BbW0pxO0YENxn38HMUbcQ=="
      created = Time.now
      life = 60
      appRec.update(:token => token, :created => created, :life => life)
      render :json => {:token => token}, :status => 200
    else
      render :json => {:respMsg => "Uncknown service"}, :status => 401
    end
  end

  def login_get
    @user = User.new
    @err = Array.new()
    @redirect = params[:redirect_url]
    @client_id = params[:client_id]
    @client_secret = params[:client_secret]
    @response_type = params[:response_type]
    # TODO check app foe
    app = params[:client_id]
    if rec = AccessApplication.where(:appName => @client_id, :appSecret => @client_secret).first
      p rec
      p @redirect
      return render "user/login", :status => 200
    end
    render :json => {:respMsg => "Uncknown app"}, :status => 401
  end

  def login_post
    @user = User.new
    @err = Array.new()
    @redirect = params[:redirect_url]
    @client_id = params[:client_id]
    @client_secret = params[:client_secret]
    @response_type = params[:response_type]

    if rec = AccessApplication.where(:appName => @client_id, :appSecret => @client_secret).first == nil
      return render :json => {:respMsg => "Uncknown app"}, :status => 401
    end

    if rec = User.where(:name => params[:user][:name]).first
      if BCrypt::Password.new(rec['password']) != add_password_sault(params[:user][:password])
        @err.push('incorrect password')
      end
    else
      @err.push('incorrect login')
    end


    if @err.count != 0
      return render "user/login"
    end

    code = SecureRandom.hex
    rec.update(:code => code)
    redirect_url = @redirect + "?code=#{code}"
    redirect_to redirect_url
  end

  def get_user_by_name()
    if (data = check_token_valid(request.headers['Authorization'])) == false
      return render :json => {:respMsg => "Not authorized"}, status: 401
    else
      if data == 'uncknown'
        return render :json => {:respMsg => "Uncknown server"}, :status => 401
      end
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
    if (data = check_token_valid(request.headers['Authorization'])) == false
      return render :json => {:respMsg => "Not authorized"}, status: 401
    else
      if data == 'uncknown'
        return render :json => {:respMsg => "Uncknown server"}, :status => 401
      end
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
    if (data = check_token_valid(request.headers['Authorization'])) == false
      return render :json => {:respMsg => "Not authorized"}, status: 401
    else
      if data == 'uncknown'
        return render :json => {:respMsg => "Uncknown server"}, :status => 401
      end
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
    p db_params['password']
    db_params['password'] = BCrypt::Password.create(add_password_sault(db_params['password']))
    p db_params['password']


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

  def status()
    render :json => {:respMsg => "alive"}, status: 200
  end

  def index()
      @user = User.new(:name=>'joe', :email=>'em', :password=>'p')
      render :json => @user
  end
end



  # if (data = check_token_valid(request.headers['Authorization'])) == false
  #   return render :json => {:respMsg => "Not authorized"}, status: 401
  # else
  #   if data == 'uncknown'
  #     return render :json => {:respMsg => "Uncknown server"}, :status => 401
  #   end
  # end
  # if !check_token_valid params[:appSecret]
    # return render :json => {:respMsg => "Not authoeized"}, status: 401
  # end

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
