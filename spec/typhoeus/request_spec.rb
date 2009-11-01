require File.dirname(__FILE__) + '/../spec_helper'

describe "request" do
  describe "quick request methods" do
    it "can run a GET synchronously" do
      response = Typhoeus::Request.get("http://localhost:3000", :params => {:q => "hi"}, :headers => {:foo => "bar"})
      response.code.should == 200
      JSON.parse(response.body)["REQUEST_METHOD"].should == "GET"
    end
    
    it "can run a POST synchronously" do
      response = Typhoeus::Request.post("http://localhost:3000", :params => {:q => "hi"}, :headers => {:foo => "bar"})
      response.code.should == 200
      JSON.parse(response.body)["REQUEST_METHOD"].should == "POST"
    end
    
    it "can run a PUT synchronously" do
      response = Typhoeus::Request.put("http://localhost:3000", :params => {:q => "hi"}, :headers => {:foo => "bar"})
      response.code.should == 200
      JSON.parse(response.body)["REQUEST_METHOD"].should == "PUT"
    end
    
    it "can run a DELETE synchronously" do
      response = Typhoeus::Request.delete("http://localhost:3000", :params => {:q => "hi"}, :headers => {:foo => "bar"})
      response.code.should == 200
      JSON.parse(response.body)["REQUEST_METHOD"].should == "DELETE"      
    end
  end

  it "takes url as the first argument" do
    Typhoeus::Request.new("http://localhost:3000").url.should == "http://localhost:3000"
  end
  
  it "should parse the host from the url" do
    Typhoeus::Request.new("http://localhost:3000/whatever?hi=foo").host.should == "http://localhost:3000"
    Typhoeus::Request.new("http://localhost:3000?hi=foo").host.should == "http://localhost:3000"
    Typhoeus::Request.new("http://localhost:3000").host.should == "http://localhost:3000"
  end
  
  it "takes method as an option" do
    Typhoeus::Request.new("http://localhost:3000", :method => :get).method.should == :get
  end
  
  it "takes headers as an option" do
    headers = {:foo => :bar}
    request = Typhoeus::Request.new("http://localhost:3000", :headers => headers)
    request.headers.should == headers
  end
  
  it "takes params as an option and adds them to the url" do
    Typhoeus::Request.new("http://localhost:3000", :params => {:foo => "bar"}).url.should == "http://localhost:3000?foo=bar"
  end
  
  it "should post large data and not have huge URL" do
    
    long_str = "In dividing Xenopus eggs, furrowing is accompanied by expansion of a new domain of plasma membrane in the cleavage plane. The source of the new membrane is known to include a store of oogenetically produced exocytotic vesicles, but the site where their exocytosis occurs has not been described. Previous work revealed a V-shaped array of microtubule bundles at the base of advancing furrows. Cold shock or exposure to nocodazole halted expansion of the new membrane domain, which suggests that these microtubules are involved in the localized exocytosis. In the present report, scanning electron microscopy revealed collections of pits or craters, up to approximately 1.5 micro m in diameter. These pits are evidently fusion pores at sites of recent exocytosis, clustered in the immediate vicinity of the deepening furrow base and therefore near the furrow microtubules. Confocal microscopy near the furrow base of live embryos labeled with the membrane dye FM1-43 captured time-lapse sequences of individual exocytotic events in which irregular patches of approximately 20 micro m(2) of unlabeled membrane abruptly displaced pre-existing FM1-43-labeled surface. In some cases, stable fusion pores, approximately 2 micro m in diameter, were seen at the surface for up to several minutes before suddenly delivering patches of unlabeled membrane. To test whether the presence of furrow microtubule bundles near the surface plays a role in directing or concentrating this localized exocytosis, membrane expansion was examined in embryos exposed to D(2)O to induce formation of microtubule monasters randomly under the surface. D(2)O treatment resulted in a rapid, uniform expansion of the egg surface via random, ectopic exocytosis of vesicles. This D(2)O-induced membrane expansion was completely blocked with nocodazole, indicating that the ectopic exocytosis was microtubule-dependent. Results indicate that exocytotic vesicles are present throughout the egg subcortex, and that the presence of microtubules near the surface is sufficient to mobilize them for exocytosis at the end of the cell cycle."
    
    response = Typhoeus::Request.post("http://translate.google.com/translate_t", :params => {'sl'=>'en','tl'=>'es','text'=>long_str})
    response.code.should == 200
    
  end
  
  it "takes request body as an option" do
    Typhoeus::Request.new("http://localhost:3000", :body => "whatever").body.should == "whatever"
  end
  
  it "takes timeout as an option" do
    Typhoeus::Request.new("http://localhost:3000", :timeout => 10).timeout.should == 10
  end
  
  it "takes cache_timeout as an option" do
    Typhoeus::Request.new("http://localhost:3000", :cache_timeout => 60).cache_timeout.should == 60
  end
  
  it "has the associated response object" do
    request = Typhoeus::Request.new("http://localhost:3000")
    request.response = :foo
    request.response.should == :foo    
  end

  it "has an on_complete handler that is called when the request is completed" do
    request = Typhoeus::Request.new("http://localhost:3000")
    foo = nil
    request.on_complete do |response|
      foo = response
    end
    request.response = :bar
    request.call_handlers
    foo.should == :bar
  end
  
  it "has an on_complete setter" do
    foo = nil
    proc = Proc.new {|response| foo = response}
    request = Typhoeus::Request.new("http://localhost:3000")
    request.on_complete = proc
    request.response = :bar
    request.call_handlers
    foo.should == :bar
  end
  
  it "stores the handled response that is the return value from the on_complete block" do
    request = Typhoeus::Request.new("http://localhost:3000")
    request.on_complete do |response|
      "handled"
    end
    request.response = :bar
    request.call_handlers
    request.handled_response.should == "handled"
  end
  
  it "has an after_complete handler that recieves what on_complete returns" do
    request = Typhoeus::Request.new("http://localhost:3000")
    request.on_complete do |response|
      "handled"
    end
    good = nil
    request.after_complete do |object|
      good = object == "handled"
    end
    request.call_handlers
    good.should be_true
  end
  
  it "has an after_complete setter" do
    request = Typhoeus::Request.new("http://localhost:3000")
    request.on_complete do |response|
      "handled"
    end
    good = nil
    proc = Proc.new {|object| good = object == "handled"}
    request.after_complete = proc
    
    request.call_handlers
    good.should be_true
  end
  
  describe "retry" do
    it "should take a retry option"
    it "should count the number of times a request has failed"
  end
  
end