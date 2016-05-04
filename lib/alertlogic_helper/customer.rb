# Alertlogic Helper
module AlertlogicHelper
  # Customer Helper
  module Customer
    def find_cid_by_name(customer_name)
      customer_ids = []
      customer_list = all_customers
      customer_list['child_chain'].each do |customer|
        if customer['customer_name'].downcase.include? customer_name.downcase
          customer_ids << customer['customer_id']
        end
      end
      customer_ids
    end

    def get_customer_ids(parent)
      params = api_params(parent, 'customer')
      resp = api_call(params)
      cids = []
      return t('error.customer_not_found') if parse_json(resp)['error']
      parse_json(resp)['child_chain'].each do |customer|
        cids << customer['customer_id'].to_i
      end
      cids
    end

    def all_customers
      params = {
        customer_id: config.customer_id,
        type: 'customer'
      }
      resp = api_call(params)
      parse_json(resp)
    end

    def process_customer_id(customer)
      if /\A[-+]?\d+\z/ =~ customer
        return customer.to_i
      else
        return find_cid_by_name(customer)
      end
    end

    def valid_cid(customer_id)
      customer_id.to_i if /\A[-+]?\d+\z/ =~ customer_id.strip
    end

    def process_customers(customer_list)
      reply_text = '/code '
      headers = ['Customer ID', 'Customer Name']
      if customer_array?(customer_list)
        customers = parse_customer_list(customer_list)
        reply_text << build_table(customers, headers)
      else
        return t('error.customer_not_found') if parse_json(customer_list)['error']
        customers = parse_child_chain(customer_list)
        reply_text << build_table(customers, headers)
      end
    end

    def customer_array?(customer_list)
      customer_list.is_a? Array
    end

    def parse_customer_list(customer_list)
      data = []
      customer_list.each do |customer|
        cust = parse_json(customer)
        data << [
          "#{cust['customer_id']}",
          cust['customer_name']
        ]
      end
      data
    end

    def parse_child_chain(customer_list)
      data = []
      parse_json(customer_list)['child_chain'].each do |customer|
        data << [
          "#{customer['customer_id']}",
          customer['customer_name']
        ]
      end
      data
    end
  end
end
