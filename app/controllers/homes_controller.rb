require 'httparty'

class HomesController < ApplicationController  
  include HTTParty

  def index
    @selected_city = nil
    if params[:city].present? || params[:date]
      @selected_city = params[:city]
      @selected_date = params[:date]
      month = Date.parse(@selected_date).strftime("%m")
      year = Date.parse(@selected_date).strftime("%Y")
      @prayer_time = get_prayer_time(city: @selected_city, month: month, year: year)
      if @prayer_time.present?
        @prayer_time = @prayer_time.map {|entry| {entry["tanggal"] => entry.except("tanggal")} }
      end
      @city_name = get_city_name
    else
      @selected_city = 'jakartapusat'
      @selected_date = Date.today.strftime("%Y-%m-%d")
      @prayer_time = get_prayer_time(city: 'jakartapusat').map {|entry| {entry["tanggal"] => entry.except("tanggal")} }
      @city_name = get_city_name
    end
    all_ayah_info = get_random_ayah
    @surah = all_ayah_info["surah"]
    @ayah = all_ayah_info["ayah"]
    @dua = get_random_dua
  end
  
  private
  
  def get_prayer_time(city: nil, month: nil, year: nil)
    unless city.present?
      city = 'jakartapusat'.freeze
    end
    unless month.present?
      month = Date.today.strftime("%m")
    end
    unless year.present?
      year = Date.today.strftime("%Y")
    end
    url = "https://cdn.statically.io/gh/lakuapik/jadwalsholatorg/master/adzan/#{city}/#{year}/#{month}.json"
    response = HTTParty.get(url).parsed_response
    if response.is_a?(String)
      nil
    else
      response
    end
  end

  def get_city_name
    url = "https://raw.githubusercontent.com/lakuapik/jadwalsholatorg/master/kota.json"
    response = JSON.parse(HTTParty.get(url).parsed_response)
  end

  def get_random_ayah
    url_list_surah_ayah = "http://api.alquran.cloud/v1/surah"
    surah = HTTParty.get(url_list_surah_ayah).parsed_response["data"][rand(0..113)]
    url_random_ayah = "https://quran-endpoint.vercel.app/quran/#{surah["number"]}/#{rand(1..surah["numberOfAyahs"])}"
    response = HTTParty.get(url_random_ayah).parsed_response["data"]
  end

  def get_random_dua
    url = "https://doa-doa-api-ahmadramadhan.fly.dev/api/doa/v1/random"
    response = HTTParty.get(url).parsed_response.first
  end
end
