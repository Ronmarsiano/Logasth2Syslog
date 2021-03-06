# encoding: utf-8
require "logstash/logAnalyticsClient/logstashSyslogConfiguration"
require 'socket'
require 'time'

class SyslogClient

  def initialize (logstashSyslogConfiguration)
    @logstashSyslogConfiguration = logstashSyslogConfiguration
    @logger = @logstashSyslogConfiguration.logger
    @client_socket = nil
    @reconnect_interval = 1000
  end # def initialize

  def send_messages(events)
    begin
        # Try to connect to TCP socket if not connected
        if @client_socket == nil
            @logger.info("trying to connect the socket")
            @client_socket = connect()
        end

        syslog_messages =""
        events.each do |single_syslog_message|
            syslog_messages = syslog_messages.concat(single_syslog_message).concat("\n")
        end

        @client_socket.write(syslog_messages)
        @logger.info("Messages(#{events.length.to_s}) sent.")
    rescue => e
        @logger.error("TCP connection was closed and will try to reopen.\nException:\n#{e.to_s}\n\n")
        @client_socket.close rescue nil
        @client_socket = nil
        sleep(@reconnect_interval)
        # Retrying after reconnect interval
        send_messages(events)
    end
  end # def send_messages


  def connect()
    if @logstashSyslogConfiguration.tcp_protocol == true
      socket = TCPSocket.new(@logstashSyslogConfiguration.destination_ip, @logstashSyslogConfiguration.destination_port)
      # Setting a keep alive on the socket 
      socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, true)
      return socket
    else
      socket = UDPSocket.new
      socket.connect(@logstashSyslogConfiguration.destination_ip, @logstashSyslogConfiguration.destination_port)
      return socket
    end
  end
end # end of class