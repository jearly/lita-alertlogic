require 'json'

# Alertlogic Helper
module AlertlogicHelper
  # Incidents Helper
  module Incidents
    # rubocop:disable LineLength
    def get_incidents(customer_id, days)
      hours = days.to_i * 24
      incidents_url = "#{config.incident_api_url}/v3/incidents?customer_id=#{customer_id}&create_date=>#{(Time.now - (hours * 60 * 60)).to_i}"
      params = {
        customer_id: customer_id,
        url: incidents_url
      }
      resp = api_call(params)
      parse_json(resp)
    end
    # rubocop:enable MethodLength

    def incidents_notes(customer_id, incident_id)
      incidents_url = "#{config.incident_api_url}/v2/notes?customer_id=#{customer_id}&incident_id=#{incident_id}"
      params = {
        customer_id: customer_id,
        url: incidents_url
      }
      resp = api_call(params)
      parse_json(resp)
    end
  end
end
