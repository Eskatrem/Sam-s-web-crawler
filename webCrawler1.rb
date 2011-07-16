require 'uri'
require 'net/http'
require 'anemone'
require 'open-uri'
require 'fasterCSV'

#tmp = uri.parse('http://www.ensae.fr')

def getlink(x)
  if x.class !="string"
    x=x.to_s
  end
  return x.scan(Regexp.new("http://www.[\-\_a-z0-9./]+"))[0]
end



def getlinks(x,originalwebsite)
  if x.class !="String"
    x=x.to_s
  end
  originalwebsite = originalwebsite.scan(Regexp.new("http://[.a-z0-9]+"))[0]
  http_links= x.scan(Regexp.new("http://www.[\-\_a-z0-9./]+"))
  php_links=x.scan(Regexp.new("[a-z0-9]+.php"))
  php_links=php_links.map do |php| 
    if originalwebsite[originalwebsite.length-1]=="/"
      php=originalwebsite+php
    else
      php=originalwebsite+"/"+php
    end
  end
  puts "http links:\n"
  puts http_links
  puts "\n"
  puts "php links:\n"
  puts php_links
  puts "\n"
  return php_links|http_links
end

def myWebCrawler(keyWord,startWebsite,maxSearch)
  $numIteration=nil
  $alreadyVisited=nil
  $res=nil
  res=myWebCrawler1(keyWord,startWebsite,maxSearch)
  $res=nil
  $numIteration=nil
  $alreadyVisited=nil
  return res
end

def myWebCrawler1(keyWord,startwebsite,maxSearch)
  restrictedDomains=["http://www.w3.org/","http://www.google-analytics.com/"]
  if $numIteration==nil 
    $numIteration=0
  end

  if $alreadyVisited==nil
    $alreadyVisited=[startwebsite]
  else
    $alreadyVisited=$alreadyVisited|[startwebsite]
  end

  if $res==nil
    $res=[]
  end

  puts startwebsite
  puts "maxSearch="+maxSearch.to_s
  puts "numiteration="+$numIteration.to_s
  if $numIteration >= maxSearch 
    return $res 
  end
  begin
    startwebsite_html = Nokogiri::HTML(open(startwebsite))
  rescue
    return nil
  end
if startwebsite_html.inner_text.include? keyWord
    $res=$res|[startwebsite]
  end
  links=getlinks(startwebsite_html,startwebsite)#.xpath("//href")
  puts "number of links="+links.length.to_s
  links.map do |link|
    $numIteration=$numIteration+1
    tmpLink = getlink(link)
  isRestricted=false
  restrictedDomains.map do |domain|
     if tmpLink.to_s.include? domain 
        isRestricted=true
      end
   end
    if tmpLink!=nil and !$alreadyVisited.include? tmpLink and !isRestricted
     
      tmp = myWebCrawler1(keyWord,tmpLink,maxSearch)
      
      $res=$res|tmp unless tmp==nil#unless ($alreadyVisited.include? tmpLink||isRestricted)
    end
  end
  return $res
end
