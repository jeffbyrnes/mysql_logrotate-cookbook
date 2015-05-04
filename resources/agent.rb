# defaults to match previous implementation of mysql logrotation
actions :create
default_action :create

# matches instance name of mysql_service
attribute :name, kind_of: String, name_attribute: true
attribute :mysql_password, kind_of: String, required: true
attribute :connection, kind_of: Hash, required: true
# logrotate options.  see logrotate_app docs for details
attribute :rotate, kind_of: Integer, required: false, default: 7
attribute :frequency, kind_of: String, required: false, default: 'daily'
attribute :dateformat, kind_of: String, required: false, default: nil
attribute :size, kind_of: String, required: false, default: nil
attribute :maxsize, kind_of: String, required: false, default: nil
attribute :logrotate_options, kind_of: Array, required: false, default: ['missingok', 'compress']
