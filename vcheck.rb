require 'net/http'
require 'uri'
require 'logger'

SUCCESS_IN_A_ROW_THRESHOLD_COUNT    = ENV['SUCCESS_THRESHOLD'] || 5
FAILURE_THRESHOLD_COUNT             = ENV['FAILURE_THRESHOLD'] || 50
WAIT_SECONDS                        = ENV['WAIT_SECONDS'] || 30
CHECK_TEXT                          = ENV['VERSION_TEXT']
CHECK_URL                           = ENV['URL']

class CompareVersion
  def self.run
    page_content.chomp == CHECK_TEXT.chomp
  end

  def self.page_content
    Net::HTTP.get(URI.parse(CHECK_URL)).to_s
  rescue
    SendToLog.call('Error accessing URL')
    ''
  end
end

class SendToLog
  def self.call(msg)
    Logger.new('/proc/1/fd/1').info(msg)
  end
end

class VersionChecker
  def initialize
    @successful = 0
    @failure    = 0
  end

  def run
    FAILURE_THRESHOLD_COUNT.times do |i|
      SendToLog.call("--------")
      SendToLog.call("(#{i + 1}/#{FAILURE_THRESHOLD_COUNT}) Checking for new version '#{CHECK_TEXT}'")
      return hard_success if check_success
      CompareVersion.run ? success! : failure!
      sleep WAIT_SECONDS
    end
    hard_failure
  end

  private

  def success!
    SendToLog.call('New version found')
    @successful += 1
  end

  def failure!
    @failure += 1 && @successful = 0
  end

  def hard_failure
    raise 'New version not live! :('
  end

  def check_success
    SUCCESS_IN_A_ROW_THRESHOLD_COUNT == @successful
  end

  def hard_success
    SendToLog.call('New version is live!')
  end
end


class Bootup
  def self.run
    banner = "
░██╗░░░░░░░██╗███████╗██████╗░██████╗░███████╗██████╗░███╗░░██╗███████╗████████╗
░██║░░██╗░░██║██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗████╗░██║██╔════╝╚══██╔══╝
░╚██╗████╗██╔╝█████╗░░██████╦╝██████╦╝█████╗░░██████╔╝██╔██╗██║█████╗░░░░░██║░░░
░░████╔═████║░██╔══╝░░██╔══██╗██╔══██╗██╔══╝░░██╔══██╗██║╚████║██╔══╝░░░░░██║░░░
░░╚██╔╝░╚██╔╝░███████╗██████╦╝██████╦╝███████╗██║░░██║██║░╚███║███████╗░░░██║░░░
░░░╚═╝░░░╚═╝░░╚══════╝╚═════╝░╚═════╝░╚══════╝╚═╝░░╚═╝╚═╝░░╚══╝╚══════╝░░░╚═╝░░░
"

    SendToLog.call(banner)
    SendToLog.call("Loading version checker...")
    SendToLog.call("Checking #{CHECK_URL} for #{CHECK_TEXT}")
    SendToLog.call("Checking #{FAILURE_THRESHOLD_COUNT} times")
  end
end

raise 'Missing parameters' if CHECK_TEXT.nil? || CHECK_URL.nil?
Bootup.run
VersionChecker.new.run
