module Representable
  class Binding
    class FragmentNotFound
    end
    
    
    attr_reader :definition # TODO: merge Binding and Definition.
  
    def initialize(definition)
      @definition = definition
    end
    
    # Main entry point for rendering/parsing a property object.
    module Hooks
      def serialize(value)
        value
      end
      
      def deserialize(fragment)
        fragment
      end
    end
    
    include Hooks
    
    
    # Hooks into #serialize and #deserialize to extend typed properties
    # at runtime.
    module Extend
      # Extends the object with its representer before serialization.
      def serialize(object)
        extend_for(super)
      end
      
      def deserialize(*)
        extend_for(super)
      end
      
      def extend_for(object)
        if mod = definition.representer_module
          object.extend(*mod)
        end
        
        object
      end
    end
    
    module Object
      include Binding::Extend  # provides #serialize/#deserialize with extend.
      
      def serialize(object)
        return object if object.nil?
        
        super(object).send(serialize_method, :wrap => false)
      end
      
      def deserialize(data) 
        # DISCUSS: does it make sense to skip deserialization of nil-values here?
        super(create_object).send(deserialize_method, data)
      end
      
      def create_object
        definition.sought_type.new
      end
    end
    
  end
end
