# Commands:
#   hubot add group <name> [owned by <user>] [with descriptin <discription>]- add private
#   hubot remove group <name> - remove private
#   hubot groups - list private groups

module.exports = (robot) ->
  robot.brain.data.privates = {} if not robot.brain.data.privates
  check_user = (user,msg,room=false) ->
    if robot.auth.isAdmin(user)
      return true

    if room
      if robot.brain.data.privates[room] && user==robot.brain.data.privates[room].user
        return true
      else
        msg.reply "Sorry, only admins or owners can do this."
        return false

    msg.reply "Sorry, only admins or owners can do this."
    return false

  clear_room_name = (room) ->
    room.trim()
    if room[0]=='#'
      room = room[1..]

    return room


  robot.respond /add group ([^ ]+)([\s\S]*)$/i, (msg) ->
    room = clear_room_name(msg.match[1])
    username = null
    description = null

    if rest = msg.match[2]
      if matches = rest.match(/[:space:]*owned by ([^ ]+)/i)
        username = matches[1]
        if username != msg.envelope.user.name && !robot.auth.isAdmin(msg.envelope.user)
          msg.reply('only admin can add private with different owner')
          return

      if matches = rest.match(/[:space:]*with description ([\s\S]+)/i)
        description = matches[1]

    username = msg.envelope.user.name if !username

    if robot.brain.data.privates[room] && robot.brain.data.privates[room].owner != username && !robot.auth.isAdmin(msg.envelope.user)
      msg.reply('only admin and owner can overwrite private')
      return

    robot.brain.data.privates[room] = {owner: username, description: description}

    msg.reply("okee dokee")

  robot.respond /remove group ([^ ]+)/i, (msg) ->
    room = clear_room_name(msg.match[1])
    if !robot.brain.data.privates[room]
      msg.reply('you can`t destroy something that not exist')
      return

    if robot.brain.data.privates[room].owner != msg.envelope.user.name && !robot.auth.isAdmin(msg.envelope.user)
      msg.reply('only admin or owner can do that')
      return

    delete robot.brain.data.privates[room]
    msg.reply('done')
    return

  robot.respond /groups/i,(msg) ->
    reply = "\n"
    if Object.keys(robot.brain.data.privates).length > 0
      for own room, data of robot.brain.data.privates
        reply += "`#{room}` : @#{data.owner}\n"
        if data.description
          reply+="#{data.description}\n"

        reply+="\n"

    else
      reply = "I don`t know no private groups!"

    msg.reply(reply)
    return