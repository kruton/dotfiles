require 'coveralls'

SimpleCov.formatters = [
  Coveralls::SimpleCov::Formatter,
  SimpleCov::Formatter::HTMLFormatter,
]

SimpleCov.add_group 'focus', 'home/.bashrc.d/20-android-focus.bash'
SimpleCov.add_group 'dedupe', 'home/.bashrc.d/98-dedupe-function.bash'
SimpleCov.add_filter '/bats/'
SimpleCov.add_filter '/test/'
SimpleCov.add_filter '/home/bin/'
