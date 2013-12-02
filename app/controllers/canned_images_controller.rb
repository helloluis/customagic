class CannedImagesController < ApplicationController

  respond_to :json

  def memes
    
    @page = params[:page]||1

    # url = "http://version1.api.memegenerator.net/Generators_Select_ByPopular?pageSize=24&pageIndex=#{@page}"

    # if resp = HTTParty.get(url)
    #   render json: { result: resp['result'] }
    # else
    #   render :status => 422
    # end

    render json: { result: App.canned_images }
    
  end

end