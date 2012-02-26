class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def render_404
    render :template => "pages/404", :layout => 'application', :status => :not_found, :content_type => Mime::HTML
  end
  
end
