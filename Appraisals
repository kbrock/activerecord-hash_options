# this should support 4.1 and higher
# git log on this file will show how to generate the gemfiles for this
%w(5.2.3 6.0.0 6.1.0).each do |ar_version|
  appraise "gemfile-#{ar_version.split('.').first(2).join}" do
    gem "activerecord", "~> #{ar_version}"
  end
end
