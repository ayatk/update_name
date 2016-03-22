# coding: utf-8
require 'twitter'

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

def symbolize_keys(hash)
  hash.map { |k, v| [k.to_sym, v] }.to_h
end

tokens = YAML.load_file('config.yml')

client = Twitter::REST::Client.new symbolize_keys(tokens)
stream = Twitter::Streaming::Client.new symbolize_keys(tokens)

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
