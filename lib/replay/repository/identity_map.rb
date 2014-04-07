module Replay
  module Repository
    module IdentityMap
      def self.included(base)
        base.extend(ClassMethods)
      end
      module ClassMethods
        def load(klass, stream_id, options={})
          #implement an identity map
          @_identities ||= {}
          return @_identities[[klass,stream_id]] if @_identities[[klass, stream_id]]

          obj=repository_load(klass, stream_id, options)
          @_identities[[klass, stream_id]] = obj

          obj
        end

        def clear_identity_map
          @_identities = {}
        end
      end
    end
  end
end
