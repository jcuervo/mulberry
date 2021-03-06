require 'spec_helper'

include CapybaraSpecHelper

describe "Grid View", :type => :request do
  it "should have child node links" do
    DEVICES.each do |d|
      visit "/#{d[:os]}/#{d[:type]}/#/node/node-grid"

      [:grid_child_one, :grid_child_two].each do |child_link|
        page.should have_css "li a[href$=#{child_link}]"
        page.should have_xpath("//div[@class = 'image' and contains(@style, 'background-image')]")
        page.should have_xpath("//div[@class = 'image' and contains(@style, 'cooper_beach.jpg')]")
      end

      click_link "Grid Child One"
      page.should have_css ".body-text"
    end
  end
end
