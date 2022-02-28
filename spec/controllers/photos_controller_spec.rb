# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe PhotosController, :type => :controller do
  before do
    @alices_photo = alice.post(:photo, :user_file => uploaded_photo, :to => alice.aspects.first.id, :public => false)
    @bobs_photo = bob.post(:photo, :user_file => uploaded_photo, :to => bob.aspects.first.id, :public => true)

    sign_in alice, scope: :user
    request.env["HTTP_REFERER"] = ''
  end

  describe '#create' do
    before do
      @params = {
        :photo => {:aspect_ids => "all"},
        :qqfile => Rack::Test::UploadedFile.new(
          Rails.root.join("spec", "fixtures", "button.png").to_s,
          "image/png"
        )
      }
    end

    it 'accepts a photo from a regular form submission' do
      expect {
        post :create, params: @params
      }.to change(Photo, :count).by(1)
    end

    it 'returns application/json when possible' do
      request.env['HTTP_ACCEPT'] = 'application/json'
      expect(post(:create, params: @params).headers["Content-Type"]).to match "application/json.*"
    end

    it 'returns text/html by default' do
      request.env['HTTP_ACCEPT'] = 'text/html,*/*'
      expect(post(:create, params: @params).headers["Content-Type"]).to match "text/html.*"
    end
  end

  describe '#create' do
    before do
      allow(@controller).to receive(:file_handler).and_return(uploaded_photo)
      @params = {photo: {user_file: uploaded_photo, aspect_ids: "all", pending: true}}
    end

    it "creates a photo" do
      expect {
        post :create, params: @params
      }.to change(Photo, :count).by(1)
    end

    it "doesn't allow mass assignment of person" do
      new_user = FactoryBot.create(:user)
      @params[:photo][:author] = new_user
      post :create, params: @params
      expect(Photo.last.author).to eq(alice.person)
    end

    it "doesn't allow mass assignment of person_id" do
      new_user = FactoryBot.create(:user)
      @params[:photo][:author_id] = new_user.id
      post :create, params: @params
      expect(Photo.last.author).to eq(alice.person)
    end

    it "can set the photo as the profile photo and unpends the photo" do
      old_url = alice.person.profile.image_url
      @params[:photo][:set_profile_photo] = true
      post :create, params: @params
      new_url = alice.reload.person.profile.image_url
      expect(new_url).not_to eq(old_url)
      expect(Photo.find_by(remote_photo_name: new_url.rpartition("_").last).pending).to be_falsey
    end
  end

  describe '#destroy' do
    it 'will let you delete your profile picture' do
      get :make_profile_photo, params: {photo_id: @alices_photo.id}, xhr: true, format: :js
      delete :destroy, params: {id: @alices_photo.id}, format: :json
      expect(Photo.find_by_id(@alices_photo.id)).to be_nil
    end
  end

  describe "#make_profile_photo" do
    it 'should return a 201 on a js success' do
      get :make_profile_photo, params: {photo_id: @alices_photo.id}, xhr: true, format: :js
      expect(response.code).to eq("201")
    end

    it 'should return a 422 on failure' do
      get :make_profile_photo, params: {photo_id: @bobs_photo.id}
      expect(response.code).to eq("422")
    end
  end
end
