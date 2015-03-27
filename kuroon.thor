require 'octokit'
require 'highline'

class Kuroon < Thor
  desc 'clone', 'clone a repo (dunyakirkali/project) from BitBucket or Git to BitBucket or Git'
  method_option :repo, type: :string, required: true
  method_option :options, type: :hash, default: { from: :bitbucket, to: :github }
  def clone(repo)
    return unless system("git clone --bare https://#{options[:from]}.org/#{ repo }.git ../#{project}")
    return unless Dir.chdir("../#{project}")

    password = ask("pass? ") { |q| q.echo = false }
    private = ask("private? ") { |q| q.echo = false }
    client = Octokit::Client.new(login: 'dunyakirkali', password: password)
    p client.create_repository("#{ project }", private: private == 'true' )

    return unless system("git push --mirror https://github.com/dunyakirkali/#{ project }.git")
    return unless FileUtils.rm_rf('../#{project}')
  end
end
