# Alertlogic Helper
module AlertlogicHelper
  # Appliances Helper
  module Appliances
    def process_appliances(appliance_list, customer_id)
      reply   = "/code Customer appliances for ID: #{customer_id} \n"
      appliance_data = construct_appliance_info(appliance_list)
      count = parse_json(appliance_list)['total_count']
      reply << build_table(appliance_data, appliance_headers)
      reply << "Total Appliances: #{count}\n"
      reply
    end

    def construct_appliance_info(appliance_list)
      data = []
      parse_json(appliance_list)['appliances'].each do |appliance|
        appliance.each do |type, details|
          data << [type, details['id'], details['name'], details['status']['status']]
        end
      end
      data
    end

    def appliance_headers
      ['Appliance Type', 'UUID', 'Name', 'Status']
    end
  end
end
