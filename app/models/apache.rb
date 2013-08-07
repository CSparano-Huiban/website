class Apache
  
  def self.password(uname, password)
    puts `echo htpasswd -b /etc/apache2/dke_users.passwd #{uname} #{password}`
  end
  
  def self.in_group(group_name)
    ENV['REMOTE_USER'] = "wallace4" unless Rails.env.production?
    return Apache.groups(ENV['REMOTE_USER']).include? group_name
  end
  
  def self.groups(uname)
    groups=Array([])
    File.open(group_path).each_line do |line|
      if (line =~/^\w+:\w+/)
        ofset = line.index(':')
        user_list = line[ofset..-1]
        if user_list.index(uname)
          groups << line[0..ofset-1]
        end
      end
    end
    return groups
  end
  
  def self.add(uname, group, year = nil, paswd = nil)
    apache_users = read
    return "#{uname} already exists" if apache_users.to_s.include? uname
    if group == "dkeaffil"
      apache_users["dkeaffil"] << uname
    elsif group =~ /dke(bro|pledge)/ && year
      if apache_users[group][year]
        apache_users[group][year] << uname 
      else
        apache_users[group][year] = [uname]
      end
    end
    password(uname, paswd) if paswd
    return write(apache_users)
  end
  
  def self.rm(uname)
    apache_users = read
    if apache_users.to_s.include? uname
      apache_users.each do | group , subsec |
        if subsec.class == Array
          subsec.delete(uname)
        else
          subsec.each do | year , names |
            names.delete(uname)
          end
        end
      end
      return write(apache_users)
    end
  end
  
 private
 
  def self.group_path
    return '/home/justin/webDKE/dke_users.groups' unless Rails.env.production?
    return '/etc/apache2/dke_users.groups'
  end
  
  def self.read
    groups = {"dkebro" => Hash.new, "dkepledge" => Hash.new, "dkeaffil" => Array.new([])}
    desc = ""
    File.open(group_path).each_line do |line|
      if line =~ /#dke(\d{4}|alum)/
        desc = line.match(/(\d{4}|alum)/).to_s
      elsif line =~ /dkebro/
        groups["dkebro"][desc] = line.sub(/(dkebro:|$|\n)/, "").split
      elsif line =~ /dkepledge/
        groups["dkepledge"][desc] = line.sub(/(dkepledge:|$|\n)/, "").split
      elsif line =~ /[a-z]+:(\S+\s?)+/
        groups[line.match(/\w+/).to_s] = line.sub(/(\w+:|$|\n)/, "").split
      end
    end
    groups["dkebro"].except!("alum")
    groups["broporn"].delete("broporn")
    return groups
  end
  
  def self.write(apache_users)
    apache_string = "#dkealum\r\ndkebro:dkealum\r\n"
    apache_users.each do | group , subsection |
      if subsection.class == Array
        apache_string += "#{group}:#{subsection.join(' ')}\r\n"
      else
        subsection.each do | year , members |
          apache_string += "#dke#{year}\r\n#{group}:#{members.join(' ')}\r\n"
        end
      end      
    end
    File.open(group_path , "w") do |file|
      file.write(apache_string)
    end
    return nil
  end
end
