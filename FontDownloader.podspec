Pod::Spec.new do |s|
  s.name                      = 'FontDownloader'
  s.version                   = '0.1'
  s.source                    = { :git => 'https://github.com/hoppenichu/FontDownloader.git', :tag => s.version }

  s.summary                   = 'UIFont Download Extensions'
  s.homepage                  = 'https://github.com/hoppenichu/FontDownloader'
  s.license                   = { :type => 'MIT', :file => 'LICENSE' }
  s.author                    = { 'Takeru Chuganji' => 'takeru@hoppenichu.com' }

  s.ios.deployment_target     = '8.0'
  s.requires_arc              = true
  s.source_files              = 'FontDownloader/*.swift'
end
