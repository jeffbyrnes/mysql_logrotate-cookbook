# defaults to match previous implementation of mysql logrotation
actions :create
default_action :create

# matches instance name of mysql_service
property :name, String, name_property: true
property :mysql_password, String, required: true
property :connection, Hash, required: true
# logrotate options.  see logrotate_app docs for details
property :rotate, Integer, required: false, default: 7
property :frequency, String, required: false, default: 'daily'
property :dateformat, [String, nil], required: false, default: nil
property :size, [String, nil], required: false, default: nil
property :maxsize, [String, nil], required: false, default: nil
property :logrotate_options, Array, required: false, default: ['missingok', 'compress']
