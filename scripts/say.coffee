# Commands:
#   hubot say <channel|username> <message> - send message to user or channel

module.exports = (robot) ->
  robot.respond /say ([^ ]+) ([\s\S]+)/i, (msg) ->
    if !robot.auth.isAdmin(msg.envelope.user)
      return

    target_name = msg.match[1]
    text = msg.match[2]


    if target = robot.adapter.client.getChannelByName(target_name) || target = robot.adapter.client.getGroupByName(target_name)
      target.send(text)
      return

    if user = robot.adapter.client.getUserByName(target_name)
      echo = ()->robot.adapter.client.getDMByName(user.name).send(text)

      if robot.adapter.client.getDMByName(user.name)!=undefined
        echo()
      else
        callback = (msg) ->
          if msg.type == 'im_created' && msg.user == user.id
            setTimeout echo, 1000
            robot.adapter.client.removeListener 'raw_message',callback

        robot.adapter.client.on 'raw_message', callback
        robot.adapter.client.openDM(user.id)

    return