express = require 'express'
app = express()

app.use express.logger()
app.use express.compress()
app.use express.static(__dirname + '/build')
app.use app.router

app.use (req, res) ->
  # Use res.sendfile, as it streams instead of reading the file into memory.
  res.sendfile __dirname + '/build/index.html'

port = process.env.PORT or 5000
app.listen port, ->
  console.log 'Listening on ' + port
