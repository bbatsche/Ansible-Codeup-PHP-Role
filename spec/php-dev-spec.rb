require_relative "lib/ansible_helper"
require_relative "bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.instance.playbook "playbooks/php-playbook.yml", copy_index_php: true, enable_suhosin: true
  end
end

describe command("php --version") do
  it "has no errors" do
    expect(subject.stderr).to eq ''
    expect(subject.exit_status).to eq 0
  end

  it "is the correct version" do
    expect(subject.stdout).to match /^PHP 5\.\d\.\d+/
  end

  it "has OPcache enabled" do
    expect(subject.stdout).to match /^\s+with Zend OPcache v\d+\.\d+\.\d+/
  end
end

describe command(%Q{php -r 'echo "PHP is running\\n";'}) do
  it "executes PHP code" do
    expect(subject.stdout).to match /^PHP is running$/
  end
end

describe command("php -i") do
  it "has XDebug installed" do
    expect(subject.stdout).to match /^xdebug support => enabled/
  end

  it "has YAML installed" do
    expect(subject.stdout).to match /^LibYAML Support => enabled/
  end

  it "has the default timezone set" do
    expect(subject.stdout).to match /^Default timezone => Etc\/UTC/
  end

  it "has Suhosin enabled" do
    expect(subject.stdout).to match /This server is protected with the Suhosin Extension/
  end

  it "has the max upload size set" do
    expect(subject.stdout).to match /upload_max_filesize => 10M/
  end

  it "has the Laravel environment set" do
    expect(subject.stdout).to match /_SERVER\["LARAVEL_ENV"\] => local/
  end

  context "suhosin" do
    it "will log all minus SQL" do
      expect(subject.stdout).to match /suhosin\.log\.file => 479/
    end
    it "will whitelist phar files" do
      expect(subject.stdout).to match /suhosin\.executor\.include\.whitelist => phar/
    end
    it "will encrypt cookies" do
      expect(subject.stdout).to match /suhosin\.cookie\.encrypt => On/
    end
    it "will encrypt sessions" do
      expect(subject.stdout).to match /suhosin.session.encrypt => On/
    end
  end
end

describe command("composer") do
  it "does not have XDebug enabled" do
    expect(subject.stderr).to_not match /You are running composer with xdebug enabled/
  end
end

describe command("phpunit --version") do
  it "is installed" do
    expect(subject.stdout).to match /^PHPUnit 4\.8\.\d+/
  end
end

describe command("phpunit /srv/http/php-test.dev/public/index.php") do
  it "has XDebug enabled" do
    expect(subject.stdout).to match /^xdebug support => enabled/
  end
end

describe command("psysh --version") do
  it "is installed" do
    expect(subject.stdout).to match /Psy Shell v0\.7\.\d+/
  end
end

describe command("curl -i php-test.dev") do
  it "sends a 200 OK response" do
    expect(subject.stdout).to match /^HTTP\/1\.1 200 OK$/
  end

  it "executes PHP code" do
    expect(subject.stdout).to match /<title>phpinfo\(\)<\/title>/ # title tag is generated by phpinfo()
  end

  it "has XDebug enabled" do
    expect(subject.stdout).to match /<th>xdebug support<\/th><th>enabled<\/th>/
  end

  it "has Laravel environment set" do
    expect(subject.stdout).to match /_SERVER\["LARAVEL_ENV"\]<\/td><td.+>local/
  end

  it "has Suhosin enabled" do
    expect(subject.stdout).to match /This server is protected with the Suhosin Extension/
  end

  context "suhosin" do
    it "will disable eval" do
      expect(subject.stdout).to match /suhosin\.executor\.disable_eval<\/td><td.+>On/
    end
  end
end

describe command("curl php-test.dev/disabled_functions_test.php") do
  it "has shell_exec disabled" do
    expect(subject.stdout).to match /Warning: shell_exec\(\) has been disabled for security reasons/
  end
end

describe command("curl php-test.dev/open_basedir_test.php") do
  it "has open_basedir enabled" do
    expect(subject.stdout).to match /open_basedir restriction in effect\. File\(.+\) is not within the allowed path\(s\)/
  end
end

describe command("curl php-test.dev/session_test.php") do
  it "can start a session" do
    expect(subject.stdout).to match /^2$/ # 2 == PHP_SESSION_ACTIVE
  end
end

describe command("curl -I php-test.dev/some-url") do
  it 'does not redirect to index.php' do
    expect(subject.stdout).to match /^HTTP\/1\.1 404 Not Found$/
  end
end

describe "Nginx config is valid" do
  include_examples "nginx::config"
end
