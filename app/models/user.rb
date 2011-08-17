# Knorbit - knowledge management software
# Copyright (C) 2011  Davi Bayo, Galo Gimenez
#
#MIT License
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

class User < ActiveRecord::Base
  has_many :user_tokens
  has_many :jobs
  
  belongs_to :template, :class_name => "Templates"

  # Contribution table
	has_many :contribute, :foreign_key => "user_id",
                        :class_name => "Contribution"
  
  # Invitation table
  has_many :invitations, :foreign_key => "user_email",
                         :class_name => "Invitations"
                         
  # Activity table
  has_many :activities, :foreign_key => "user_id",
                        :class_name => "Activity"
  
  # Followers table
  has_many :followers, :foreign_key => "follower_id",
                       :dependent => :destroy
                       
  has_many :following, :through => :followers, :source => :followed
  
   has_many :followed, :foreign_key => "followed_id",
                       :dependent => :destroy  
                                                
  has_one :profile, :dependent => :destroy
  has_one :account, :dependent => :destroy
  
  has_many :sent_messages, :foreign_key => "from_id",
                  :class_name => "Message",
                  :dependent => :destroy
                                                  
  has_many :received_messages, :foreign_key => "to_id", 
                  :class_name => "Message"
  
  # Document versions                
  has_many :versions         
  
  #Comments on documents
  has_many :comments  
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  
  # We check that the name is there
  validates :name, :presence => true
  
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session[:omniauth]
        user.user_tokens.build(:provider => data['provider'], :uid => data['uid'])
      end
    end
  end
  
  def apply_omniauth(omniauth)
    #add some info about the user
    self.name = omniauth['user_info']['name'] if name.blank?
    #self.nickname = omniauth['user_info']['nickname'] if nickname.blank?
    
    unless omniauth['credentials'].blank?
      #user_tokens.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
      
      user_tokens.build(:provider => omniauth['provider'], 
                        :uid => omniauth['uid'],
                        :token => omniauth['credentials']['token'], 
                        :secret => omniauth['credentials']['secret'])
    else
      user_tokens.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
    end
    #self.confirm!# unless user.email.blank?
  end
  
  def password_required?
    (user_tokens.empty? || !password.blank?) && super  
  end
  
  def feed
      Activity.from_jobs_followed_by(self)
  end
  
  after_create do
  	@profile = self.create_profile()
    @profile.keyword1 = ""
    @profile.keyword2 = ""
    @profile.keyword3 = ""
    @profile.keyword4 = ""
    @profile.keyword5 = ""
    @profile.qualifier1 = ""
    @profile.qualifier2 = ""
    @profile.qualifier3 = ""
    @profile.qualifier4 = ""
    @profile.qualifier5 = ""
    @profile.save
    
    @account = self.create_account()   
    @account.account = 'Free account'
    @account.reputation = 0
    @account.credit = 0
    @account.language = "English"
    @account.geospace = ""
    @account.userlevel = "Regular"
    @account.active = "Yes"
    @account.maxinv = 10
    @account.allowsms = "Yes"
    @account.allowalerts = "No"  

    @account.save
  end
    
end
