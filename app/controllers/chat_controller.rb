class ChatController < ApplicationController
  def room
    @scheme = Rails.env == "production" ? "wss://" : "ws://"
  end
end
