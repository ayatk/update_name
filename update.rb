# coding: utf-8
require 'twitter'
require 'optparse'
require 'yaml'


def opt(array)
  option={}
  OptionParser.new do |opt|
    # opt.on('-i ICON_NAME', '--icon=ICON_NAME',
    #        'アイコンの変更 [いつもの | ネガ | モノクロ | ぱら | のこ]') { |v| option[:icon] = v }
    opt.on('-n NAME', '--name=NAME', '名前の変更') { |v| option[:name] = v }
    opt.on('-l LOCATION', '--location=LOCATION', 'ロケーションの変更') { |v| option[:location] = v }
  end.parse(array)
  option
end

# def update_icon(icon, client)
#   unless @icon_hash.include?(icon.to_sym)
#     return 'Error => そのアイコンはありません'
#   end
#   client.update_profile_image("images/#{icon}")
#   "アイコンを#{icon}に変更しました"
# end

def update_name(name, client)
  if !name.length.between?(1, 20) or name =~ /^@|update|-n|--name/
    return 'Error => その名前は使用できません'
  end
  client.update_profile(:name => name)
  "名前を#{name}にしました"
end

def update_location(location, client)
  if location.length > 30 or location =~ /^@|update|-n|--name/
    return 'Error => ロケーションは30文字以下に設定してください'
  end
  client.update_profile(:location => location)
  "場所を#{location}に設定しました"
end

def reply(str, status, client)
  str.insert(0, "@#{status.user.screen_name}")
  if str.length >= 140
    str.slice!(139..-1)
    str += '…'
  end
  client.update(str, :in_reply_to_status_id => status.id.to_s)
end

update_str = /^(?!RT).*@#{@sn}\supdate\s((.|\n)+?)$/

tokens = YAML.load_file('token.yml')


client = Twitter::REST::Client.new tokens
stream = Twitter::Streaming::Client.new tokens

@sn = client.user.screen_name

stream.user { |status|
  p status.text
  next unless status.is_a? Twitter::Tweet
  next if status.text.start_with? "RT"
  reply_str = ''
  case status.text
    when update_str
      option = status.text.gsub("@#{@sn}\supdate\s", '')
      p option
      opt_hash = opt(option.split(' '))
      p opt_hash
      # if opt_hash[:icon]
      #
      #   reply_str += "\n" + update_icon(opt_hash[:icon], client)
      # end
      if opt_hash[:name]
        reply_str += "\n" + update_name(opt_hash[:name], client)
      end
      if opt_hash[:location]
        reply_str += "\n" + update_location(opt_hash[:location], client)
      end
      next if reply_str == ''
      p reply_str
      reply(reply_str, status, client)
  end
}
