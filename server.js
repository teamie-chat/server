var chat            = require("./.app/drupal-chat.js");
var config          = {
  port: 1234,
  redis: {},
  drupal: {}
};
var app             = chat(config);
console.dir(app);

app.start();

