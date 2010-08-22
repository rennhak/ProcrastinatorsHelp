#!/usr/bin/ruby
#

###
#
# (c) Bjoern Rennhak, 2010
#
# This script switches the /etc/hosts file to "choosemode". That means it checks the time and
# depending on it, either work etc/hosts or play etc/hosts is allowed.
#
########

# = Libraries
require 'date'
require 'optparse'


# = Mode is a abstract class to control if you are currently supposed to work or you can relax
class Mode # {{{

  # = Initialize is the custom constructor of the Mode class, which sets up the time settings when work and play are ok
  # @params wts workTimeStart
  # @params wte workTimeEnd
  def initialize options, wts_hour = 10, wts_min = 30, wte_hour = 20, wte_min = 00 # {{{
    @options        = options

    # Set the hosts variable where to find the various files
    @hosts, @hosts_original, @hosts_block = "/etc/hosts", "/etc/hosts.original", "/etc/hosts.block"

    # Set the time and when the work time begins and ends
    @dtn            = DateTime.now
    @hour, @min     = @dtn.hour, @dtn.min

    @now            = Time.local( DateTime.now.year, DateTime.now.month, DateTime.now.day, Time.now.hour, Time.now.min, Time.now.sec )
    @workBeginTime  = Time.local( DateTime.now.year, DateTime.now.month, DateTime.now.day, wts_hour,      wts_min,      Time.now.sec )
    @workEndTime    = Time.local( DateTime.now.year, DateTime.now.month, DateTime.now.day, wte_hour,      wte_min,      Time.now.sec )

    # Control flow
    ( switchHostsToWork! unless( workHostsInPlace? )  ) if( @options[ :work ] )
    ( switchHostsToPlay! if( workHostsInPlace? )      ) if( @options[ :play ] )

    time?   if( @options[ :time       ] )
    check!  if( @options[ :automatic  ] )
    ntp!    if( @options[ :ntp        ] )

  end # of def initialize }}}


  # = time? displays the time when the work hosts is active
  def time? # {{{
    puts "The current time when '#{@hosts_block}' is active is from '#{@workBeginTime.to_s}' to '#{@workEndTime}' according to your current time."
  end # of def time? }}}


  # = The function work? determines if it is *now* worktime or playtime according to the default settings
  # @type Helper function
  # @returns True, if its worktime or false if not
  def work? # {{{
    # p (@now <=> @workBeginTime)
    # 10:00, 00:00                        --> -1
    # 10:30                               --> 0
    # 10:31, 19:00, 20:00, 20:01          --> 1

    # p (@now <=> @workEndTime)
    # 10:00, 10:30, 10:31, 19:00, 00:00   --> -1
    # 20:00                               --> 0
    # 20:01                               --> 1

    ( ( ( @now <=> @workBeginTime ) == 1) and ( ( @now <=> @workEndTime ) == -1 ) ) ? ( true ) : ( false )
  end # of def work? }}}


  # = workHostsInPlace? determines if the /etc/hosts file is the 'work' template or not
  # @type Helper function
  # @returns True, if it is or false if not
  def workHostsInPlace? # {{{
    result = `diff -q #{@hosts} #{@hosts_block}`
    ( result.length == 0 ) ? ( true ) : ( false )
  end # of def workHostsInPlace? }}}

  # = switchHostsToWork! does exactly as the name implies, switching of whatever is in place currently to work mode
  # @type Helper function
  def switchHostsToWork! # {{{
    `sudo cp -v #{@hosts_block} #{@hosts}`
  end # of def switchHostsToWork! }}}

  # = switchHostsToPlay! does exactly as the name implies, switching of whatever is in place currently to play mode
  # @type Helper function
  def switchHostsToPlay! # {{{
    `sudo cp -v #{@hosts_original} #{@hosts}`
  end # of def switchHostsToPlay! }}}

  # = check! determines if we actually are currently in work time or not and sets the hosts file accordingly.
  # @helpers work?, switchHostsToPlay!, switchHostsToWork!, workHostsInPlace?
  def check! # {{{
    if( work? )
      switchHostsToWork! unless( workHostsInPlace? )
    else
      switchHostsToPlay! if( workHostsInPlace? )
    end
  end # of def check! }}}

  # = ntp! calls the ntp client to reset the system clock to the correct time
  def ntp!
    # FIXME write a more clever way to retrieve country specific ntp servers
    ntp_server = %w[0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org]
    `sudo ntpdate #{ntp_server[rand(ntp_server.length - 1)]}`
  end
end # of class mode }}}


# = Direct Invocation
if __FILE__ == $0 # {{{

  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: check_work_time_hosts.rb [options]"

    opts.on("-w", "--work", "Set the work time hosts file") do |w|
      options[:work]   = w
    end

    opts.on("-p", "--play", "Set the play time hosts file") do |p|
      options[:play]   = p
    end

    opts.on("-t", "--time", "Display time frame when work hosts file is active") do |t|
      options[:time]   = t
    end

    opts.on("-a", "--automatic", "Set the work or play time hosts file according to current time automatically") do |a|
      options[:automatic]   = a
    end

    opts.on("-n", "--ntp", "Set the system clock via NTP service") do |n|
      options[:ntp]   = n
    end

  end.parse!


  if( options.empty? )
    raise ArgumentError, "Please try '-h' or '--help' to view all possible options"
  end

  mode    = Mode.new( options )

end # of __FILE__ == $0 }}}


