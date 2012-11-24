Then /^I should get a download with the filename "([^\"]*)"$/ do |filename|
       page.response_headers['Content-Disposition'].should include("filename=\"#{filename}\"")
    end
