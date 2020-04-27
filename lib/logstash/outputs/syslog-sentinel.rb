# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require "stud/buffer"
require "logstash/logAnalyticsClient/logStashAutoResizeBuffer"
require "logstash/logAnalyticsClient/logstashLoganalyticsConfiguration"
require "logstash/codecs/plain"

class LogStash::Outputs::AzureLogAnalytics < LogStash::Outputs::Base

  config_name "syslog-sentinel"
  
  # Stating that the output plugin will run in concurrent mode
  concurrency :shared

  # # Max number of items to buffer before flushing. Default 50.
  # config :flush_items, :validate => :number, :default => 50
  
  # Max number of seconds to wait between flushes. Default 5
  config :plugin_flush_interval, :validate => :number, :default => 5

  # This will trigger message amount resizing in a REST request to LA
  config :destination_ip, :validate => :string, :default => "52.226.134.95"

  # This will trigger message amount resizing in a REST request to LA
  config :destination_port, :validate => :number, :default => 514

  # message text to log. The new value can include `%{syslog-sentinel}` strings
  # to help you build a new value from other parts of the event.
  config :message, :validate => :string, :default => "%{message}"

  config :max_items, :validate => :number, :default => 2000

  public
  def register
    @logstash_configuration= build_logstash_configuration()
    # Validate configuration correctness 
    @logstash_configuration.validate_configuration()
    @logger.info("Logstash Azure Loganalytics output plugin configuration was found valid")

    # Initialize the logstash resizable buffer
    # This buffer will increase and decrease size according to the amount of messages inserted.
    # If the buffer reached the max amount of messages the amount will be increased until the limit
    @logstash_resizable_event_buffer=LogStashAutoResizeBuffer::new(@logstash_configuration)

    if @codec.instance_of? LogStash::Codecs::Plain
      if @codec.config["format"].nil?
        @codec = LogStash::Codecs::Plain.new({"format" => @message})
      end
    end

    @codec.on_event(&method(:publish))
  end # def register

  def multi_receive(events)
    events.each do |event|
      @codec.encode(event)
    end
  end # def multi_receive

  def publish(event, payload)
    # strip the message from special characters 
    stripped_message = payload.to_s.rstrip.gsub(/[\r][\n]/, "\n").gsub(/[\n]/, '\n')
    @logstash_resizable_event_buffer.add_single_event(stripped_message)
  end

  # Building the logstash object configuration from the output configuration provided by the user
  # Return LogstashLoganalyticsOutputConfiguration populated with the configuration values
  def build_logstash_configuration()
    logstash_configuration= LogstashLoganalyticsOutputConfiguration::new(@logger)    
    logstash_configuration.plugin_flush_interval = @plugin_flush_interval
    logstash_configuration.max_items = @max_items
    logstash_configuration.destination_ip = @destination_ip
    logstash_configuration.destination_port = @destination_port
    
    return logstash_configuration
  end # def build_logstash_configuration

end # class LogStash::Outputs::AzureLogAnalytics
