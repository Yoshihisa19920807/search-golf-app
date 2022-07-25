require 'rakuten_web_service'
require 'aws-record'

class SearchGolfApp
  include Aws::Record
  integer_attr :golf_course_id, hash_key: true
  integer_attr :duration1
  integer_attr :duration2
end

def lambda_handler(event:, context:)
  # フォーマット修正
  date = event['date'].to_s.insert(4, '-').insert(7, '-')
  budget = event['budget']
  departure = event['departure']
  duration = event["duration"]

  # フロント側から受け取った検索条件をもとに Rakuten API で「予約可能なゴルフ場」を取得
  RakutenWebService.configure do |c|
    c.application_id = ENV['RAKUTEN_APPID']
    c.affiliate_id = ENV['RAKUTEN_AFID']
  end

  matched_plans = []
  plans = RakutenWebService::Gora::Plan.search(
    maxPrice: budget,
    playDate: date,
    areaCode: '8,11,12,13,14',
    # 除外するプランを設定
    NGPlan: 'planHalfRound,planLesson,planOpenCompe,planRegularCompe',
  )

  # 取得した「予約可能なゴルフ場」とDynamoDB に保存しておいた「ゴルフ場とそのゴルフ場までの所要時間」のデータを使って条件がマッチしたゴルフ場だけをフロント側へ返す
  begin
    plans.each do |plan|
      # DynamoDBに保持している所要時間を取得
      plan_duration = SearchGolfApp.find(golf_course_id: plan['golfCourseId']).send("duration#{departure}")
      # 希望の所要時間より長いものの場合はスキップ
      next if plan_duration > duration
      matched_plans.push(
        {
          plan_name: plan['planInfo'][0]['planName'],
          plan_id: plan['planInfo'][0]['planId'],
          course_name: plan['golfCourseName'],
          caption: plan['golfCourseCaption'],
          prefecture: plan['prefecture'],
          image_url: plan['golfCourseImageUrl'],
          evaluation: plan['evaluation'],
          price: plan['planInfo'][0]['price'],
          duration: plan_duration,
          reserve_url_pc: plan['planInfo'][0]['callInfo']['reservePageUrlPC'],
          stock_count: plan['planInfo'][0]['callInfo']['stockCount'],
        }
      )
    end
  rescue => exception
    p exception
    return {
      count: 0,
      plans: []
    }
  end

  matched_plans.sort_by! {|plan| plan[:duration]}

  {
    count: matched_plans.count,
    plans: matched_plans
  }
end
