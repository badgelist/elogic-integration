require 'rails_helper'

RSpec.feature 'User management' do

  let(:user) { build(:user) }

  it 'Signs a user in' do
    visit '/sign_in'
    
    expect(page).to have_button 'Sign in'
    expect(page).to have_field 'Email'
    expect(page).to have_field 'Password'

    # fill_in 'Email', with: user.email
    # fill_in 'Password', with: 'validPassword123'
    # click_button 'Sign in'

    # expect(page).to have_link 'Sign out'
  end

end