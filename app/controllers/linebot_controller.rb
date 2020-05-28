class LinebotController < ApplicationController

  require 'line/bot'

  protect_from_forgery :except => [:callback]
  
  def index
  end
  
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)
    
    @sample = "もうやだ"
    @sample2 = "もういい"
    
    
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          # LINEから送られてきたメッセージが「アンケート」と一致するかチェック
          if event.message['text'].eql?('アンケート')
            # binding pry
            # private内のtemplateメソッドを呼び出します。
            client.reply_message(event['replyToken'], template)
            client.reply_message(event['replyToken'], template2)
            
          end
        end
      end
    }

    head :ok
  end

  private
  
  def template
    
    {
  "type": "template",
  "altText": "this is a confirm template",
  "template": {
      "type": "confirm",
      "text": "今日のもくもく会はいかがでしたか",
      "actions": [
          {
            "type": "message",
            "label": @sample,
            "text": @sample
          },
          {
            "type": "message",
            "label": @sample2,
            "text": @sample2
          }
      ]
  }
}

  end
  
  
  def template2

    {
      "type": "location",
      "title": "my location",
      "address": "〒150-0002 東京都渋谷区渋谷２丁目２１−１",
      "latitude": 35.65910807942215,
      "longitude": 139.70372892916203
    }  
  
  end

end
