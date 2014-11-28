require 'net/http'

module TVDB

  def tvdb_root
    'http://thetvdb.com'
  end

  def api_key
    '1EDB5D9DF99BA55D'
  end

  def api_root
    tvdb_root + '/api/'
  end

  def api_keyed
    api_root + api_key
  end

  def tvdb_query_series_all(series)
    uri = URI(api_keyed + '/series/' + series.to_s + '/all/' + 'en.xml')
    logger.debug uri
    Hash.from_xml(Net::HTTP.get(uri))
  end

  def tvdb_search_series(series)
    uri = URI(api_root + "GetSeries.php?seriesname=#{series}")
    logger.debug uri
    Hash.from_xml(Net::HTTP.get(uri))
  end

  def get_banner_uri(location)
    return nil if location.nil?
    tvdb_root + '/banners/' + location
  end

end