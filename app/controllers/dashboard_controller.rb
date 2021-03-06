# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :verify_developer, except: [:index, :new_dash]

  def index
    @inactive_reasons, @active_reasons = [true, false].map do |inactive|
      Reason.all.joins(:posts)
            .where('reasons.inactive = ?', inactive)
            .group('reasons.id')
            .select('reasons.*, count(\'posts.*\') as post_count')
            .order('post_count DESC')
            .to_a
    end
    @reasons = Reason.all
    @posts = Post.all
  end

  def new_dash; end

  def spam_by_site
    @posts = Post.includes_for_post_row

    @posts = @posts.where(site_id: params[:site]) if params[:site].present?

    @posts = @posts.undeleted if params[:undeleted].present?

    @posts = @posts.order(id: :desc).paginate(per_page: 50, page: params[:page])
    @sites = Site.where(id: @posts.map(&:site_id))
  end

  def db_dumps
    @dumps = Dir.chdir(Rails.root.join('shared', 'dumps')) do
      Dir.glob '*.sql.gz'
    end
  end

  def download_dump
    valid = Dir.chdir(Rails.root.join('shared', 'dumps')) do
      Dir.glob '*.sql.gz'
    end
    @dump = Rails.root.join('shared', 'dumps', params[:filename])

    if !valid.include? params[:filename]
      render status: 401, layout: nil
    else
      send_file @dump, type: 'application/octet-stream'
    end
  end
end
