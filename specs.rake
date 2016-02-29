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

    def minitest_bplate( model )
      name = model.slice(0,1).capitalize + model.slice(1..-1)
      return "require( 'minitest/autorun' )\nrequire( 'minitest/rg' )\nrequire_relative( '../#{model}.rb' )\n\nclass Test#{name} < MiniTest::Test\n\n\nend"
    end

  end

  test = MakeMyTest.new( '.rb', getwd(), Dir.entries( getwd() ) )

  task( :setup ) do
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

  task( :delete_tests ) do
    system "rm -rf specs/"
  end

end
