class User::TeamsController < ApplicationController
  before_filter :login_required
  def index
    @teams=Team.find :all,:conditions=>['creator_id =?',current_user.id]
  end
  def new
    @users =User.find :all
    @team = Team.new
  end
  def create
    @team = Team.create params[:team]
    @team.update_attributes :creator_id=>current_user.id
    user_ids = params[:user_ids]||[]
    user_ids.each do|user_id|
      TeamUser.create(:team_id=>@team.id,
        :user_id=>user_id,
        :status=>3,
        :creator_id=>current_user.id,
        :affirmant_id=>user_id)
    end
  end

  def edit
    @team = Team.find params[:id]
    @team_users=TeamUser.find :all,:conditions=>['team_id = ?',@team.id]
  end
  def update
    @team = Team.find params[:id]
    user_ids = params[:user_ids]||[]
    user_ids.each do|user_id|
      TeamUser.create(:team_id=>@team.id,
        :user_id=>user_id,
        :status=>3,
        :creator_id=>current_user.id,
        :affirmant_id=>user_id)
    end
  end
  def destroy

  end
end
