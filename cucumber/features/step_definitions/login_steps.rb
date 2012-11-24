Given /^a registered user$/ do 
  visit '/login' 
end 

When /^he clicks on login link$/ do 
  visit '/login' 
  fill_in("login", :with => "test") 
  fill_in("password", :with => "test123") 
  click_button "Log in" 
  p current_url 
  p response.body 
end 

Then /^that user should get created$/ do 
  @user = User.find_by_login("test") 
  @user.test.should == "test" 
end 
