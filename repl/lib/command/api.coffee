{ Command } = require "../command"
querystring = require "querystring"

class exports.Api extends Command
  @modelName = "apifactory"

  help: ( cb ) ->
    super ( err, help ) =>
      return cb null, help + """\n
        ## Examples:

        To create an API:

            axle> api "twitter" create endPoint="api.twitter.com"

        To delete an API:

            axle> api "twitter" delete

        ## valid options for creation/updating:

        #{ @app.model( @constructor.modelName ).getValidationDocs() }

        See the API documentation for more: http://apiaxle.com/api.html
        """

  unlinkkey: ( id, commands, keypairs, cb ) ->
    if not key = commands.shift()
      return cb new Error "Please provide a key name to link to #{ id }."

    options =
      path: "/v1/api/#{ id }/unlinkkey/#{ key }"
    @callApi "PUT", options, cb

  linkkey: ( id, commands, keypairs, cb ) ->
    if not key = commands.shift()
      return cb new Error "Please provide a key name to link to #{ id }."

    options =
      path: "/v1/api/#{ id }/linkkey/#{ key }"
    @callApi "PUT", options, cb

  delete: ( id, commands, keypairs, cb ) ->
    options =
      path: "/v1/api/#{ id }"
    @callApi "DELETE", options, cb

  update: ( id, commands, keypairs, cb ) ->
    options =
      path: "/v1/api/#{ id }"
      data: JSON.stringify( keypairs )
    @callApi "PUT", options, cb

  keys: ( id, commands, keypairs, cb ) ->
    { from, to, resolve } = keypairs
    from = ( encodeURIComponent( parseInt( from ) or 0 ) )
    to = ( encodeURIComponent( parseInt( to ) or 100 ) )
    resolve = if resolve is "true" then "true" else "false"

    options =
      path: "/v1/api/#{ id }/keys?resolve=#{ resolve }&to=#{ to }&from=#{ from }"

    @callApi "GET", options, cb

  create: ( id, commands, keypairs, cb ) ->
    options =
      path: "/v1/api/#{ id }"
      data: JSON.stringify( keypairs )
    @callApi "POST", options, cb

  show: ( id, commands, keypairs, cb ) ->
    @callApi "GET", path: "/v1/api/#{ id }", cb

  stats: ( id, commands, keypairs, cb ) ->
    qs = querystring.stringify keypairs
    @callApi "GET", path: "/v1/api/#{ id }/stats?#{ qs }", cb
