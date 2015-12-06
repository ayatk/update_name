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

  if status.text =~ /^((?!RT).*@#{sn}\supdate_name\s((.|\n)+?)|.+?\(@#{sn}\))$/
    # 許可されていないユーザーのupdate_nameをブロック
    if status.user.screen_name != sn && !permission
      option = {"in_reply_to_status_id" => status.id.to_s}
      tweet = "@#{status.user.screen_name} その操作は許可されていません"
      client.update tweet,option
      puts "[System] Blocked rename -> \'#{name}\' by @#{status.user.screen_name}"
      next
    end

    name = status.text.gsub("@#{sn}\supdate_name\s","").gsub("(@#{sn})","")
    name.strip!

    begin
      option = {"in_reply_to_status_id" => status.id.to_s}
      if name.length == 0 # 変更する名前が0文字の時
        tweet = "@#{status.user.screen_name} 0文字はダメですo(｀ω´*)oﾌﾟﾝｽｶﾌﾟﾝｽｶ!!"
        puts "[System] named at 0character by @#{status.user.screen_name}"
      elsif name.length < 20
        client.update_profile(:name => name)
        tweet = "@#{status.user.screen_name} 「#{name}」に名前を変えました"
        puts "[System] Renamed -> \'#{name}\' by @#{status.user.screen_name}"
      else # 変更する名前が20文字以上の時
        tweet = "@#{status.user.screen_name} 「#{name}」は文字数オーバーです(´・ω・`)"
        puts "[System] over naming -> \'#{name}\' by @#{status.user.screen_name}"
      end
      client.update tweet,option
    rescue => ex
      puts "[System] update name denied for #{ex.class} -> \'#{name}\' by @#{status.user.screen_name}\n"
      notice = "@#{status.user.screen_name} 変更に失敗しました -> #{ex.class}"
      option = {"in_reply_to_status_id" => status.id.to_s}
      if notice.length < 140
        tweet = "@#{status.user.screen_name} 変更に失敗しました -> #{ex.class}"
      else
        tweet = "@#{status.user.screen_name} 変更に失敗しました"
      end
      client.update tweet,option
      next
    end
  end
end
