# Alertlogic Helper
module AlertlogicHelper
  # Api Helper
  module Api
    def api_call(options = {})
      customer_id = options[:customer_id]
      type        = options[:type] || nil
      source      = options[:source] || nil
      url         = options[:url] || nil
      # Construct URL if url not provided
      url = construct_api_url(customer_id, type, source) if url.nil?
      send_request(url)
    end

    def send_request(url)
      http_resp = http(config.http_options).get(url) do |req|
        req.headers  = headers
        req.options.timeout = 90
      end
      http_resp.body.to_s
    end

    # rubocop:disable MethodLength
    def construct_api_url(cid, type, source = nil)
      case type
      when 'customer'
        "#{config.customer_api_url}/#{cid}"
      when 'monitoring'
        "#{config.monitoring_api_url}/#{source}/#{cid}"
      when 'lm'
        "#{config.lm_api_url}/#{cid}/#{source}"
      when 'tm'
        "#{config.tm_api_url}/#{cid}//#{source}"
      else
        t('error.generic')
      end
    end
    # rubocop:enable MethodLength

    def headers
      {}.tap do |headers|
        headers['Authorization'] = "Basic #{Base64.encode64(config.api_auth).chomp.gsub(/\n/, '')}" if config.api_auth
        headers['Content-Type']  = 'application/json'
        headers['Accept']        = 'application/json'
      end
    end
  end
end
