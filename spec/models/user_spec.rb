require 'rails_helper'

RSpec.describe User, type: :model do

  it 'has a valid factory' do
    expect(build(:user)).to be_valid
  end

  let(:user) { build(:factory_you_built) }

  describe 'ActiveRecord fields and associations' do

    it { expect(user).to have_attributes :name, :email, :password }

  end

end