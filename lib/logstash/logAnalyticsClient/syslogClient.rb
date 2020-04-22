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
    @host = "52.226.134.95"
    @port = 514
    @client_socket = nil
    @udp = false
    @reconnect_interval = 1000
  end # def initialize

  def send_messages(documents)
    begin
        
        # Try to connect to TCP socket if not connected
        if @client_socket == nil
            @client_socket = connect()
        end
        syslog_messages = ""
        documents.each do |document|
            single_syslog_message = construct_syslog_message(document)
            @logger.error("Message to be sent: \n\n #{single_syslog_message}")
            @client_socket.write(single_syslog_message)
            @logger.error("Message was sent.")
            # syslog_messages = syslog_messages + construct_syslog_message(document) + "\n"
        end
        # @client_socket.write(syslog_messages)
        @logger.error(@host.to_s)
        @logger.error(@port.to_s)
        @logger.error("Done")
    rescue => e
        @logger.error("syslog " + @protocol + " output exception: closing, reconnecting and resending event", :host => @host, :port => @port, :exception => e, :backtrace => e.backtrace)
        @logger.error("Failed to send message")
        @client_socket.close rescue nil
        @client_socket = nil
        sleep(@reconnect_interval)
        # Retrying after reconnect interval
        send_messages(documents)
    end
  end # def send_messages


  def connect()
    if @udp == true
      socket = UDPSocket.new
      socket.connect(@host, @port)
    else
      @logger.error(@host.to_s)
      @logger.error(@port.to_s)
      socket = TCPSocket.new(@host, @port)
      socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, true)
      socket.setsockopt(Socket::SOL_TCP, Socket::TCP_KEEPIDLE, 50)
      socket.setsockopt(Socket::SOL_TCP, Socket::TCP_KEEPINTVL, 10)
      socket.setsockopt(Socket::SOL_TCP, Socket::TCP_KEEPCNT, 5)
    end
    return socket
  end



  def construct_syslog_message(event)
    timestamp = Time.now.strftime("%b %e %H:%M:%S")
    @logger.error("Timestamp: #{timestamp}\n\n")
    host = "MyMachine"
    # Here we construct the message from the tokens we have 
    syslog_message = "<34> #{timestamp} #{host} CEF:0|#{event.get("MSG").to_s}"

    return syslog_message
  end


end # end of class