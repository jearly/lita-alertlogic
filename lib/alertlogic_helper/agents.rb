# Alertlogic Helper
module AlertlogicHelper
  # Agents Helper
  module Agents
    def agent_appliance_summary(customer_id)
      reply   = "/code Appliance/Agents counts for customer: #{customer_id} \n"
      params = api_params(customer_id, 'monitoring', 'tmc-appliances')
      data = agent_appliance_assignment(parse_json(api_call(params)))
      reply << build_table(data, agent_assignment_headers)
    end

    def agent_appliance_assignment(assignment_info)
      data    = []
      assignment_info['sources'].each do |source|
        data << [
          source['source']['name'],
          source['source']['metadata']['local_ipv4'],
          source['source']['agents_count'],
          source['source']['status']['status']
        ]
      end
      data
    end

    def agent_assignment_headers
      [
        'Appliance Name',
        'Appliance IP',
        'Agents Count',
        'Overall Collection Status'
      ]
    end

    def agent_policy_summary(customer_id)
      reply   = "/code Policy/Agents counts for customer: #{customer_id} \n"
      params = api_params(customer_id, 'tm', 'policies')
      policies_list = parse_json(api_call(params))['policies']
      policies = process_agent_policies(policies_list, customer_id)
      reply << build_table(policies, agent_policy_headers)
    end

    def process_agent_policies(policies, customer_id)
      data = []
      policies.each do |policy|
        base_url = construct_api_url(customer_id, 'tm', 'protectedhosts')
        url = "#{base_url}?appliance.policy.id=#{policy['policy']['id']}"
        params = { customer_id: customer_id, url: url }
        agents_count = parse_json(api_call(params))['total_count']
        data << [policy['policy']['name'], policy['policy']['id'], agents_count]
      end
      data
    end

    def agent_policy_headers
      ['Policy Name',
        'Policy ID',
        'Agents Count'
      ]
    end

    def agent_ip_summary(customer_id)
      reply    = "/code Agents/IP summary for customer: #{customer_id} \n"
      params   = api_params(customer_id, 'tm', 'protectedhosts')
      ip_count = process_agent_ips(parse_json(api_call(params))['protectedhosts'])
      counts = count_agent_ips(ip_count)
      reply << build_table(counts, agent_ip_summary_headers)
    end

    def process_agent_ips(agents)
      ip_count = []
      agents.each do |agent|
        ip_count << agent['protectedhost']['metadata']['local_ipv4'].length if agent['protectedhost']['metadata']
      end
      ip_count
    end

    def count_agent_ips(ip_count)
      data = []
      summary = Hash.new 0
      ip_count.each do |count|
        summary[count] += 1
      end
      summary.each do |agents_list, count|
        data << [agents_list, count]
      end
      data
    end

    def agent_ip_summary_headers
      [
        'IP Count/Agent',
        'Agents Count'
      ]
    end
  end
end
