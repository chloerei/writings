class ExportTask
  include Mongoid::Document
  include Mongoid::Timestamps

  field :format
  field :status

  belongs_to :space
  belongs_to :user

  scope :success, -> { where(:status => 'success') }

  after_destroy do
    FileUtils.rm_r output_path, :force => true
  end

  def self.perform_task(id)
    self.find(id).export
  end

  def self.delete_task(id)
    self.where(:id => id).first.try(:destroy)
  end

  def tmp_path
    "#{Rails.root}/tmp/export_tasks/#{id}"
  end

  def output_path
    "#{Rails.root}/data/export_tasks/#{id}"
  end

  def success?
    status == 'success'
  end

  def error?
    status == 'error'
  end

  def export
    options = {
      :tmp_path    => tmp_path,
      :output_path => output_path
    }

    case format
    when 'jekyll'
      Exporter::Jekyll.new(space, options).export
    when 'wordpress'
      Exporter::Wordpress.new(space, options).export
    end

    update_attribute :status, 'success'

    SystemMailer.delay.export_task_success(id)
    ExportTask.delay_for(1.day).delete_task(id)
  rescue => e
    update_attribute :status, 'error'
    raise e
  end

  def path
    case format
    when 'jekyll'
      "#{output_path}/jekyll.zip"
    when 'wordpress'
      "#{output_path}/wordpress.xml"
    end
  end

  def filename
    time = (created_at || Time.now.utc).to_date
    case format
    when 'jekyll'
      "#{space.name}.jekyll.#{time}.zip"
    when 'wordpress'
      "#{space.name}.wordpress.#{time}.xml"
    end
  end
end
