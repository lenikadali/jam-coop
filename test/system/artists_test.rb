# frozen_string_literal: true

require 'application_system_test_case'

class ArtistsTest < ApplicationSystemTestCase
  setup do
    sign_in_as(create(:user))
    @artist = build(:artist)
  end

  test 'adding a new artist' do
    visit artists_url
    click_on 'New artist'
    fill_in 'Name', with: @artist.name
    click_on 'Save'
    assert_selector 'h1', text: @artist.name
  end
end
