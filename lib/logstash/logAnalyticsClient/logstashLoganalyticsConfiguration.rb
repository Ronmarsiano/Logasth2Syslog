# encoding: utf-8
class LogstashLoganalyticsOutputConfiguration
    def initialize(logger)
        @logger = logger

        @MIN_MESSAGE_AMOUNT = 100
        # Maximum of 30 MB per post to Log Analytics Data Collector API. 
        # This is a size limit for a single post. 
        # If the data from a single post that exceeds 30 MB, you should split it.
        @loganalytics_api_data_limit = 30 * 1000 * 1000

        # Taking 4K safety buffer
        @MAX_SIZE_BYTES = @loganalytics_api_data_limit - 10000
    end

    def validate_configuration()
        if @max_items < @MIN_MESSAGE_AMOUNT
            raise ArgumentError, "Setting max_items to value must be greater then #{@MIN_MESSAGE_AMOUNT}."

        @logger.info("Azure Loganalytics configuration was found valid.")
        
        # If all validation pass then configuration is valid 
        return  true
    end # def validate_configuration

    def destination_ip
        @destination_ip
    end
    
    def destination_port
        @destination_port
    end

    def MAX_SIZE_BYTES
        @MAX_SIZE_BYTES
    end

    def logger
        @logger
    end

    def time_generated_field
        @time_generated_field
    end

    def max_items
        @max_items
    end

    def plugin_flush_interval
        @plugin_flush_interval
    end

    def MIN_MESSAGE_AMOUNT
        @MIN_MESSAGE_AMOUNT
    end
    
    def max_items=(new_max_items)
        @max_items = new_max_items
    end

    def time_generated_field=(new_time_generated_field)
        @time_generated_field = new_time_generated_field
    end

    def plugin_flush_interval=(new_plugin_flush_interval)
        @plugin_flush_interval = new_plugin_flush_interval
    end

    def max_items=(new_max_items)
        @max_items = new_max_items
    end

    def destination_ip=(new_destination_ip)
        @destination_ip = new_destination_ip
    end

    def destination_port=(new_destination_port)
        @destination_port = new_destination_port
    end
end