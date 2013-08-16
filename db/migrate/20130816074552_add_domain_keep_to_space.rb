class AddDomainKeepToSpace < Mongoid::Migration
  def self.up
    Space.where(:domain => /.+/).update_all :domain_keep => true
  end

  def self.down
  end
end
