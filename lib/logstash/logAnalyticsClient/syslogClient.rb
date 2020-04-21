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
            @logger.error("000000000000000")
            syslog_messages = syslog_messages + construct_syslog_message(documents) + "\n"
        end
        @logger.error("222222222222222222222222")
        @client_socket.write(syslog_messages)
        @logger.error("33333333333333333333333")
    rescue => e
        @logger.error("syslog " + @protocol + " output exception: closing, reconnecting and resending event", :host => @host, :port => @port, :exception => e, :backtrace => e.backtrace)
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
    end
    return socket
  end



  def construct_syslog_message(document)
    timestamp = Time.now.strftime("%{+MMM dd HH:mm:ss}")
    host = "MyMachine"
    @logger.error("!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    @logger.error(timestamp.to_s)
    @logger.error(host.to_s)
    @logger.error(document.to_s)
    @logger.error(document.get("MSG"))

    @logger.error("!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    
    syslog_message = "<34>#{timestamp} #{host} #{document.get("MSG").to_s}"
    
    @logger.error("Done construct")
    return syslog_message
  end


end # end of class