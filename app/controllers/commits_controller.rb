class CommitsController < ApplicationController
  def receive
    user = User.find(511)
    aspects = user.aspects
    aspect_ids = aspects.map {|aspect| aspect.id }
        
    begin
      payload = JSON.parse(params[:payload]).deep_symbolize_keys

      message = "New push to **#{payload[:ref].split("/").last}** at [#{payload[:repository][:name].capitalize}](#{payload[:repository][:url]})\n\n"
    
      payload[:commits].each do |commit|
        commit = commit.deep_symbolize_keys
        message += "Commit: [#{commit[:message].gsub(/\n/," ")}](#{commit[:url]}) by *#{commit[:author][:name]}*\n\n"
      end
      
      message += "##{payload[:repository][:name]}_push ##{payload[:repository][:name]}_#{payload[:ref].split("/").last}_push"    
      
      status_message = user.build_post(:status_message, {:public => true, :text => message, :aspect_ids => aspect_ids})
      if status_message.save
        user.add_to_streams(status_message, aspects)
        user.dispatch_post(status_message, :url => short_post_url(status_message.guid))
        render :nothing => true, :status => 201
      else
        render :nothing => true, :status => 422
      end
    rescue JSON::ParserError
      render :nothing => true, :status => 422
    end
  end
end
