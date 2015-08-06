DATA = {} if DATA is undefined

# there's a catch to implementing the resource depletion to be "just in time"
# which is that the resource cost needs to be perfectly divisible by the time
# it will take. Otherwise the resource will be in decimal placements which I
# haven't build the rest of the system to account for.
#
# for example: for example, if the required_construction is 200 then the costs
# must be in units of 200. (200, 400, 600 ...) otherwise the cost will be 0.5
# when the construction progress ticks, making the resource something like: 10.5

DATA['buildings'] =
  cabin:
    capacity: 1
    required_construction: 200
    costs:
      lumber: 200
  'comedy-inn':
    capacity: 0
    required_construction: 500
    costs:
      lumber: 500
