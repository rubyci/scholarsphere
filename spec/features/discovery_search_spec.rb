# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Searching discoverable resources' do
  let!(:public_work) { create(:work, has_draft: false) }
  let!(:authorized_work) { create(:work, visibility: Permissions::Visibility::AUTHORIZED, has_draft: false) }

  context 'with a public user' do
    it 'searches only public works' do
      visit search_catalog_path
      click_button('Search')

      expect(page).to have_content(public_work.latest_published_version.title)
      expect(page).not_to have_content(authorized_work.latest_published_version.title)
    end
  end

  context 'with a Penn State user' do
    let(:user) { create(:user) }

    it 'searches public and Penn State works', with_user: :user do
      visit search_catalog_path
      click_button('Search')

      expect(page).to have_content(public_work.latest_published_version.title)
      expect(page).to have_content(authorized_work.latest_published_version.title)
    end
  end
end