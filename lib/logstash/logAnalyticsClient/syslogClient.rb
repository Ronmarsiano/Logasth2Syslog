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
    @client_socket = nil
    @udp = false
    @reconnect_interval = 1000
  end # def initialize

  def send_messages(events)
    begin
        # Try to connect to TCP socket if not connected
        if @client_socket == nil
            @logger.info("trying to connect the socket")
            @client_socket = connect()
        end
        syslog_messages = ""
        message_counter = 0
        events.each do |single_syslog_message|
            syslog_messages = syslog_messages.concat(single_syslog_message).concat("\n")
            message_counter = message_counter + 1
        end
        @client_socket.write(syslog_messages)
        @logger.info("Messages(#{message_counter}) sent.")
    rescue => e
        # @logger.error("syslog " + @protocol + " output exception: closing, reconnecting and resending event", :host => @host, :port => @port, :exception => e, :backtrace => e.backtrace)
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
      socket.connect(@destination_ip, @destination_port)
    else
        socket = TCPSocket.new(@destination_ip, @destination_port)
        # Setting a keep alive on the socket 
        socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, true)
        return socket
    end
    return socket
  end
end # end of class