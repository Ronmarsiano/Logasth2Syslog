# encoding: utf-8
require "logstash/logAnalyticsClient/logstashLoganalyticsConfiguration"
require 'rest-client'
require 'json'
require 'openssl'
require 'base64'
require 'time'

class SyslogClient
  @client_socket = nil
  @host = "52.226.134.95"
  @port = 514
  @udp = false
  @reconnect_interval = 1000

  def initialize (logstashLoganalyticsConfiguration)
    
  end # def initialize

  def send_messages(documents)
    begin
        # Try to connect to TCP socket if not connected
        @client_socket ||= connect
        syslog_messages = ""
        documents.each do |document|
            syslog_messages = syslog_messages + construct_syslog_message(documents) + "\n"
        end
        @client_socket.write(syslog_messages)
    rescue => e
        @logger.warn("syslog " + @protocol + " output exception: closing, reconnecting and resending event", :host => @host, :port => @port, :exception => e, :backtrace => e.backtrace)
        @client_socket.close rescue nil
        @client_socket = nil
        sleep(@reconnect_interval)
        # Retrying after reconnect interval
        send_messages(documents)
    end
  end # def send_messages


  def connect
    socket = nil
    if udp?
      socket = UDPSocket.new
      socket.connect(@host, @port)
    else
      socket = TCPSocket.new(@host, @port)
    end
    socket
  end



  def construct_syslog_message(document)
    timestamp = Time.now.strftime("%{+MMM dd HH:mm:ss}")
    host = "MyMachine"
    @logger.error("<34>#{timestamp} #{host} #{document.to_s}" )
    syslog_message = "<34>#{timestamp} #{host} #{document.to_s}"
    
    return syslog_message
  end


end # end of class