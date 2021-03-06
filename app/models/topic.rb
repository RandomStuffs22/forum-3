class Topic < ActiveRecord::Base

  belongs_to :forum, :counter_cache => true
  belongs_to :user
  
  has_many :posts, :order => 'posts.created_at', :dependent => :destroy do
    def last
      @last_post ||= find(:first, :include => :user, :order => 'posts.created_at desc')
    end
  end
  
  validates_presence_of :forum, :user, :title
  before_create { |r| r.replied_at = Time.now.utc }
  attr_accessible :title
  # to help with the create form
  attr_accessor :body

  def voices
    posts.map { |p| p.user_id }.uniq.size
  end
  
  def hit!
    self.class.increment_counter :hits, id
  end

  def sticky?() sticky == 1 end

  def views() hits end

  def paged?() posts_count > 25 end
  
  def last_page
    (posts_count.to_f / 25.0).ceil.to_i
  end

  def editable_by?(user)
    user && (user.id == user_id || user.admin? || user.moderator_of?(forum_id))
  end

end
