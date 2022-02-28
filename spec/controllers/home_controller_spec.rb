# frozen_string_literal: true

#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe HomeController, type: :controller do
  describe "#toggle_mobile" do
    it "changes :mobile to :html" do
      session[:mobile_view] = true
      get :toggle_mobile
      expect(session[:mobile_view]).to be false
    end

    it "changes :html to :mobile" do
      session[:mobile_view] = nil
      get :toggle_mobile
      expect(session[:mobile_view]).to be true
    end
  end

  describe "#force_mobile" do
    it "changes :html to :mobile" do
      session[:mobile_view] = nil
      get :force_mobile
      expect(session[:mobile_view]).to be true
    end

    it "keeps :mobile" do
      session[:mobile_view] = true
      get :force_mobile
      expect(session[:mobile_view]).to be true
    end
  end
end
