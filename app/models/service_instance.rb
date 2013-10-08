class ServiceInstance < BaseModel
  attr_accessor :id

  DATABASE_PREFIX = 'cf_'.freeze

  def self.find_by_id(id)
    instance = new(id: id)
    instance if connection.select("SHOW DATABASES LIKE '#{instance.database}'").any?
  end

  def self.find(id)
    find_by_id(id) || raise("Couldn't find ServiceInstance with id=#{id}")
  end

  def self.exists?(id)
    find_by_id(id).present?
  end

  def database
    @database ||= begin
                    # MySQL database names are limited to [0-9,a-z,A-Z$_] and 64 chars
      if id =~ /[^0-9,a-z,A-Z$-]+/
        raise 'Only ids matching [0-9,a-z,A-Z$-]+ are allowed'
      end

      database = id.gsub('-', '_')

      "#{DATABASE_PREFIX}#{database}"
    end
  end

  def save
    connection.execute("CREATE DATABASE `#{database}`")
  end

  def destroy
    connection.execute("DROP DATABASE IF EXISTS `#{database}`")
  end

  def to_json(*)
    {
      'dashboard_url' => 'http://fake.dashboard.url'
    }.to_json
  end
end