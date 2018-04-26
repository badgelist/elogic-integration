require 'rails_helper'

RSpec.feature 'User management' do
  include RSpec::Rails::ControllerExampleGroup

  let(:users) { create_list(:user, 3) }

  it 'Index displays list of users' do
    user = users[0]

    visit sign_in_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'validPassword123'
    click_button 'Sign in'

    expect(page).to have_link 'Sign out'
    visit users_path
    
    expect(page).to have_text 'Manage Server Admin Users'
    expect(page).to have_text users[0].email
    expect(page).to have_text users[1].email
    expect(page).to have_text users[2].email
  end

end