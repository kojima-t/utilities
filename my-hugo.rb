#!/usr/bin/env ruby

require 'optparse'

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
      puts `hugo server -w -D -t "#{@THEME}"`
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
    if article_exist? @article
      puts "We will undraft this article."
      `hugo undraft "post/#{@article}"`
    else
      puts "No such article."
    end
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
      `atom #{file_name}`
    end
  end
end

option = {}
OptionParser.new do |opt|
  opt.on('-d', '--deploy') { |v| option[:deploy] = v }
  opt.on('-a', '--add') { |v| option[:add] = v }
  opt.on('-u', '--undraft') { |v| option[:undraft] = v}
  opt.on('-w', '--watch-undraft') { |v| option[:watch] = v }
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
  puts arg
  hugo = MyHugo.new(arg)
  hugo.post_add if option[:add]
  hugo.deploy if option[:deploy]
  hugo.watch_draft if option[:watch]
  hugo.undraft if option[:undraft]
end
