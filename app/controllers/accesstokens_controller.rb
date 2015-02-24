class AccesstokensController < ApplicationController
	respond_to :html
  def index
  	@accesstokens = AccessToken.all
  	respond_with(@accesstokens)
  end
end
