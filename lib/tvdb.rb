require 'net/http'

module TVDB

  def tvdb_root
    'http://thetvdb.com'
  end

  def api_key
    '1EDB5D9DF99BA55D'
  end

  def api_root
    tvdb_root + '/api/' + api_key
  end

  def tvdb_query_series_all(series)
    uri = URI(api_root + '/series/' + series.to_s + '/all/' + 'en.xml')
    logger.debug uri
    Hash.from_xml(Net::HTTP.get(uri))
  end

end