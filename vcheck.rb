require 'net/http'
require 'uri'

FAILURE_THRESHOLD_COUNT             = 50
SUCCESS_IN_A_ROW_THRESHOLD_COUNT    = 5
WAIT_SECONDS                        = 30
CHECK_TEXT                          = ARGV[0]
CHECK_URL                           = ARGV[1]

class CompareVersion
  def self.run
    page_content.chomp == CHECK_TEXT.chomp
  end

  def self.page_content
    Net::HTTP.get(URI.parse(CHECK_URL)).to_s
  rescue
    puts 'Error accessing URL'
    ''
  end
end

class VersionChecker
  def initialize
    @successful = 0
    @failure    = 0
  end

  def run
    FAILURE_THRESHOLD_COUNT.times do |i|
      puts "Checking for new version (#{i + 1}/#{FAILURE_THRESHOLD_COUNT})"
      return hard_success if check_success
      CompareVersion.run ? success! : failure!
      sleep WAIT_SECONDS
    end
    hard_failure
  end

  private

  def success!
    puts 'New version found'
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
    puts 'New version is live!'
  end
end

VersionChecker.new.run
