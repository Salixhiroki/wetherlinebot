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
    
    @sample = "もうやだです"
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
            client.reply_message(event['replyToken'], template4)
            # client.reply_message(event['replyToken'], template2)
            
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
    "address": "〒183-0023 東京都府中市宮町３丁目１２−２１",
    "latitude": 35.40026,
    "longitude": 139.28549
  }
  
  end
  
  def template3
    {
      "type": "text",
      "text": "お前はバカか"
    }
  end
  
  def template4
    {
      "type": "sticker",
      "packageId": "1",
      "stickerId": "1",
      "stickerResourceType": "STATIC"
    }
  end
  
  

end
