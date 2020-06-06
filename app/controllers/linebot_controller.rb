class LinebotController < ApplicationController

  require 'line/bot'
  require "json"
  require 'net/https'
  require 'open-uri'
  require "date"
  protect_from_forgery :except => [:callback]
  
  def index
  end


  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)
    
    # @sample = "もうやだです"
    # @sample2 = "もういい"
    
    
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          # LINEから送られてきたメッセージが「アンケート」と一致するかチェック
          message = event.message['text']
          # logger.debug("東京に行きたいなー")
          if send_msg(message)
            city = "東京"
            @weather_status =  template(city)
            weather_message = {
              type: 'text',
              text: @weather_status
            }
            logger.debug(@weather_status)
            client.reply_message(event['replyToken'], weather_message)
          end
          
          # if event.message['text'].eql?('アンケート')
            # binding pry
            # private内のtemplateメソッドを呼び出します。
            # client.reply_message(event['replyToken'], template4)
            # client.reply_message(event['replyToken'], template2)
          # end
        end
      end
    }

    head :ok
  end
  
  
  
  def send_msg(msg)
    # logger.debug("東京に行きたいなー")
    if msg == "東京"
      return true
    else
      false
    end
  end
  
  def template(city)
    case city
    when "東京"
      url = "https://api.openweathermap.org/data/2.5/forecast?q=Tokyo&appid=763383863ffb272b64c5303acca61551" 
      response =open(url)
      logger.debug(response)
      data = JSON.parse(response.read, {symbolize_names: true})
      result = weather(data)
      return result
    end
  end
    
  def weather(data)
    item = data[:list]
    cityname = data[:city][:name]
    n = 0
    date = Date.today.to_s
    (0..7).each do |i|
      weather_id = item[i][:weather][0][:id]
      weather_date =  item[i][:dt_txt]
      weather_date = weather_date.slice(0..9)
      
      
      if date == weather_date
        logger.debug("なんでですか")
        weather = get_weather(weather_id)
        if weather == "雨"
          n = 1
          break
        end
      end
      logger.debug(weather)
    end
    if n==1
      return "傘を持っていってください"
    else
      return "今日は傘はいらないよ！"
    end
  end
    
  
  def get_weather(weather_id)
    case weather_id
    when 200, 201, 202, 210, 211, 212, 221, 230, 231, 232, 
      300, 301, 302, 310, 311, 312, 313, 314, 321, 
      500, 501, 502, 503, 504, 511, 520, 521, 522, 523 ,531 then
      weather = '雨'
      return weather
    end
  end
  

  private
  
  
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
  
#   def template
    
#     {
#   "type": "template",
#   "altText": "this is a confirm template",
#   "template": {
#       "type": "confirm",
#       "text": "今日のもくもく会はいかがでしたか",
#       "actions": [
#           {
#             "type": "message",
#             "label": @sample,
#             "text": @sample
#           },
#           {
#             "type": "message",
#             "label": @sample2,
#             "text": @sample2
#           }
#       ]
#   }
# }

#   end
  
  
  # def template2
  # {
  # "type": "location",
  #   "title": "my location",
  #   "address": "〒183-0023 東京都府中市宮町３丁目１２−２１",
  #   "latitude": 35.40026,
  #   "longitude": 139.28549
  # }
  
  # end
  
  # def template3
  #   {
  #     "type": "text",
  #     "text": "お前はバカか"
  #   }
  # end
  
  # def template4
  #   {
  #     "type": "sticker",
  #     "packageId": "1",
  #     "stickerId": "1",
  #     "stickerResourceType": "STATIC"
  #   }
  # end
  
  

end
