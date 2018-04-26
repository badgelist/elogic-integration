require 'rails_helper'

RSpec.feature 'User management' do
  include RSpec::Rails::ControllerExampleGroup

  let(:users) { create_list(:user, 3) }

  scenario 'User views list of users' do
    manually_sign_in_user(users[0])
    expect(page).to have_link 'Sign out'

    visit users_path
    
    expect(page).to have_text 'Manage Server Admin Users'
    expect(page).to have_text users[0].email
    expect(page).to have_text users[1].email
    expect(page).to have_text users[2].email
  end

  scenario 'User creates new user' do
    expect(User.count).to eq 0
    manually_sign_in_user(users[0])
    expect(page).to have_link 'Sign out'

    visit users_path
    expect(User.count).to eq 3
    
    expect(page).to have_text 'Manage Server Admin Users'
    expect(page).to have_link 'New User'
    
    click_link 'New User'
    expect(page).to have_text 'Create New Admin User'
    
    # First check that saving a blank form is an error
    click_button 'Save'
    expect(page).to have_content 'There was a problem'
    expect(page).to have_text 'Create New Admin User'

    # Then check that filling everything in creates a new user
    fill_in 'Name', with: 'Abraham Testingtons'
    fill_in 'Email', with: 'abe@example.com'
    fill_in 'Password', with: 'password'
    click_button 'Save'

    expect(page).to have_content 'User successfully created'
    expect(page).to have_text 'Manage Server Admin Users'
    expect(page).to have_text 'abe@example.com'
    expect(User.count).to eq 4
  end

  scenario 'User edits user' do
    manually_sign_in_user(users[0])
    expect(page).to have_link 'Sign out'

    visit edit_user_path(users[1])
    
    expect(page).to have_text 'Modify User'
    expect(find_field('Email').value).to eq users[1].email
    
    # Delete name and check that it can't be saved
    fill_in 'Name', with: ''
    click_button 'Update User'
    expect(page).to have_content 'There was a problem'
    expect(page).to have_text 'Modify User'
    
    # Fix name and do the update
    fill_in 'Name', with: 'New Name 567'
    click_button 'Update User'
    expect(page).to have_text 'Manage Server Admin Users'
    expect(page).to have_text 'New Name 567'

    user = User.find(users[1].id)
    expect(user.name).to eq 'New Name 567'
  end

  scenario 'User deletes user' do
    manually_sign_in_user(users[0])
    expect(page).to have_link 'Sign out'

    expect(User.count).to eq 3
    visit edit_user_path(users[1])
    expect(page).to have_text 'Modify User'
    expect(find_field('Email').value).to eq users[1].email

    click_link 'Delete user'
    expect(page).to have_text 'Manage Server Admin Users'
    expect(page).to have_content 'User successfully deleted'
    expect(User.count).to eq 2
  end

end