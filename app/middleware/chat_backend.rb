require 'faye/websocket'
require 'thread'
require 'redis'
require 'json'
require 'erb'


class ChatBackend
  KEEPALIVE_TIME = 15 # in seconds
  CHANNEL        = "chat-demo"

  def initialize(app)
    @app     = app
    @clients = []
    
    if Rails.env == "production"
      uri = URI.parse(ENV["REDISCLOUD_URL"])
      @redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
    else
      @redis = Redis.new
    end
    
    Thread.new do
      # if Rails.env == "production"
      #   redis_sub = Redis.new(host: uri.host, port: uri.port, password: uri.password)
      # else
      #   redis_sub = Redis.new
      # end
      
      redis_sub = Rails.env == "production" ? Redis.new(host: uri.host, port: uri.port, password: uri.password) : Redis.new
      
      redis_sub.subscribe(CHANNEL) do |on|
        on.message do |channel, msg|
          @clients.each {|ws| ws.send(msg) }
        end
      end
    end
  end

  def call(env)
    if Faye::WebSocket.websocket?(env)
      ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })
      ws.on :open do |event|
        p [:open, ws.object_id]
        @clients << ws
      end

      ws.on :message do |event|
        p [:message, event.data]
        @redis.publish(CHANNEL, sanitize(event.data))
      end

      ws.on :close do |event|
        p [:close, ws.object_id, event.code, event.reason]
        @clients.delete(ws)
        ws = nil
        Key.destroy_all
      end

      # Return async Rack response
      ws.rack_response

    else
      @app.call(env)
    end
  end

  private
    def sanitize(message)
      json = JSON.parse(message)
      json.each {|key, value| json[key] = ERB::Util.html_escape(value) }
      JSON.generate(json)
    end
end

