class User < ApplicationRecord
  include Clearance::User

  #=== VALIDATIONS ===#

  validates :name, presence: true, length: { maximum: 50 }

  #=== METHODS ===#

  # Returns URL of this user's gravatar
  def gravatar_url(size = 500)
    email_temp = (email || 'nonexistentuser@example.com').downcase
    gravatar_id = Digest::MD5::hexdigest(email_temp)
    "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}&d=mm"
  end

end
