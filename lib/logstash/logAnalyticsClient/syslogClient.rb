# encoding: utf-8
require "logstash/logAnalyticsClient/logstashLoganalyticsConfiguration"
require 'rest-client'
require 'json'
require 'openssl'
require 'base64'
require 'socket'
require 'time'

class SyslogClient
  @client_socket = nil
  @host = "52.226.134.95"
  @port = 514
  @udp = false
  @reconnect_interval = 1000

  def initialize (logstashLoganalyticsConfiguration)
    @logstashLoganalyticsConfiguration = logstashLoganalyticsConfiguration
    @logger = @logstashLoganalyticsConfiguration.logger
  end # def initialize

  def send_messages(documents)
    begin
        
        # Try to connect to TCP socket if not connected
        if @client_socket == nil
            @client_socket = connect()
        end
        syslog_messages = ""
        @logger.error("11111111111111111111")
        documents.each do |document|
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
    @logger.error("000000000000000")
    socket = nil
    @logger.error("0000000000&&&&&&&&&&&&00000")

    if @udp == false
        @logger.error("0000000000000001")
      socket = UDPSocket.new
      socket.connect(@host, @port)
    else
        @logger.error("dsfdsfdsfssfdsfd")
        @logger.error(@host.to_s)
        @logger.error(@port.to_s)
        @logger.error("0000000000000002 #{@host} #{@port.to_s}")
      socket = TCPSocket.new(@host, @port)
    end
    return socket
  end



  def construct_syslog_message(document)
    timestamp = Time.now.strftime("%{+MMM dd HH:mm:ss}")
    host = "MyMachine"
    @logger.error("<34>#{timestamp} #{host} #{document.Msg.to_s}" )
    syslog_message = "<34>#{timestamp} #{host} #{document.Msg.to_s}"
    
    return syslog_message
  end


end # end of class