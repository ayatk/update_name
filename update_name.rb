# coding: utf-8
require 'twitter'

def update_profile_name(name, status, client)
  begin
    client.update_profile(:name => name)
    tweet = "@#{status.user.screen_name} #{name}になりました"
    puts "[System] Renamed -> \'#{name}\' by @#{client.user.screen_name}"
    client.update(tweet,:in_reply_to_status_id => client.id.to_s)
  rescue => ex
    puts "[System] update name denied for #{ex.class} -> \'#{name}\' by @#{client.user.screen_name}\n"
    tweet = "@#{status.user.screen_name} 変更できませんでした…(m´・ω・｀)m ｺﾞﾒﾝ…ﾅｻｲ \n-> #{ex.class}"
    client.update(tweet,:in_reply_to_status_id => client.id.to_s)
  end
end


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

# 自分のsn
sn = 'AyaTokikaze'

# 自分以外の人がupdate_nameできるかどうか
# default: false
permission = false

# 名前を変えるための正規表現
update_str1 = /^(?!RT).*@#{sn}\supdate_name\s((.|\n)+?)$/
update_str2 = /^(?!RT).*[（\(]@#{sn}[）\)]$/

puts "[System] stert update_name server"

stream_client.user do |status|
  next unless status.is_a? Twitter::Tweet
  next if status.text.start_with? "RT"
  case status.text
  when update_str1
	name = status.text.gsub("@#{sn}\supdate_name\s","").strip!
    update_profile_name(name, status, client)
  when update_str2
	name = status.text.gsub(/[（\(]@#{sn}[）\)]/, "").strip!
    update_profile_name(name, status, client)
  end
end
