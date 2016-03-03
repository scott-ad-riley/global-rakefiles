namespace( :sin ) do 

  class MakeMyTest

    attr_reader :type, :dir

    def initialize( type, wd, models )
      @type = type
      @wd = wd
      @models = (models) ? models.map{ |f| f.concat(".rb") } : Dir.entries( "#{@wd}/models" ) if Dir.exists? 'models'
    end

    def manipulate()
      for file in @models
        if file.end_with?( @type )
          yield(file, @type, @wd)
        end
      end
    end

    def make_folders
      Dir.mkdir( "#{@wd}/models" ) unless Dir.exists? 'models'
      Dir.mkdir( "#{@wd}/specs" ) unless Dir.exists? 'specs'
      Dir.mkdir( "#{@wd}/public" ) unless Dir.exists? 'public'
      Dir.mkdir( "#{@wd}/views" ) unless Dir.exists? 'views'
    end

    def populate_controller
      yield("controller.rb", @wd)
    end

    def controller_bplate()
      return "require( 'sinatra' )\nrequire( 'sinatra/contrib/all' ) if development?\nrequire( 'json' )\n\n"
    end

    def model_require(model)
      return "require_relative( 'models/#{model}' )\n"
    end

    def class_bplate( model )
      name = model.slice(0,1).capitalize + model.slice(1..-1)
      return "class #{name}\n\n\nend"
    end

    def minitest_bplate( model )
      name = model.slice(0,1).capitalize + model.slice(1..-1)
      return "require( 'minitest/autorun' )\nrequire( 'minitest/rg' )\nrequire_relative( '../models/#{model}' )\n\nclass Test#{name} < MiniTest::Test\n\n\nend"
    end

  end


  task( :setup ) do |t, args|
    test = MakeMyTest.new( '.rb', getwd(), args.extras )
    test.make_folders()

    test.manipulate do |model_file, type, wd|
      model = model_file.split(type).first
      touch( "#{wd}/models/#{model_file}" )
      open( "#{wd}/models/#{model_file}", 'a' ) do |f|
        f << test.class_bplate( model )
      end
    end

    test.manipulate do |file, type, wd|
      touch( "#{wd}/specs/#{file.split( type ).first}_spec.rb")
    end

    test.manipulate do |file, type, wd| 
      model = file.split(type).first
      spec_file = model + "_spec.rb"
      open( "#{wd}/specs/#{spec_file}", 'a' ) do |f|
        f << test.minitest_bplate( model )
      end
    end

    touch( "#{getwd()}/controller.rb" )
    test.populate_controller do |file, wd|
      open( "#{wd}/controller.rb", 'a' ) do |f|
        f << test.controller_bplate()
      end
    end
    test.manipulate do |model_file, type, wd|
      model = model_file.split(type).first
      open( "#{wd}/controller.rb", 'a' ) do |f|
        f << test.model_require( model )        
      end
    end
  end

  task( :run ) do 
    files = Dir.entries( "#{getwd()}/specs" )
    test = MakeMyTest.new( '.rb', getwd(), files )

    test.manipulate do |file, type, wd| 
      sh("ruby #{wd}/specs/#{file}")
    end
  end

  task( :delete_specs ) do
    system "rm -rf specs/"
  end
  
  task( :delete_models ) do
    system "rm -rf models/"
  end

end
