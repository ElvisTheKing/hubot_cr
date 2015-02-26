# Commands:
#   hubot rules - show rules
#   hubot set rules <rules> - set rules

module.exports = (robot) ->
  robot.brain.data.rules = "" if not robot.brain.data.rules
  check_user = (user,msg) ->
    if robot.auth.isAdmin(user)
      return true
    else
      msg.reply "Sorry, only admins can do this."
      return false

  robot.respond /rules/i, (msg) ->
    msg.reply(robot.brain.data.rules)
    return

  robot.respond /set rules ([\s\S]+)/i, (msg) ->
    unless check_user(msg.envelope.user, msg)
      return

    robot.brain.data.rules=msg.match[1]
    msg.reply('roger that')
    return

