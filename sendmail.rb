require "net/smtp"  
   
 # params :   
 #   ARGV[0] = subject  
 #   ARGV[1] = content  
 #   ARGV[2] = filename  
 #   ARGV[3] = to  
   
 def sendemail(subject,content,to=nil)  
     from = "saq@xj.cninfo.net"  
     to = ["saq@xj.cninfo.net"] if to.nil?  
     sendmessage = "Subject: "+subject +"\n\n"+content  
     smtp = Net::SMTP.start("mail.xj.cninfo.net",25,"mail.xj.cninfo.net",'saq','wei720503',:login)  
     smtp.send_message sendmessage,from,to  
     smtp.finish  
 end  
 def sendemail_file(subject,filename,to)  
     content = ""  
     File.open(filename) do |file|  
       file.each_line {|line| content += "#{line}\n" }  
     end  
     sendemail(subject,content,to)  
 end  
   
   
 subject = ARGV[0] || "system autoly send"  
 content = ARGV[1] || ""  
 filename = ARGV[2] || ""  
 to = ARGV[3]   
   
 if content.to_s == "" and filename.to_s!=""  
     sendemail_file(subject,filename,to)  
 else  
   content = "Nothing" if content.to_s == ""  
   sendemail(subject,content,to)  
 end