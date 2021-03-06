# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Doi do
  subject { described_class.new(doi) }

  context 'with doi:10.26207/jc7z-sa94' do
    let(:doi) { 'doi:10.26207/jc7z-sa94' }

    it { is_expected.to be_valid }
    it { is_expected.to be_managed }
    its(:prefix) { is_expected.to eq('10.26207') }
    its(:directory_indicator) { is_expected.to eq('10') }
    its(:registrant_code) { is_expected.to eq('26207') }
    its(:suffix) { is_expected.to eq('jc7z-sa94') }
    its(:to_s) { is_expected.to eq('doi:10.26207/jc7z-sa94') }
    its(:uri) { is_expected.to eq(URI('https://doi.org/10.26207/jc7z-sa94')) }
  end

  context 'with doi:10.18113/S1X934' do
    let(:doi) { 'doi:10.18113/S1X934' }

    it { is_expected.to be_valid }
    it { is_expected.to be_managed }
  end

  context 'with a configured prefix' do
    let(:doi) { "doi:#{ENV['DATACITE_PREFIX']}/fvr2-yw38" }

    before { ENV['DATACITE_PREFIX'] = "10.#{Faker::Number.number(digits: 5)}" }

    it { is_expected.to be_valid }
    it { is_expected.to be_managed }
  end

  context 'with https://doi.org/10.1515/pol-2020-2011' do
    let(:doi) { 'https://doi.org/10.1515/pol-2020-2011' }

    it { is_expected.to be_valid }
    it { is_expected.not_to be_managed }
    its(:prefix) { is_expected.to eq('10.1515') }
    its(:directory_indicator) { is_expected.to eq('10') }
    its(:registrant_code) { is_expected.to eq('1515') }
    its(:suffix) { is_expected.to eq('pol-2020-2011') }
    its(:to_s) { is_expected.to eq('doi:10.1515/pol-2020-2011') }
    its(:uri) { is_expected.to eq(URI('https://doi.org/10.1515/pol-2020-2011')) }
  end

  context 'with 10.1007/s10570-013-0029-x' do
    let(:doi) { '10.1007/s10570-013-0029-x' }

    it { is_expected.to be_valid }
    it { is_expected.not_to be_managed }
    its(:prefix) { is_expected.to eq('10.1007') }
    its(:directory_indicator) { is_expected.to eq('10') }
    its(:registrant_code) { is_expected.to eq('1007') }
    its(:suffix) { is_expected.to eq('s10570-013-0029-x') }
    its(:to_s) { is_expected.to eq('doi:10.1007/s10570-013-0029-x') }
    its(:uri) { is_expected.to eq(URI('https://doi.org/10.1007/s10570-013-0029-x')) }
  end

  context 'with an invalid directory indicator' do
    let(:doi) { 'doi:12.1234/asdf' }

    it { is_expected.not_to be_valid }
  end

  context 'with an invalid prefix' do
    let(:doi) { 'doi:qwer/asdf' }

    it { is_expected.not_to be_valid }
  end

  context 'with no suffix' do
    let(:doi) { 'doi:10.1000/' }

    it { is_expected.not_to be_valid }
  end

  context 'with only a prefix' do
    let(:doi) { 'doi:10.1234' }

    it { is_expected.not_to be_valid }
  end

  context 'with whitespace' do
    let(:doi) { '  doi:10.26207/jc7z-sa94 ' }

    it { is_expected.to be_valid }
    it { is_expected.to be_managed }
  end

  context 'with a subdivision in the registrant code' do
    let(:doi) { 'doi:10.26207.10/jc7z-sa94' }

    it { is_expected.to be_valid }
    it { is_expected.not_to be_managed }
    its(:directory_indicator) { is_expected.to eq('10') }
    its(:registrant_code) { is_expected.to eq('26207.10') }
  end
end
