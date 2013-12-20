express = require 'express'
app = express()

# New call to compress content
app.use(express.compress())

app.use(express.static(__dirname + '/build'))

app.listen(process.env.PORT || 3000);