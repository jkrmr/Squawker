# frozen_string_literal: true

require "rails_helper"

describe "User pages" do
  subject { page }

  describe "signup page" do
    before { visit signup_path }
    it { should have_content "Sign Up" }
    it { should have_title(full_title("Sign Up")) }
  end # signup page

  describe "profile page" do
    let(:user) { create(:user) }

    before { visit user_path(user, via_ui: true) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }

    describe "follow/unfollow buttons" do
      let(:other_user) { create(:user) }
      before { sign_in user, via_ui: true }

      describe "following a user" do
        before { visit user_path(other_user) }

        it "should increment the followed user count" do
          expect do
            click_button "Follow"
          end.to change(user.followed_users, :count).by(1)
        end

        it "should increment the other user's followers count" do
          expect do
            click_button "Follow"
          end.to change(other_user.followers, :count).by(1)
        end

        describe "toggling the button" do
          before { click_button "Follow" }
          it { should have_xpath("//input[@value='Unfollow']") }
        end
      end

      describe "unfollowing a user" do
        before do
          user.follow!(other_user)
          visit user_path(other_user)
        end

        it "should decrement the followed user count" do
          expect do
            click_button "Unfollow"
          end.to change(user.followed_users, :count).by(-1)
        end

        it "should decrement the other user's followers count" do
          expect do
            click_button "Unfollow"
          end.to change(other_user.followers, :count).by(-1)
        end

        describe "toggling the button" do
          before { click_button "Unfollow" }
          it { should have_xpath("//input[@value='Follow']") }
        end
      end
    end
  end # profile page

  describe "signup" do
    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "shoud not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }

        it { should have_title "Sign Up" }
        it { should have_content "error" }
      end
    end # invalid info

    describe "with valid information" do
      before do
        fill_in "Name", with: "Example User"
        fill_in "Username", with: "example_user"
        fill_in "Email", with: "user@example.com"
        fill_in "Password", with: "password"
        fill_in "Confirmation", with: "password"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by(email: "user@example.com") }

        it { should have_link "Sign Out" }
        it { should have_title user.name }
        it { should have_selector "div.alert.alert-success", text: "Welcome" }
      end

      describe "followed by signout" do
        # before { click_link "Sign Out" } # ?
        it { should have_link "Sign In" }
      end
    end # valid info
  end # signup

  describe "edit" do
    let(:user) { create(:user) }
    before do
      sign_in user, via_ui: true
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_content "Update your profile" }
      it { should have_title "Edit user" }
      it { should have_link "change", href: "http://gravatar.com/emails" }
    end

    describe "with valid information" do
      let(:new_name) { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirmation",     with: user.password
        click_button "Save changes"
      end

      it { should have_title new_name }
      it { should have_selector "div.alert.alert-success" }
      it { should have_link "Sign Out", href: signout_path }
      specify { expect(user.reload.name).to eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end # valid information

    describe "with invalid information" do
      before { click_button "Save changes" }
      it { should have_content "error" }
    end
  end # edit

  describe "following/followers indicator" do
    it "displays users the current user follows" do
      user = create(:user)
      other_user = create(:user)
      user.follow!(other_user)
      sign_in(user, via_ui: true)

      visit following_user_path(user)

      expect(page).to have_title(full_title("Following"))
      expect(page).to have_selector("h3", text: "Following")
      expect(page).to have_link(other_user.name, href: user_path(other_user))
    end

    it "displays users that follow the current user" do
      user = create(:user)
      other_user = create(:user)
      user.follow!(other_user)
      sign_in(other_user, via_ui: true)

      visit followers_user_path(other_user)

      expect(page).to have_title(full_title("Followers"))
      expect(page).to have_selector("h3", text: "Followers")
      expect(page).to have_link(user.name, href: user_path(user))
    end
  end
end
