require 'octokit'
require 'highline'

class Kuroon < Thor

  desc 'clone', 'clone a repo (dunyakirkali/project) from BitBucket or Git to BitBucket or Git'
  method_option :repo, type: :string, required: true
  method_option :from, type: :string, default: :bitbucket
  method_option :to, type: :string, default: :github

  def clone
    @user = /(.*)\//.match(options[:repo]).captures.first
    @project = /\/(.*)/.match(options[:repo]).captures.first
    return unless system("git clone --bare https://#{options[:from]}.org/#{ options[:repo] }.git ../#{@project}")
    return unless Dir.chdir("../#{@project}")
    create_repo
    return unless system("git push --mirror https://#{options[:to]}.com/#{ options[:repo] }.git")
    ensure
      FileUtils.rm_rf("../#{@project}")
  end

  private

  def create_repo
    password = ask("pass? ") { |q| q.echo = false }
    repo_private = ask("private? ") { |q| q.echo = false }
    if options[:to] == :github
      client = Octokit::Client.new(login: @user, password: password)
      client.create_repository("#{ @project }", private: repo_private == 'true' )
    elsif options[:to] == :bitbucket
      # TODO
    end
  end
end
