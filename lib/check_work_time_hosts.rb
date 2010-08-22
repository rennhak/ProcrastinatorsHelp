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


# = Mode is a abstract class to control if you are currently supposed to work or you can relax
class Mode # {{{

  # = Initialize is the custom constructor of the Mode class, which sets up the time settings when work and play are ok
  # @params wts workTimeStart
  # @params wte workTimeEnd
  def initialize wts_hour = 10, wts_min = 30, wte_hour = 20, wte_min = 00 # {{{
    # Set the hosts variable where to find the various files
    @hosts, @hosts_original, @hosts_block = "/etc/hosts", "/etc/hosts.original", "/etc/hosts.block"

    # Set the time and when the work time begins and ends
    @dtn            = DateTime.now
    @hour, @min     = @dtn.hour, @dtn.min

    @now            = Time.local( DateTime.now.year, DateTime.now.month, DateTime.now.day, Time.now.hour, Time.now.min, Time.now.sec )
    @workBeginTime  = Time.local( DateTime.now.year, DateTime.now.month, DateTime.now.day, wts_hour,      wts_min,      Time.now.sec )
    @workEndTime    = Time.local( DateTime.now.year, DateTime.now.month, DateTime.now.day, wte_hour,      wte_min,      Time.now.sec )
  end # of def initialize }}}


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

  # = check determines if we actually are currently in work time or not and sets the hosts file accordingly.
  # @helpers work?, switchHostsToPlay!, switchHostsToWork!, workHostsInPlace?
  def check # {{{
    if( work? )
      switchHostsToWork! unless( workHostsInPlace? )
    else
      switchHostsToPlay! if( workHostsInPlace? )
    end
  end # of def check }}}

end # of class mode }}}


# TODO: If it is directly invoked make sure the user gets a blame!
if __FILE__ == $0 # {{{

  m = Mode.new.check

end # of __FILE__ == $0 }}}


