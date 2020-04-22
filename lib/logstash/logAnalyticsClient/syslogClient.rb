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
        events.each do |event|
            @logger.info("Creating syslog message from input")
            single_syslog_message = event
            @logger.info("Syslog message created")
            syslog_messages = "#{syslog_messages}#{single_syslog_message}\n"
            @logger.info("Syslog Message:\n#{syslog_messages}")
            message_counter = message_counter + 1
        end
        @logger.info("Trying to write syslog message to socket")
        @client_socket.write(syslog_messages)
        @logger.info("Syslog message was sent.\nContent:\n#{syslog_messages}")
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
        @logger.info("TCP socket")
        socket = TCPSocket.new(@destination_ip, @destination_port)
        @logger.info("TCP socket created and connected")
        # Setting a keep alive on the socket 
        socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, true)
        @logger.info("TCP socket set keep alive value")
        return socket
    end
    return socket
  end

  def construct_syslog_message(event)
    timestamp = Time.now.strftime("%b %e %H:%M:%S")
    host = "MyMachine"
    # Here we construct the message from the tokens we have 
    syslog_message = "<34>#{timestamp} #{host} #{event}"

    @logger.info("Message:\n\n#{syslog_message}\n\n")
    return syslog_message
  end

end # end of class