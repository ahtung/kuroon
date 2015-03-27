require 'octokit'

class Kuroon < Thor

  desc 'clone', 'clone a repo (dunyakirkali/project) from BitBucket or Git to BitBucket or Git'
  method_option :repo, type: :string, required: true
  method_option :from, type: :string, default: :bitbucket
  method_option :to, type: :string, default: :github
  method_option :private, type: :boolean, default: false

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
    password = ask("pass? ", echo: false)
    if options[:to] == :github
      client = Octokit::Client.new(login: @user, password: password)
      client.create_repository("#{ @project }", private: options[:private])
    elsif options[:to] == :bitbucket
      # TODO
    end
  end
end
