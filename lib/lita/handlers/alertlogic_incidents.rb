require 'lita'
# Lita Module
module Lita
  # Plugin type Handler
  module Handlers
    # Alert Logic Incident routes
    class AlertlogicIncidents < Handler
      config :api_auth
      config :lm_api_url
      config :tm_api_url
      config :customer_api_url
      config :incident_api_url
      config :customer_id
      config :http_options, required: false, type: Hash, default: {}

      namespace 'Alertlogic'

      include ::AlertlogicHelper::Api
      include ::AlertlogicHelper::Common
      include ::AlertlogicHelper::Customer
      include ::AlertlogicHelper::Incidents

      # Route definitions
      # Incidents list route
      route(
        /a(?:lertlogic)? incidents? (.+)? (.+)?/i,
        :incidents_list,
        help: {
          t('help.incidents.syntax') => t('help.incidents.desc')
        }
      )

      # Incident notes route
      route(
      /a(?:lertlogic)? incidentnotes? (.+)? (.+)?/i,
        :list_notes,
        help: {
          t('help.incident_notes.syntax') => t('help.incident_notes.desc')
        }
      )

      # Customer Info Definition
      def incidents_list(response)
        customer_id = response.match_data[1]
        days     = response.match_data[2]
        return response.reply(t('validation.customer_id')) if customer_id.nil?
        incidents = get_incidents(customer_id, days)
        return response.reply(t('response.no_incidents', customer: customer_id)) if incidents.empty?
        response.reply "/code #{JSON.pretty_generate(incidents)}"
      end

      def list_notes(response)
        customer_id = response.match_data[1]
        incident_id = response.match_data[2]
        return response.reply(t('validation.customer_id')) if customer_id.nil?
        return response.reply(t('validation.incident_id')) if incident_id.nil?
        notes = JSON.pretty_generate(incidents_notes(customer_id, incident_id))
        response.reply "/code #{notes}"
      end
    end
    Lita.register_handler(AlertlogicIncidents)
  end
end
