require 'rails_helper'
require 'pry'

RSpec.describe BooksController, type: :controller do 
  let(:user) { create(:user) }
  let!(:matching_book) { create(:book, title: 'True Book') }
  let!(:non_matching_book) { create(:book, title: 'False Book') }

  before do
    sign_in user
  end

  describe "GET #index" do
    it 'renders the index template' do 
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET #search" do
    context "when a search term is provided" do
      before do
        get :search, params: { search: 'True' }, format: :json
      end

      it "returns a successful response" do
        expect(response).to be_successful
      end

      it "returns JSON content type" do
        expect(response.content_type).to include("application/json")
      end
    end
  end

  describe "GET #search" do
    context "when a search term is provided" do
      it "returns a successful response and the correct content type" do
        get :search, params: { search: 'True' }, format: :json
        expect(response).to be_successful
        expect(response.content_type).to include("application/json")
      end
    end
  end
end
