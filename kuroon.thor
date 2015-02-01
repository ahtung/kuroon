require 'octokit'
require 'highline'

class Kuroon < Thor
  desc 'clone', 'clone a repo from BitBucket to Git'
  def clone(repo)
    project = /\/(.*)/.match(repo).captures.first

    p project
    return unless system("git clone --bare https://bitbucket.org/#{ repo }.git ../#{project}")
    return unless Dir.chdir("../#{project}")

    password = ask("pass? ") { |q| q.echo = false }
    private = ask("private? ") { |q| q.echo = false }
    client = Octokit::Client.new(login: 'dunyakirkali', password: password)
    p client.create_repository("#{ project }", private: private == 'true' )

    return unless system("git push --mirror https://github.com/dunyakirkali/#{ project }.git")
    return unless FileUtils.rm_rf('../#{project}') 
  end
end
