#!/usr/bin/ruby
#

# (c) Bjoern Rennhak, 2010
#
# This script switches the /etc/hosts file to "choosemode". That means it checks the time and
# depending on it, either work etc/hosts or play etc/hosts is allowed.
#

require 'date'

class Mode

  # wts == workTimeStart ; wte == workTimeEnd
  def initialize wts_hour = 10, wts_min = 30, wte_hour = 20, wte_min = 00
    @dtn = DateTime.now
    @hour, @min = @dtn.hour, @dtn.min
  
    @now            = Time.local( DateTime.now.year, DateTime.now.month, DateTime.now.day, Time.now.hour, Time.now.min, Time.now.sec)
    @workBeginTime  = Time.local( DateTime.now.year, DateTime.now.month, DateTime.now.day, wts_hour, wts_min, Time.now.sec)
    @workEndTime    = Time.local( DateTime.now.year, DateTime.now.month, DateTime.now.day, wte_hour, wte_min, Time.now.sec)

  end # of def initialize

  # Returns true if its worktime or false if not
  def work?
  
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
  end # of def work?

  def workHostsInPlace?
    result = `diff -q /etc/hosts /etc/hosts.block`
    if( result.length == 0 )
      true
    else
      false
    end
  end

  def switchHostsToWork!
    `sudo cp -v /etc/hosts.block /etc/hosts`
  end

  def switchHostsToPlay!
    `sudo cp -v /etc/hosts.original /etc/hosts`
  end

  def check
    if( work? )
      switchHostsToWork! unless( workHostsInPlace? )
    else
      switchHostsToPlay! if( workHostsInPlace? )
    end
  end

end # of class mode

# If it is directly invoked make sure the user gets a blame!
if __FILE__ == $0
  m = Mode.new.check
end # of __FILE__ == $0


