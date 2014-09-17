chat = require("./.app/drupal-chat.js")

config =
  port: 1234
  redis:
    port      : 2345
    address   : 'localhost'
    username  : 'redis'
    password  : 'pwd'
    database  : 0
  drupal:
    port      : 3456
    address   : 'localhost'

app = chat(config)
app.start()
