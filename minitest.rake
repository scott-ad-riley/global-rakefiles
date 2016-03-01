namespace( :mt ) do 

  class MakeMyTest

    attr_reader :type, :dir

    def initialize( type, wd, files )
      @type = type
      @wd = wd
      @files = files
    end

    def manipulate()
      for file in @files
        if file.end_with?( @type )
          yield(file, @type, @wd)
        end
      end  
    end

    def spec_folder
      Dir.mkdir( "#{@wd}/specs" )
    end

    def models(models)
      for model in models
        open("#{@wd}/models/#{model}.rb", "a") do |f|
          f << class_bplate( model )
        end
      end
      @files = Dir.entries( @wd + "/models" ) # once we create the models we need to update our object with that info
    end

    def class_bplate( model )
      name = model.slice(0,1).capitalize + model.slice(1..-1)
      return "class #{name}\n\n\nend"
    end

    def minitest_bplate( model )
      name = model.slice(0,1).capitalize + model.slice(1..-1)
      return "require( 'minitest/autorun' )\nrequire( 'minitest/rg' )\nrequire_relative( '../models/#{model}.rb' )\n\nclass Test#{name} < MiniTest::Test\n\n\nend"
    end

  end

  mkdir("models") unless Dir.exists? "models"
  test = MakeMyTest.new( '.rb', getwd(), Dir.entries( getwd() + "/models") )

  task( :setup ) do |t, args|
    test.models(args.extras)

    test.spec_folder()

    test.manipulate do |file, type, wd|
      touch( "#{wd}/specs/#{file.split( type ).first()}_spec.rb")
    end

    test.manipulate do |file, type, wd| 
      model = file.split(type).first
      spec_file = model + "_spec.rb"
      open( "#{wd}/specs/#{spec_file}", 'a' ) do |f|
        f << test.minitest_bplate( model )
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
