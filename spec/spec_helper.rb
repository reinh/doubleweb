$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'doubleweb'
require 'spec'
require 'spec/autorun'

SPECDIR = File.dirname(__FILE__)

Spec::Runner.configure do |config|
  
end
