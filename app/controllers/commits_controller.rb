class CommitsController < ApplicationController
  def receive
    user = User.find(1)
    aspects = user.aspects
    
    begin
      payload = JSON.parse(params[:payload])
    
      message = "New push to #{payload[:repository][:name]}\n"
    
      payload[:commits].each do |commit|
        message += "Commit: [#{commit[:message]}](#{commit[:url]}) by #{commit[:author][:name]}"
      end
    
      status_message = user.build_post(:status_message, {:public => true, :text => message})
      if status_message.save
        user.add_to_streams(status_message, aspects)
        user.dispatch_post(status_message, :url => short_post_url(@status_message.guid))
        render :nothing => true, :status => 201
      else
        render :nothing => true, :status => 422
      end
    rescue JSON::ParserError
      render :nothing => true, :status => 422
    end
  end
end
