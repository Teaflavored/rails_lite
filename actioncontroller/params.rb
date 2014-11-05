class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  #
  # You haven't done routing yet; but assume route params will be
  # passed in as a hash to `Params.new` as below:
  def initialize(req, route_params = {})
    @params = {}
    
    parse_www_encoded_form(req.query_string)
    parse_www_encoded_form(req.body)
    route_params.each do |key, value|
      @params[key] = value
    end
  end

  def [](key)
    @params[key.to_s]
  end

  def to_s
    @params.to_json.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }

  def parse_www_encoded_form(www_encoded_form)
    return if www_encoded_form.nil?
    pairs = URI.decode_www_form(www_encoded_form)

    pairs.each do |pair|
      parsed_keys = parse_key(pair.first)
      @params = @params.deep_merge(parsed_keys.reverse.inject(pair.last) { |h, a| { a => h } })
    end

  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end