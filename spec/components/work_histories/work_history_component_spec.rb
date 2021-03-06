# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkHistories::WorkHistoryComponent, type: :component, versioning: true do
  let(:user) { create :user }

  let(:work) { create :work, versions: [draft, v1], depositor: user.actor }

  let(:draft) { build :work_version, :draft, title: 'Draft Version', work: nil, created_at: 1.day.ago }
  let(:v1) { build :work_version, :published, title: 'Published v1', work: nil, created_at: 3.days.ago }

  # This is normally done automatically in the controller, but we need to do it
  # here to get our user on the changes above
  before do
    PaperTrail.request.whodunnit = editor.to_gid
  end

  describe 'rendering' do
    context 'with a standard user' do
      let(:editor) { create(:user) }

      it 'renders the work history' do
        result = render_inline(described_class.new(work: work))

        expect(result.css('h3').text)
          .to include("Version #{draft.version_number}")
          .and include("Version #{v1.version_number}")

        expect(result.css('.version-timeline__list').length).to eq 2

        # Draft version has work-version changes but no files
        expect(result.css("#work_version_changes_#{draft.id} .version-timeline__change--work-version")).to be_present
        expect(result.css("#work_version_changes_#{draft.id} .version-timeline__change--file")).to be_empty

        # Published version has work-version, file, and creator changes
        expect(result.css("#work_version_changes_#{v1.id} .version-timeline__change--work-version")).to be_present
        expect(result.css("#work_version_changes_#{v1.id} .version-timeline__change--file")).to be_present
        expect(result.css("#work_version_changes_#{v1.id} .version-timeline__change--creator")).to be_present

        # User's access is displayed
        expect(result.css("#work_version_changes_#{v1.id}").text).to include editor.access_id
      end
    end

    context 'with an external application' do
      let(:editor) { create(:external_app) }

      it 'renders the work history using the name of the application' do
        work # Implicitly create all user records via the `let`s

        result = render_inline(described_class.new(work: work))
        expect(result.css("#work_version_changes_#{v1.id}").text).to include editor.name
      end
    end

    context 'when the user cannot be found' do
      let(:editor) { build(:user, id: '12345') }

      it 'renders a null user' do
        work # Implicitly create all user records via the `let`s

        result = render_inline(described_class.new(work: work))
        expect(result.css("#work_version_changes_#{v1.id}").text).to include '[unknown user]'
      end
    end
  end
end
