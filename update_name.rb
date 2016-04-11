# coding: utf-8
require 'twitter'
require 'yaml'

def update_profile_name(name, status, client)
  begin
    client.update_profile(:name => name)
    tweet = "@#{status.user.screen_name} #{name}になりました"
    puts "[System] Renamed -> '#{name}' by @#{status.user.screen_name}"
    client.update(tweet, :in_reply_to_status_id => status.id.to_s)
  rescue => ex
    # ignored
  end
end

tokens = YAML.load_file('token.yml')

client = Twitter::REST::Client.new tokens
stream = Twitter::Streaming::Client.new tokens

sn = client.user.screen_name

# 自分以外の人がupdate_nameできるかどうか
# default: false
permission = false

# 名前を変えるための正規表現
update_str1 = /^(?!RT).*@#{sn}\supdate_name\s((.|\n)+?)$/
update_str2 = /^(?!RT).*[（\(]@#{sn}[）\)]$/

puts '[System] stert update_name server'

stream.user do |status|
  next unless status.is_a? Twitter::Tweet
  next if status.text.start_with? 'RT'
  next if status.user.screen_name != sn
  case status.text
    when update_str1
      name = status.text.gsub("@#{sn}\supdate_name\s", '')
      update_profile_name(name, status, client)
    when update_str2
      name = status.text.gsub(/[（\(]@#{sn}[）\)]/, '')
      update_profile_name(name, status, client)
    else
  end
end
