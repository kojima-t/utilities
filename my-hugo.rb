#!/usr/bin/env ruby

require 'optparse'
require 'open3'

class MyHugo
  def initialize article
    @BLOG_DIR = ENV['HOME'] + '/blog/articles'
    @POST_DIR = @BLOG_DIR + '/content/post'
    @PUBLIC_DIR = @BLOG_DIR + '/public'
    @THEME = 'angels-ladder'
    @article = article + '.md'
  end

  def deploy
    generate
    Dir.chdir(@PUBLIC_DIR) do
      puts `git add --all`
      date = `date`
      msg = "deploy at " + date
      puts `git commit -m "#{msg}"`
      puts "We will deploy in your GitHub Pages."
      puts `git push origin master`
    end
  end

  def watch_draft
    Dir.chdir(@BLOG_DIR) do
      cmd = "hugo server -w -D -t #{@THEME}"
      stdin, stdout, stderr = Open3.popen3(cmd)
      puts "Access to localhost:1313"
      puts "You should type anything to stop this script."
      q = gets
      exit 0
    end
  end

  def watch_daemon
    Dir.chdir(@BLOG_DIR) do
      cmd = "hugo server -w -D -t #{@THEME}"
      fork do
        puts "Access to localhost:1313"
        puts "This is daemon process. If you want to stop, kill this."
        `#{cmd}`
      end
    end
  end

  def post_add
    Dir.chdir(@BLOG_DIR) do
      if article_exist? @article
        puts "Its article already exist. We will open."
      else
        puts "Its article does not exist. We will add and open."
        `hugo new "post/#{@article}"`
      end
      edit_article(@article)
    end
  end

  def undraft
    Dir.chdir(@BLOG_DIR) do
      if article_exist? @article
        puts "We will undraft this article."
        `hugo undraft "content/post/#{@article}"`
      else
        puts "No such article."
      end
    end
  end

  def list_articles
    Dir.chdir(@POST_DIR) do
      puts Dir.glob('*')
    end
  end

  def search_articles
  end

  private

  def generate
    Dir.chdir(@BLOG_DIR) do
      puts `hugo -t #{@THEME}`
    end
  end

  def article_exist?(file_name)
    Dir.chdir(@POST_DIR) do
      File.exist?(file_name)
    end
  end

  def edit_article(file_name)
    Dir.chdir(@POST_DIR) do
      fork do
        `atom #{file_name}`
      end
    end
  end
end

option = {}
OptionParser.new do |opt|
  opt.on('-d', '--deploy', 'GitHub Pages に deploy') { |v| option[:deploy] = v }
  opt.on('-a', '--add', '記事を content/post ディレクトリに追加、編集用にエディタを開く。') { |v| option[:add] = v }
  opt.on('-u', '--undraft', '指定した記事を下書きから外す。') { |v| option[:undraft] = v}
  opt.on('-w', '--watch', 'プレビューサーバーを起動する。') { |v| option[:watch] = v }
  opt.on('--daemon', 'プレビューサーバーのデーモン化') { |v| option[:daemon] = v }
  opt.on('-l', '--list-files', 'content/post ディレクトリのファイルを表示') { |v| option[:list] = v }
  opt.on('-s', '--search-file=VALUE', '引数にとったファイル名を検索') { |v| option[:search] = v }
  opt.parse!(ARGV)
end

if __FILE__ == $PROGRAM_NAME
  if option.length > 1
    puts "Sorry, we do not inplement multiple option."
    exit 1
  end
  if (option[:add] or option[:undraft]) and (not ARGV[0])
    puts "These option is needed just one argment(add or undraft file name.)"
    exit 1
  end
  arg = if ARGV[0].nil?
          ''
        else
          ARGV[0]
        end
  hugo = MyHugo.new(arg)
  hugo.post_add if option[:add]
  hugo.deploy if option[:deploy]
  hugo.watch_draft if option[:watch]
  hugo.undraft if option[:undraft]
  hugo.watch_daemon if option[:daemon]
  hugo.list_articles if option[:list]
  hugo.search_articles if option[:search]
end
