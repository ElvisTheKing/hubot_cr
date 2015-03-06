# Commands:
#   hubot pages - show all pages
#   hubot set page <name> <content> - set page content, page name can contain only latin letters
#   hubot <name> - get page

module.exports = (robot) ->
  robot.brain.data.pages = {} if not robot.brain.data.pages

  check_user = (user,msg) ->
    if robot.auth.isAdmin(user)
      return true
    else
      msg.reply "Sorry, only admins can do this."
      return false

  robot.respond /pages/i, (msg) ->
    r = Object.keys(robot.brain.data.pages).join(', ')
    msg.send(r)
    return

  robot.respond /set page ([a-z]+) ([\s\S]+)/i, (msg) ->
    unless check_user(msg.envelope.user, msg)
      return

    robot.brain.data.pages[msg.match[1].toLowerCase()]=msg.match[2]
    msg.reply('roger that')
    return

  robot.respond /([a-z]+)/i, (msg) ->
    name = msg.match[1].toLowerCase()
    if robot.brain.data.pages[name] != undefined
      msg.send(robot.brain.data.pages[name])
    return

