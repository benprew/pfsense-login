#!/usr/bin/env ruby

require 'mechanize'
require 'ostruct'
require 'optparse'

opts = OpenStruct.new

OptionParser.new do |parser|
  parser.on("-u", "--url URL", "Login url") do |v|
    opts.url = v
  end

  parser.on("-U", "--user USER", "Basic auth user to login as") do |v|
    opts.user = v
  end

  parser.on("-P", "--password PASSWORD", "Basic auth password") do |v|
    opts.password = v
  end
end.parse!


a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

session = nil

tries = 3

while !session
  a.get(opts.url) do |page|
    page.form_with(class: 'login') do |login|
      login.usernamefld = opts.user
      login.passwordfld = opts.password
    end.click_button

    cookies = a.cookie_jar.cookies(opts.url)
    if cookies.first
      session = cookies.first.to_s
    else
      warn "No session cookie, attempting to login again"
      sleep 3
      raise "Unable to login" if tries -= 1 < 0
    end
  end
end

puts session
