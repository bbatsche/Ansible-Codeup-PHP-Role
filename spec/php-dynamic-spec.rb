require_relative "lib/ansible_helper"
require_relative "bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.instance.playbook("playbooks/php-playbook.yml", {
      copy_index_php: true,
      copy_favicon: true,
      dynamic_php: true
    })
  end
end

describe command("curl php-test.dev/some-url") do
  it "redirects to index.php" do
    expect(subject.stdout).to match /<title>phpinfo\(\)<\/title>/ # title tag is generated by phpinfo()
  end
end

describe "Nginx config is valid" do
  include_examples "nginx::config"
end
