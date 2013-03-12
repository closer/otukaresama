# encoding: utf-8
require "mechanize"
require "holiday_jp"


# ポータルにログイン
agent = Mechanize.new

page = agent.get "http://portal.license/"

form = page.form_with :id => "UserLoginForm"
puts "ポータルのユーザー名："
form.field_with(:id => "UserLogin").value    = gets
puts "ポータルのパスワード："
form.field_with(:id => "UserPassword").value = gets

agent.submit form


# 入力データ取得
puts "有休残："
uq = gets.to_i

puts "退社日(xxxx/xx/xx/)："
dates = []
date = Date.parse(gets)


# 休日をのぞいて申請日を算出
until uq == 0
  dates << date and uq -= 1 unless ( date.cwday > 5 || HolidayJp.holiday?(date) )
  date = date - 1
end


# フォーム基本情報セット
add_page = agent.get "/workflows/add"

form = add_page.form_with :id => "WorkflowForm"
form.field_with(:name => "time_kind").value = "3"
form.field_with(:name => "FeatureCodes").value = ""
form.field_with(:name => "").value = ""


# 1日ずつ処理
=begin
dates.reverse.each do |date|
  puts date
  form.field_with(:name => "apply_date").value = ""
end
=end
