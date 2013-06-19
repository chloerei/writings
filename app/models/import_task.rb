class ImportTask
  include Mongoid::Document
  include Mongoid::Timestamps

  field :format
  field :status
  field :file

  belongs_to :space
  belongs_to :user
  has_many :articles, :dependent => :delete

  mount_uploader :file, FileUploader

  def tmp_path
    "#{Rails.root}/tmp/import_tasks/#{id}"
  end

  def self.perform_import(id)
    self.find(id).import
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

    importer.import do |article|
      article.space = space
      article.import_task = self
      article.save
    end
    update_attribute :status, 'success'
  rescue
    update_attribute :status, 'error'
  end

  def confirm(ids)
    articles.where(:id.in => ids).unset(:import_task_id)
  end
end
