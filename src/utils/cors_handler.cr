require "kemal"

class CORSHandler < Kemal::Handler
  def call(context)
    context.response.headers.add "Access-Control-Allow-Origin", "*"
    call_next context
  end
end
