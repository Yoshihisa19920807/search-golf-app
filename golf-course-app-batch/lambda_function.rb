require 'rakuten_web_service'
require 'google_maps_service'
require 'aws-record'

class SearchGolfApp
  include Aws::Record
  integer_attr :golf_course_id, hash_key: true
  integer_attr :duration1
  integer_attr :duration2
end

module Area
  # 楽天APIで定められているエリアコード（8:茨城県,11:埼玉県,12:千葉県,13:東京都,14:神奈川県）
  CODES = ['8', '11', '12', '13', '14']
end

module Departure
  # 基準とする出発地点
  DEPARTURES = {
    1 => '東京駅',
    2 => '横浜駅',
  }
end

def duration_minutes(departure, destination)
  gmaps = GoogleMapsService::Client.new(key: ENV['GOOGLE_MAP_API_KEY'])
  routes = gmaps.directions(
    departure,
    destination,
    region: 'jp'
  )
  return unless routes.first # ルートが存在しない時はnilを返す
  duration_seconds = routes.first[:legs][0][:duration][:value] #所要時間
  duration_minutes = duration_seconds / 60
end

def put_item(course_id, durations)
  p course_id
  p durations
  return if SearchGolfApp.find(golf_course_id: course_id)
  duration = SearchGolfApp.new
  p duration
  duration.golf_course_id = course_id
  duration.duration1 = durations.fetch(1)
  duration.duration2 = durations.fetch(2)
  duration.save
end

def lambda_handler(event:, context:)
  RakutenWebService.configure do |c|
    c.application_id = ENV['RAKUTEN_APPID']
    c.affiliate_id = ENV['RAKUTEN_AFID']
  end

  Area::CODES.each do |code|
    1.upto(100) do |page|
      # コース一覧を取得
      courses = RakutenWebService::Gora::Course.search(areaCode: code, page: page)
      courses.each do |course|
        course_id = course['golfCourseId']
        course_name = course['golfCourseName']
        next if course_name.include?('レッスン') # ゴルフ場以外の情報をスキップ
        # 出発地点から取得したゴルフ場までの所要時間をGoogle Maps Platformで取得する
        durations = {}
        Departure::DEPARTURES.each do |duration_id, departure|
          minutes = duration_minutes(departure, course_name)
          durations.store(duration_id, minutes) if minutes
        end
        # 取得した取得した情報をDynamoDBに保存する
        put_item(course_id, durations) unless durations.empty?
      end
      break unless courses.next_page? # 次のページが存在するか確認
    end

  end
  { statusCode: 200 }
end
