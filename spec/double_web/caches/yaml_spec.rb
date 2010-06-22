require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe DoubleWeb::Caches::Yaml do
  TMPFILE = "#{SPECDIR}/tmp/double-web-yaml-store"
  class DoubleWeb::Caches::Yaml::Store; public :load; end

  before do
    DoubleWeb.cache_strategy = :yaml
    DoubleWeb.cache.path = TMPFILE
    DoubleWeb.patch!
  end

  after { DoubleWeb.clear! }
  after(:all) { File.unlink(TMPFILE) if File.exists?(TMPFILE)}

  subject { DoubleWeb.cache }
  let(:request) { Net::HTTP::Get.new('/foo') }
  let(:response) { Net::HTTPSuccess.new(1, 200, "Success") }

  describe "cache" do
    it { should be_a_kind_of DoubleWeb::Caches::Yaml::Store }
  end

  describe "net http patch" do
    subject { Net::HTTP::Get.new('/foo') }
    it { should == Net::HTTP::Get.new('/foo') }
    it { should be_eql Net::HTTP::Get.new('/foo') }
    it("should have the same hash") { subject.hash.should == Net::HTTP::Get.new('/foo').hash }
  end

  describe "#clear" do
    it "should store the empty Hash in the YAML cache" do
      subject.clear
      DoubleWeb::Caches::Yaml.cache.load.should == {}
    end
  end

  describe "[]=" do
    it "stores the key and value to the YAML file" do
      subject[request] = response
      subject[request].should == response
    end
  end

  describe "[]" do
    it "retrieves the value for the key from the YAML file" do
      subject[request] = response
      subject[request].should == response
    end
  end

  describe "when the path is not set" do
    before { DoubleWeb.cache.path = nil }

    it "raises an error that instructs to set the path" do
      lambda { subject[request] }.should raise_error
    end

  end

end
