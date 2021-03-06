# encoding: utf-8
require "stud/buffer"
require "logstash/logAnalyticsClient/syslogClient"
require "logstash/logAnalyticsClient/logstashSyslogConfiguration"

# LogStashAutoResizeBuffer class setting a resizable buffer which is flushed periodically
# The buffer resize itself according to Azure Loganalytics  and configuration limitations
class LogStashAutoResizeBuffer
    include Stud::Buffer

    def initialize(logstashSyslogConfiguration)
        @logstashSyslogConfiguration = logstashSyslogConfiguration
        @logger = @logstashSyslogConfiguration.logger
        @client=SyslogClient::new(logstashSyslogConfiguration)
        buffer_initialize(
          :max_items => logstashSyslogConfiguration.max_items,
          :max_interval => logstashSyslogConfiguration.plugin_flush_interval,
          :logger => @logstashSyslogConfiguration.logger
        )
    end # initialize

    # Public methods
    public

    # Adding an event document into the buffer
    def add_single_event(single_event)
        buffer_receive(construct_syslog_message(single_event))
    end # def add_single_event

    def construct_syslog_message(event)
        timestamp = Time.now.strftime("%b %e %H:%M:%S")
        host = "MyMachine"
        # Here we construct the message from the tokens we have 
        syslog_message = "<34>#{timestamp} #{host} #{event}"

        return syslog_message
      end

    # Flushing all buffer content to Azure Loganalytics.
    # Called from Stud::Buffer#buffer_flush when there are events to flush
    def flush (events, close=false)
        # Skip in case there are no candidate documents to deliver
        if events.length < 1
            @logger.warn("No events in batch ")
            return
        end

        @client.send_messages(events)
    end # def flush
end # LogStashAutoResizeBuffer