class User < ActiveRecord::Base
  validates_presence_of :username, uniqueness: true
  validates_presence_of :password_digest, uniqueness: true
  validates_presence_of :session_token, uniqueness: true
  validates :password, length: { minimum: 6, allow_nil: true }

  attr_reader :password
  # has_many :cars ?
  after_initialize :ensure_session_token

  def self.find_by_credentials(username, password)
    user = User.find_by(username: username)

    return nil if user.nil?
    user.is_password?(password) ? user : nil
  end

  def is_password?(password)
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def reset_session_token!
    self.session_token = SecureRandom.urlsafe_base64
    self.save!
    self.session_token
  end

  private

  def ensure_session_token
    self.session_token ||= SecureRandom.urlsafe_base64
  end
end
