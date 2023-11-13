# require 'rails_helper'

# RSpec.describe LinkMetaPresenter do
#   let(:description) { nil }
#   let(:temperature) { nil }
#   let(:icon) { nil }

#   subject(:weatherpresenter) { described_class.new(data) } 

#   describe '#nice_weather?' do
#     it 'returns information about the weather' do
#       expect(subject.article).to be article 
#     end
#   end

#   describe '#good_to_read_outside?' do
#     it { is_expected.(:twitter_card).to(:article) } 
#   end

#   describe '#encourage_text' do 
#     it 'returns article by default in all cases' do
#       expect(subject.og_type).to eq 'article'
#     end
#   end

#   describe '#domain' do
#     it 'returns happybearsoftware.com by default in all cases' do
#       expect(subject.domain).to eq 'happybearsoftware.com'
#     end
#   end

#   context 'when the article has a Twitter card' do # First scenario
#     let(:twitter_card) do # We swap our our articles nil twitter card for this let
#       double(:twitter_card,
#              card: 'twitter_card_summary',
#              title: 'Twitter title',
#              description: 'Twitter description',
#              image_url: 'twitter.com/image',
#              creator: '@twitter_card_author',
#              site: 'twitter.com/site')
#     end
#   end
# end