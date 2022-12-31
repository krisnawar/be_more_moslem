require 'httparty'

class HomesController < ApplicationController  
  include HTTParty

  def index
    @selected_city = nil
    if params[:city].present?
      @selected_city = params[:city]
      @prayer_time = get_prayer_time(city: @selected_city).map {|entry| {entry["tanggal"] => entry.except("tanggal")} }
      @city_name = get_city_name
      @city_name.delete(@selected_city)
    else
      @prayer_time = get_prayer_time(city: 'jakartapusat').map {|entry| {entry["tanggal"] => entry.except("tanggal")} }
      @city_name = get_city_name
    end
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
  end

  def get_city_name
    url = "https://raw.githubusercontent.com/lakuapik/jadwalsholatorg/master/kota.json"
    response = JSON.parse(HTTParty.get(url).parsed_response)
  end
end
