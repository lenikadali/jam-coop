# frozen_string_literal: true

require 'application_system_test_case'

class BuyingAnAlbumTest < ApplicationSystemTestCase
  setup do
    @album = create(:album_with_tracks)
    create(:transcode, track: @album.tracks.first)
    create(:download, album: @album)
    service = stub(create_checkout_session: stub(success?: true, url: 'https://stripe.example.com'))
    StripeService.expects(:new).returns(service)
  end

  test 'purchasing an album' do
    visit artist_album_url(@album.artist, @album)
    click_button 'Buy'
    assert_selector 'button', text: 'Checkout'
    click_button 'Checkout'

    # Fake the Stripe checkout redirect to the "success_url"
    visit purchase_url(Purchase.last)
    assert_text 'Thank you!'
    assert_text 'Download (mp3v0)'
  end
end
