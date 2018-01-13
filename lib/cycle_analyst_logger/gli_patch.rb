# Work around a bug with the RdocDocumentListener
# Fix rdoc formatter #201
# https://github.com/davetron5000/gli/pull/201#issuecomment-195385509
require 'gli'
module RdocDocumentListenerAppFix
  def initialize(_global_options,_options,_arguments,app)
    super
    @app = app
  end
end
class GLI::Commands::RdocDocumentListener
  prepend RdocDocumentListenerAppFix
end
