# Commands:
#   hubot greet on <channel> with <message> - add greeting
#   hubot stop greeting on <channel> - remove greeting
#   hubot greetings - list greetings

module.exports = (robot) ->
  robot.brain.data.greetings = {} if not robot.brain.data.greetings
  check_user = (user,msg) ->
    if robot.auth.hasRole(user,'greeter') || robot.auth.isAdmin(user)
      return true
    else
      msg.reply "Sorry, only admins and greeters can do this."
      return false

  clear_room_name = (room) ->
    room.trim()
    if room[0]=='#'
      room = room[1..]

    return room


  robot.respond /greet +on +([^ ]+) +with +(.+)/i, (msg) ->
    unless check_user(msg.envelope.user)
      return

    room = clear_room_name(msg.match[1])

    robot.brain.data.greetings[room] = msg.match[2]
    msg.reply('roger that')
    return

  robot.respond /stop greeting on ([^ ]+)/i, (msg) ->
    unless check_user(msg.envelope.user)
      return

    room = clear_room_name(msg.match[1])
    if robot.brain.data.greetings[room]
      delete robot.brain.data.greetings[room]

    msg.reply('roger that')
    return

  robot.respond /greetings/i,(msg) ->
    unless check_user(msg.envelope.user)
      return

    reply = "\n"
    if robot.brain.data.greetings.length > 0
      for own channel, greeting of robot.brain.data.greetings
        reply += "#{channel} : \"#{greeting}\"\n"
    else
      reply = "I don`t know no greetings!"

    msg.reply(reply)
    return

  robot.respond /whoami/i,(msg) ->
    msg.reply(msg.envelope.user.id)
    return


  robot.enter (msg) ->
    room = msg.message.room
    user = robot.brain.userForId msg.envelope.user.id
    user.room = user.name

    if robot.brain.data.greetings[room] != undefined
      robot.send(user, robot.brain.data.greetings[room])

    return


