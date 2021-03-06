require 'rails_helper'

RSpec.describe User, type: :model do

  it 'has a valid factory' do
    expect(build(:user)).to be_valid
  end

  let(:user) { build(:user) }

  describe 'ActiveRecord fields and associations' do

    it { expect(user).to have_attribute :name }
    it { expect(user).to have_attribute :email }
    it { expect(user).to respond_to :gravatar_url }
    it { expect(user.gravatar_url).to include 'https://secure.gravatar.com/avatar' }

  end

end