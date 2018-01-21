require 'bcrypt'

class User < ApplicationRecord
    include ActiveModel::Validations
    include ActiveModel::Serializers::JSON
    include BCrypt
    validates :name,
    :presence => {:message => "Name can't be empty." },
    :uniqueness => {:message => "Name already occupied."}


    validates :email,
    :presence => {:message => "Email can't be empty." },
    :uniqueness => {:message => "Email already exists."}

    validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create

    validates :password,
    :presence => {:message => "Password can't be empty." }

    # def password()
    #   @password ||= Password.new(password_hash)
    # end
    #
    # def password=(new_password)
    #   @password = Password.create(new_password)
    #   self.password_hash = @password
    # end
end
