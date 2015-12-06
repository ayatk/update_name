# coding: utf-8
require 'twitter'

puts "[System] stert update_name server"

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV["CONSUMER_KEY"]
  config.consumer_secret     = ENV["CONSUMER_SECRET"]
  config.access_token        = ENV["ACCESS_TOKEN"]
  config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
end

stream_client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = ENV["CONSUMER_KEY"]
  config.consumer_secret     = ENV["CONSUMER_SECRET"]
  config.access_token        = ENV["ACCESS_TOKEN"]
  config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
end
sn = 'AyaTokikaze'

stream_client.user do |status|
  # 自分以外の人がupdate_nameできるかどうか
  # default: false
  permission = false
  next unless status.is_a? Twitter::Tweet
  next if status.text.start_with? "RT"
  when condition

  if status.text =~ /^(?!RT)(.*@#{sn}\supdate_name\s((.|\n)+?)|.+?\(@#{sn}\))$/
    # 許可されていないユーザーのupdate_nameをブロック
    if status.user.screen_name != sn && !permission
      option = {"in_reply_to_status_id" => status.id.to_s}
      tweet = "@#{status.user.screen_name} その操作は許可されていません"
      client.update tweet,option
      puts "[System] Blocked rename -> \'#{name}\' by @#{status.user.screen_name}"
      next
    end

    name = status.text.gsub("@#{sn}\supdate_name\s","")
    name = status.text.gsub("(@#{sn})","")
    name.strip!

    begin
      if name.length > 20 # 変更する名前が20文字以上の時
        option = {"in_reply_to_status_id" => status.id.to_s}
        tweet = "@#{status.user.screen_name} 「#{name}」は文字数オーバーです"
        client.update tweet,option
        puts "[System] over naming -> \'#{name}\' by @#{status.user.screen_name}"
      else
        client.update_profile(:name => name)
        option = {"in_reply_to_status_id" => status.id.to_s}
        tweet = "@#{status.user.screen_name} 「#{name}」に名前を変えました"
        client.update tweet,option
        puts "[System] Renamed -> \'#{name}\' by @#{status.user.screen_name}"
      end
    rescue
      puts 'update_name denied.'
      notice = "@#{status.user.screen_name} 変更に失敗しました: #{name}"
      if notice.length < 140
        @rest_client.update("@#{status.user.screen_name} 変更に失敗しました: #{name}")
      else
        @rest_client.update("@#{status.user.screen_name} 変更に失敗しました")
      end
    end
  end
end
