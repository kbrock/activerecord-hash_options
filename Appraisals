# git log on this file will show how to generate the gemfiles for this
%w(6.0.0 6.1.0 7.0 7.1).each do |ar_version|
  appraise "gemfile-#{ar_version.split('.').first(2).join}" do
    gem "activerecord", "~> #{ar_version}"
    remove_gem "byebug"
    if ar_version < "7.0"
      gem "sqlite3", "~> 1.6.9"
    else
      # sqlite3 v 2.0 is causing trouble with rails
      gem "sqlite3", "< 2.0"
    end
  end
end
