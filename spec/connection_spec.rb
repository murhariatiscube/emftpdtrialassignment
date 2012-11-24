





describe "VCR and Webmock working together" do

  let(:url) { URI.parse 'https://s3.amazonaws.com' }

  it "fails for net request" do
    expect { Net::HTTP.get(url) }.to raise_error
  end

  it "succeeds if the request is manually stubbed" do
    stub_request(:get, url.to_s).to_return(status: 200, body: 'hello')
	
	stub_request(:get, "https://s3.amazonaws.com").to_return(:status => 200, :body => "", :headers => {})
	
    Net::HTTP.get(url).should eql('hello')
  end

end
