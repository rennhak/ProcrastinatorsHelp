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
    @dtn = DateTime.now
    @hour, @min = @dtn.hour, @dtn.min

    @now            = Time.local( DateTime.now.year, DateTime.now.month, DateTime.now.day, Time.now.hour, Time.now.min, Time.now.sec)
    @workBeginTime  = Time.local( DateTime.now.year, DateTime.now.month, DateTime.now.day, wts_hour, wts_min, Time.now.sec)
    @workEndTime    = Time.local( DateTime.now.year, DateTime.now.month, DateTime.now.day, wte_hour, wte_min, Time.now.sec)

  end # of def initialize }}}


  # = The function work? determines if it is *now* worktime or playtime according to the default settings
  # @type Helper function
  # @returns True, if its worktime or false if not
  def work? # {{{
    # 10:00 --> -1
    # 10:30 --> 0
    # 10:31 --> 1
    # 19:00 --> 1
    # 20:00 --> 1
    # 20:01 --> 1
    # 00:00 --> -1
    # p (@now <=> @workBeginTime)

    # 10:00 --> -1
    # 10:30 --> -1
    # 10:31 --> -1
    # 19:00 --> -1
    # 20:00 --> 0
    # 20:01 --> 1
    # 00:00 --> -1
    # p (@now <=> @workEndTime)

    if( ( ( @now <=> @workBeginTime ) == 1) and ( ( @now <=> @workEndTime ) == -1 ) )
      true
    else
      false
    end
  end # of def work? }}}

  # = workHostsInPlace? determines if the /etc/hosts file is the 'work' template or not
  # @type Helper function
  # @returns True, if it is or false if not
  def workHostsInPlace? # {{{
    result = `diff -q /etc/hosts /etc/hosts.block`
    if( result.length == 0 )
      true
    else
      false
    end
  end # of def workHostsInPlace? }}}

  # = switchHostsToWork! does exactly as the name implies, switching of whatever is in place currently to work mode
  # @type Helper function
  def switchHostsToWork! # {{{
    `sudo cp -v /etc/hosts.block /etc/hosts`
  end # of def switchHostsToWork! }}}

  # = switchHostsToPlay! does exactly as the name implies, switching of whatever is in place currently to play mode
  # @type Helper function
  def switchHostsToPlay! # {{{
    `sudo cp -v /etc/hosts.original /etc/hosts`
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

