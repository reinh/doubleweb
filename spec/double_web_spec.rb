require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe DoubleWeb do
  require 'rubygems'
  require 'fakeweb'

  before :all do
    FakeWeb.allow_net_connect = false
    FakeWeb.register_uri(:get, "http://www.google.com/", :body => "Hello from http://google.com/")
  end

  before do
    DoubleWeb.cache_strategy = :memory
    DoubleWeb.clear!
  end

  describe ".init!" do
    before  { @old, $stdout = $stdout, StringIO.new }
    after   { $stdout = @old }
    subject { DoubleWeb }

    describe "with internet=on" do
      before do
        ENV['internet'] = 'on'
        DoubleWeb.init!
      end

      it { should_not be_watch }
      it { should_not be_playback }

      it "should notify that doubleweb is inactive" do
        $stdout.rewind
        $stdout.read.should == "DoubleWeb: inactive\n"
      end
    end

    describe "with internet=off" do
      before do
        ENV['internet'] = 'off'
        DoubleWeb.init!
      end

      it { should_not be_watch }
      it { should be_playback }

      it "should notify that doubleweb is in playback mode" do
        $stdout.rewind
        $stdout.read.should == "DoubleWeb: playback mode\n"
      end
    end


    describe "with internet=watch" do
      before do
        ENV['internet'] = 'watch'
        DoubleWeb.init!
      end

      it { should be_watch }
      it { should_not be_playback }

      it "should notify that doubleweb is in playback mode" do
        $stdout.rewind
        $stdout.read.should == "DoubleWeb: watching\n"
      end
    end

    describe "without internet=" do
      before do
        ENV['internet'] = nil
        DoubleWeb.init!
      end

      it { should_not be_watch }
      it { should_not be_playback }

      it "should notify that doubleweb is in playback mode" do
        $stdout.rewind
        $stdout.read.should == "DoubleWeb: set the `internet` enviroment variable to control DoubleWeb\n" +
                                     "  options are 'on', 'off', 'watch'\n" +
                                     "  DoubleWeb is currently disabled.\n"
      end
    end

  end

  describe ".patch!" do
    before { DoubleWeb.patch! }

    it "should patch Net::HTTP" do
      Net::HTTP.ancestors.should include(DoubleWeb::DriverPatches::NetHTTP)
    end
  end

  describe ".watch!" do
    describe "without a block" do
      subject { lambda { DoubleWeb.watch! } }
      it { should change(DoubleWeb, :watch?).from(false).to(true) }
    end

    describe "with a block" do
      subject { lambda { DoubleWeb.watch!{} } }
      it { should_not change(DoubleWeb, :watch?).to(true) }
    end
  end

  describe ".playback!" do
    describe "without a block" do
      subject { lambda { DoubleWeb.playback! } }
      it { should change(DoubleWeb, :playback?).from(false).to(true) }
    end

    describe "with a block" do
      subject { lambda { DoubleWeb.playback!{} } }
      it { should_not change(DoubleWeb, :playback?).to(true) }
    end
  end

  describe "when watching" do
    before { DoubleWeb.watch! { perform } }

    describe "the cached response" do
      subject { DoubleWeb[request] }

      it { should_not be_nil }
      it { should == response }
    end

  end

  describe "playback" do
    describe "an unwatched request" do
      before { DoubleWeb.clear! }
      subject { lambda { DoubleWeb.playback! { perform } } }

      it { should raise_error(DoubleWeb::UnexpectedRequestError) }
    end

    describe "a watched request" do
      before { DoubleWeb.watch! { perform } }
      subject { lambda { DoubleWeb.playback! { perform } } }

      it { should_not raise_error(DoubleWeb::UnexpectedRequestError) }
      it { subject.call.should == response }
    end

  end

  private
  def requests;  @requests  ||= {} end
  def responses; @responses ||= {} end

  def request(path='/')
    requests[path] ||= Net::HTTP::Get.new(path)
  end

  def response(path='/')
    responses[path] ||= perform(path)
  end

  def perform(path='/')
    responses[path] = Net::HTTP.start('www.google.com') do |http|
      http.request(request(path))
    end
  end
end
