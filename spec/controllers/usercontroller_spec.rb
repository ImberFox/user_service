require 'rails_helper'

RSpec.describe UserController, :type => :controller do
  before :context do
    user = User.new(:name => "Name", :email => "Email@email.em", :password => "111")
    if user.valid?
      user.save()
    else
      user = User.find_by_name("Name")
    end
    @id = user.id
    @name = user.name
    @email = user.email
  end

  context "check controller" do
    it "checks get user (by id) which dosent exist" do
      get :get_user_by_id, params: {'id' => 6} #params#6 #{:id => 6}

      data = JSON.parse(response.body)
      expect(response.status).to eq(404)
      expect(data['respMsg']).to eq("No such user")
    end

    it "checks get user (by id) invalid id" do
      get :get_user_by_id, params: {'id' => 'fsd'} #params#6 #{:id => 6}

      data = JSON.parse(response.body)
      expect(response.status).to eq(400)
      expect(data['respMsg']).to eq("id is invalid")
    end

    it "checks get user (by id) ok" do
      get :get_user_by_id, params: {'id' => @id} #params#6 #{:id => 6}

      data = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(data['respMsg']).to eq("Ok")
      expect(data['user']['userName']).to eq("Name")
      expect(data['user']['userId']).to eq(@id)
      expect(data['user']['userAvatar']).to eq(nil)
    end

    it "checks get user (by name) which dosent exist" do
      get :get_user_by_name, params: {'userName' => 'srg'} #params#6 #{:id => 6}

      data = JSON.parse(response.body)
      expect(response.status).to eq(404)
      expect(data['respMsg']).to eq("No such user")
    end

    it "checks get user (by name) invalid name" do
      get :get_user_by_name, params: {'userName' => ''} #params#6 #{:id => 6}

      data = JSON.parse(response.body)
      expect(response.status).to eq(400)
      expect(data['respMsg']).to eq("userName is Empty")
    end

    it "checks get user (by name) ok" do
      get :get_user_by_name, params: {'userName' => @name} #params#6 #{:id => 6}

      data = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(data['respMsg']).to eq("Ok")
      expect(data['user']['userName']).to eq(@name)
      expect(data['user']['userId']).to eq(@id)
      expect(data['user']['userAvatar']).to eq(nil)
    end
###########################################################################

    it "checks create user without name" do
      post :create_user, params: {'sefre' => 'etwe'} #params#6 #{:id => 6}

      data = JSON.parse(response.body)
      expect(response.status).to eq(400)
      expect(data['respMsg']).to eq("userName is Empty")
    end

    it "checks create user without email " do
      post :create_user, params: {'userName' => @name} #params#6 #{:id => 6}

      data = JSON.parse(response.body)
      expect(response.status).to eq(400)
      expect(data['respMsg']).to eq("userEmail is Empty")
    end

    it "checks create user with incorrect email" do
      post :create_user, params: {'userName' => @name, 'userEmail' => 'sef'} #params#6 #{:id => 6}

      data = JSON.parse(response.body)
      expect(response.status).to eq(400)
      expect(data['respMsg']).to eq("userEmail is invalid")
    end

    it "checks create user without password" do
      post :create_user, params: {'userName' => @name, 'userEmail' => "ef@seg.rh"} #params#6 #{:id => 6}

      data = JSON.parse(response.body)
      expect(response.status).to eq(400)
      expect(data['respMsg']).to eq("userPassword is Empty")
    end

    it "checks create user with ocupied name" do
      post :create_user, params: {'userName' => @name,
        'userEmail' => "ef@seg.rh", 'userPassword' => 'efew'} #params#6 #{:id => 6}

      data = JSON.parse(response.body)
      expect(response.status).to eq(409)
      expect(data['respMsg']).to eq("userName already occupied")
    end

    it "checks create user with existing email" do
      post :create_user, params: {'userName' => "sfe",
        'userEmail' => @email, 'userPassword' => 'efew'} #params#6 #{:id => 6}

      data = JSON.parse(response.body)
      expect(response.status).to eq(409)
      expect(data['respMsg']).to eq("userEmail already exist")
    end

    it "checks create user ok" do
      post :create_user, params: {'userName' => "drgr", 'userEmail' => "sgfr@sef.hf",
        'userPassword' => 'efe'} #params#6 #{:id => 6}

      data = JSON.parse(response.body)
      expect(response.status).to eq(201)
      expect(data['respMsg']).to eq("Ok")
    end
  end

  context "checks status" do
    it "check" do
      get :status
      expect(response.status).to eq(200)
    end
  end
end
