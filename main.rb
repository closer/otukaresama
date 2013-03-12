# encoding: utf-8
require "mechanize"
require "holiday_jp"


# ポータルにログイン
agent = Mechanize.new

page = agent.get "http://portal.license/"

form = page.form_with :id => "UserLoginForm"
puts "ポータルユーザー名："
form.field_with(:id => "UserLogin").value    = gets.strip
puts "ポータルパスワード："
form.field_with(:id => "UserPassword").value = gets.strip

form.submit


# 入力データ取得
puts "有休残："
uq = gets.to_i

puts "退社日(xxxx/xx/xx/)："
dates = []
date = Date.parse(gets.strip)


# 休日をのぞいて申請日を算出
until uq == 0
  dates << date and uq -= 1 unless ( date.cwday > 5 || HolidayJp.holiday?(date) )
  date = date - 1
end

mypage = agent.get "/mypages/index"
form = mypage.form_with :action => "/workflows/add"
form.field_with(:id => 'workflow_type_id').value = "1"

# フォーム基本情報セット
add_page = form.submit
form = add_page.form_with :name => "WorkflowForm"
form.field_with(:name => "time_kind").value = "3"
form.field_with(:name => "FeatureCodes").value = %w|422 247|
form.field_with(:name => "data[Workflow][body]").value = ""

# 1日ずつ処理
dates.reverse.each do |date|
  puts date
  form.field_with(:name => "apply_date").value = date.strftime("%Y-%m-%d")
  form.fields.each{|f| p f }
  # p form.submit.body.toutf8
end

