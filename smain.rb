# encoding: utf-8
require "selenium-webdriver"
require "holiday_jp"


# ポータルにログイン
driver = Selenium::WebDriver.for :chrome

begin

  driver.get "http://portal.license/"

  puts "ポータルユーザー名："
  driver.find_element(:id,"UserLogin").send_keys gets.strip
  puts "ポータルパスワード："
  driver.find_element(:id, "UserPassword").send_keys gets.strip

  form = driver.find_element :id, "UserLoginForm"
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

  # 1日ずつ処理
  dates.reverse.each do |date|

    puts date

    # 申請画面へはいる
    driver.get "http://portal.license/mypages/index"

    driver.find_element(:id, 'workflow_type_id').send_key "年次"
    driver.find_element(:name, "申請する").click

    sleep 3

    # フォーム基本情報セット
    driver.find_element(:id, "WorkflowTimeKind3").click
    driver.execute_script(%[$$("[name='apply_date']")[0].value = "#{date.strftime("%Y-%m-%d")}";])

    %w|422 247|.each do |id|
      driver.find_element(:xpath, "//option[@value='#{id}']").click
      driver.execute_script("SelectMoveRows(document.WorkflowForm.Features,document.WorkflowForm.FeatureCodes);")
    end
    driver.find_element(:name, "data[Workflow][body]").send_key ""

    sleep 2

    driver.find_element(:name, "data[Workflow][mode]").click
  end

ensure
  driver.close
end
