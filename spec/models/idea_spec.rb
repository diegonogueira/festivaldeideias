require 'spec_helper'

describe Idea do
  describe "Validations/Associations" do

    it { should validate_presence_of :title }
    it { should validate_presence_of :description }
    it { should validate_presence_of :category_id }
    it { should validate_presence_of :user_id }


    describe "#user" do
      it { should belong_to :user }
    end

    describe "#parent" do
      it { should belong_to :parent }
    end

    describe "#category" do
      it { should belong_to :category }
    end

    describe "#colaborations" do
      it { should have_many :colaborations }
    end

    describe "#create_colaboration" do
      it "Should create a child idea in order to colaborate" do
        @idea = Idea.make! 
        @user = User.make!
        idea = {
          :title => "Test",
          :headline => "Test",
          :description => "Test",
          :category_id => @idea.category.id,
          :parent_id => @idea.id,
          :user_id => @user.id

        }
        Idea.create_colaboration(idea).should_not == nil
      end
    end

    describe "#as_json" do
      it "Should return a given json output" do
        @idea = Idea.make!
        idea_json = {
          :id => @idea.id,
          :title => @idea.title,
          :headline => @idea.headline,
          :category => @idea.category,
          :user => @idea.user.id,
          :description => @idea.description,
          :description_html => @idea.description_html,
          :likes => @idea.likes,
          :colaborations => @idea.colaborations.count,
          :minimum_investment => @idea.minimum_investment,
          :formatted_minimum_investment => @idea.formatted_minimum_investment,
          :url => @idea.as_json[:url]
        }
        @idea.as_json.should == idea_json
      end
    end



    describe "#to_param" do
      it "Should concatenate id and title" do
        @idea = Idea.make!
        @idea.to_param.should == "#{@idea.id}-#{@idea.title.parameterize}"
      end
    end


    describe "#description_html" do
      it "Should convert the description to html" do
        string = "<p>This is a description</p>\n"
        @idea = Idea.make!(:description => "This is a description")
        @idea.description_html.should == string
      end
    end

    describe "#convert_html" do
      it "Should convert any text to html format" do
        str = "This is a string with a link: http://google.com"
        str_html = "<p>This is a string with a link: <a href=\"http://google.com\" target=\"_blank\">http://google.com</a></p>\n"

        @idea = Idea.make!
        @idea.convert_html(str).should == str_html
      end
    end

    describe ".new_collaborations" do
      before do
        @idea = Idea.make!(:parent_id => nil, :user => User.make!(:notifications_read_at => Time.now))
       # create(:idea, :parent_id => @idea.id, :created_at => Time.now - 1.day)
        @collaboration =  Idea.make!(:parent_id => @idea.id)
      end
      subject { Idea.new_collaborations(@idea.user) }
      it { should == [@collaboration] }
    end

    describe ".collaborations_status_changed" do
      before do
        @idea = Idea.make!(:parent_id => nil)
        @user = User.make!(:notifications_read_at => Time.now)

        # The user shouldn't see this on notifications
        Idea.make!(:parent_id => @idea.id, :accepted => nil, :user => @user)

        # The user should see this
        @collaboration = Idea.make!(:parent_id => @idea.id, :accepted => true, :user => @user)
      end

      subject { Idea.collaborations_status_changed(@user) }
      it { should == [@collaboration]}
    end
  end


  describe ".collaborated_idea_changed" do
    before do
      @user = User.make!(:notifications_read_at => Time.now)
      @idea = Idea.make!(:parent_id => nil)
      @collaboration = Idea.make!(:parent_id => @idea.id, :user => @user)

      # This collaboration parent was read by the user
      #create(:idea, :parent_id => create(:idea, :updated_at => Time.now - 1.day), :user => @user)
    end
    subject { Idea.collaborated_idea_changed(@user) }
    it { should == [@idea] }
  end
  
  describe "#ramify!" do
    before do
      @idea = Idea.make!(parent_id: nil)
      @colab = Idea.make!(parent_id: @idea.id, accepted: false)
    end
    subject { Idea.ramify!(@colab) } 

    it { should == true }
  end
end
