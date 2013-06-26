class ImportTask
  include Mongoid::Document
  include Mongoid::Timestamps

  field :format
  field :status
  field :file

  mount_uploader :file, FileUploader

  belongs_to :space
  belongs_to :user
  has_many :import_articles, :dependent => :delete

  validates_presence_of :file

  def tmp_path
    "#{Rails.root}/tmp/import_tasks/#{id}"
  end

  def self.perform_task(id)
    self.find(id).import
  end

  def self.delete_task(id)
    self.where(:id => id).first.try(:destroy)
  end

  def import
    options = {
      :tmp_path => tmp_path
    }

    importer = case format
               when 'jekyll'
                 Importer::Jekyll.new(file, options)
               when 'wordpress'
                 Importer::Wordpress.new(file, options)
               end

    importer.import do |import_article|
      import_article.import_task = self
      import_article.save
    end
    update_attribute :status, 'success'

    SystemMailer.delay.import_task_success(id)
    ImportTask.delay_for(1.day).delete_task(id)
  rescue => e
    update_attribute :status, 'error'
    raise e
  end

  def confirm(ids)
    if ids
      import_articles.asc(:created_at).where(:id.in => ids).each(&:import)
    end
  end
end
