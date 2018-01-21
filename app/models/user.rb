require 'bcrypt'

class User < ApplicationRecord
    include ActiveModel::Validations
    include ActiveModel::Serializers::JSON
    validates :name,
    :presence => {:message => "Name can't be empty." },
    :uniqueness => {:message => "Name already occupied."}


    validates :email,
    :presence => {:message => "Email can't be empty." },
    :uniqueness => {:message => "Email already exists."}

    validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create

    validates :password,
    :presence => {:message => "Password can't be empty." }

    # TODO add auth_tocken, refresh, time to user
    # i think its generates when login
end
