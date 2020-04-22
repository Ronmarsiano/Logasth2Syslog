# encoding: utf-8
require "logstash/logAnalyticsClient/logstashLoganalyticsConfiguration"
require 'rest-client'
require 'json'
require 'openssl'
require 'base64'
require 'socket'
require 'time'

class SyslogClient

  def initialize (logstashLoganalyticsConfiguration)
    @logstashLoganalyticsConfiguration = logstashLoganalyticsConfiguration
    @logger = @logstashLoganalyticsConfiguration.logger
    @destination_ip = @logstashLoganalyticsConfiguration.destination_ip
    @destination_port = @logstashLoganalyticsConfiguration.destination_port
    @host = "52.226.134.95"
    @port = 514
    @client_socket = nil
    @udp = false
    @reconnect_interval = 1000
  end # def initialize

  def send_messages(events)
    begin
        # Try to connect to TCP socket if not connected
        if @client_socket == nil
            @client_socket = connect()
        end
        syslog_messages = ""
        message_counter = 0
        events.each do |document|
            single_syslog_message = construct_syslog_message(document)
            syslog_messages = "#{syslog_messages}#{single_syslog_message}\n"
            message_counter = message_counter + 1
        end
        @client_socket.write(syslog_messages)
        @logger.info("Messages(#{message_counter}) sent.")
    rescue => e
        @logger.error("syslog " + @protocol + " output exception: closing, reconnecting and resending event", :host => @host, :port => @port, :exception => e, :backtrace => e.backtrace)
        @client_socket.close rescue nil
        @client_socket = nil
        sleep(@reconnect_interval)
        # Retrying after reconnect interval
        send_messages(events)
    end
  end # def send_messages


  def connect()
    if @udp == true
      socket = UDPSocket.new
      socket.connect(@host, @port)
    else
        socket = TCPSocket.new(@host, @port)
        # Setting a keep alive on the socket 
        socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, true)
        return socket
    end
    return socket
  end

  def construct_syslog_message(event)
    timestamp = Time.now.strftime("%b %e %H:%M:%S")
    host = "MyMachine"
    @logger.error("******************************")
    @logger.error("This is the message:\n\n#{event.get("message").to_s}")

    @logger.error("***************111111111111***************")
    # Here we construct the message from the tokens we have 
    syslog_message = "<34> #{timestamp} #{host} CEF:0|#{event.get("MSG").to_s}"

    return syslog_message
  end

end # end of class