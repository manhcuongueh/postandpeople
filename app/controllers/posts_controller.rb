class PostsController < ApplicationController
    def index    
    end
    
    ##Selenium Code
    def selenium_code
        # kill other chrome process
        system("killall chrome")
        list_running = Status.where('status=?', 'Running')
        for l in list_running
            l.update_attribute(:status,'Waiting')
        end
        while Status.where('status=?', 'Waiting').first.present?
            account = Status.where('status=?', 'Waiting').first
            #set status for an ID
            account.update_attribute(:status,'Running')
            #initialize user
            @user = User.new
            #declare dom of posts
            post_dom=[]
            #declare hashtags of posts
            hashtags=[]
            #declare date 
            date=[]
            #run chrome
            options = Selenium::WebDriver::Chrome::Options.new
            options.add_argument('--headless')
            options.add_argument('--no-sandbox')
            @@bot = Selenium::WebDriver.for :chrome, options: options
            #@@bot = Selenium::WebDriver.for :chrome
            @@bot.manage.window.maximize
            sleep 1
            #go to account page
            @@bot.navigate.to "https://www.instagram.com/#{account.username}"
            sleep 1   
            if @@bot.find_elements(:xpath, '/html/body/span/section/main/div/div/article/div/div/div/div').size >0 
                @@bot.find_element(:xpath, '/html/body/span/section/nav/div[2]/div/div/div[3]/div/div/section/div/button').click
                #get followers 
                followers = @@bot.find_element(:xpath, '/html/body/span/section/main/div/header/section/ul/li[2]/a/span')['title']
                followers = followers.gsub(',','').to_i
                #get account_id
                username = @@bot.find_element(:xpath, '/html/body/span/section/main/div/header/section/div[1]/h1').text
                #scroll down the account page and save dom
                for i in 0..9
                    @@bot.action.send_keys(:end).perform
                    sleep 1
                    #save dom after 8 times press page down button
                    if i%3==0
                        # elements contain the content of a post
                        dom=@@bot.find_elements(:xpath, '/html/body/span/section/main/div/div/article/div/div/div/div')
                        for i in dom
                            if i.find_elements(:tag_name,'a').size>0
                                dom=[];
                                dom[0]=i.find_element(:tag_name,'a')['href']
                                dom[1]=i.find_element(:tag_name,'img')['src']
                                post_dom.push(dom) 
                            end    
                        end      
                    end 
                end
                #avoid duplicate when save dom
                post_dom=post_dom.uniq
                #Get exactly 100 post
                post_dom=post_dom[0..99]
                k=0
                for i in 0..post_dom.length-1  
                    @@bot.navigate.to "#{post_dom[i][0]}"
                    #get all comments
                    total_cm = @@bot.page_source
                    total_cm = total_cm.split('"edge_media_to_comment":{"count":')[1]
                    total_cm = total_cm.split(',"page_info":{"')[0].to_i
                    # get date of first post and date of last post
                    if i==0 ||i==post_dom.length-1 
                        date.push(@@bot.find_element(:xpath, '/html/body/span/section/main/div/div/article/div[2]/div/a/time')['title'])
                    end
                    # pass load more comment 
                    start_time= Time.now
                    while @@bot.find_elements(:xpath, '/html/body/span/section/main/div/div/article/div[2]/div[1]/ul/li[2]/button').size > 0 do
                        while @@bot.find_elements(:xpath, '/html/body/span/section/main/div/div/article/div[2]/div[1]/ul/li[2]/button[@disabled=""]').size > 0 do
                            sleep 1
                            if (Time.now > start_time + 20) 
                                if k == 0
                                    @@bot.quit()
                                    options = Selenium::WebDriver::Chrome::Options.new
                                    options.add_argument('--headless')
                                    options.add_argument('--no-sandbox')
                                    @@bot = Selenium::WebDriver.for :chrome, options: options
                                    #@@bot = Selenium::WebDriver.for :chrome
                                    @@bot.manage.window.maximize
                                    @@bot.navigate.to "https://www.instagram.com/accounts/login/?force_classic_login"
                                    sleep 0.5
                                    #using username and password to login
                                    @@bot.find_element(:id, 'id_username').send_keys 'minhho402'
                                    @@bot.find_element(:id, 'id_password').send_keys '515173'
                                    @@bot.find_element(:class, 'button-green').click
                                    @@bot.navigate.to "#{post_dom[i][0]}" 
                                    sleep 0.5
                                    k=1
                                else    
                                    @@bot.quit()
                                    options = Selenium::WebDriver::Chrome::Options.new
                                    options.add_argument('--headless')
                                    options.add_argument('--no-sandbox')
                                    @@bot = Selenium::WebDriver.for :chrome, options: options
                                    #@@bot = Selenium::WebDriver.for :chrome
                                    @@bot.manage.window.maximize
                                    @@bot.navigate.to "#{post_dom[i][0]}"
                                    sleep 0.5
                                    @@bot.find_element(:xpath, '/html/body/span/section/nav/div[2]/div/div/div[3]/div/div/section/div/button').click
                                    k=0
                                end
                            end
                        end
                            if @@bot.find_elements(:xpath, '/html/body/span/section/div/span').size > 0 
                                @@bot.find_elements(:xpath, '/html/body/span/section/div/span').click
                            end
                            @@bot.find_element(:xpath, '/html/body/span/section/main/div/div/article/div[2]/div[1]/ul/li[2]/button').click
                            start_time= Time.now
                            sleep 0.5
                            #limit at 1000 comments
                            comment_size = @@bot.find_elements(:xpath, '/html/body/span/section/main/div/div/article/div[2]/div[1]/ul/li').size
                            if  comment_size > 999
                                break
                            end
                    end
                    
                    if total_cm > 0      
                        dom_comment = @@bot.find_element(:xpath, '/html/body/span/section/main/div/div/article/div[2]/div[1]/ul')
                        #find hashtags
                        reply_doms = dom_comment.find_elements(:xpath, "li/div/div/div/a[@title='#{username}']")
                        if reply_doms.size > 0 && reply_doms.first.text == username
                            reply_time = reply_doms.size - 1
                        else
                            reply_time = reply_doms.size
                
                        end
                        hashtag_doms = dom_comment.find_elements(:xpath, "li/div/div/div/span/a[contains(@href,'explore/tags')]")
                        for d in hashtag_doms
                            hashtags.push(d.text)
                        end
                        #set percentage    
                        if total_cm > 999
                            percentage = reply_time.to_f/comment_size
                        else
                            percentage = reply_time.to_f/total_cm
                        end
                        
                    else
                        reply_time = 0
                        percentage = 0
                    end 
                    @user.percentages.new(
                        link: post_dom[i][0],
                        image: post_dom[i][1],
                        reply_time: reply_time,
                        total_cm: total_cm,
                        percentage: percentage
                    )                
                end
                #calculate appearance times
                appearance = hashtags.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
                appearance = appearance.sort_by {|_key, value| value}
                appearance = appearance.last(20).reverse
                #Crawl used time by global
                sum = 0; 
                for i in appearance
                    @@bot.navigate.to "https://www.instagram.com/#{username}"
                    #pass send an emoji
                    begin
                    @@bot.find_element(:xpath, '/html/body/span/section/nav/div[2]/div/div/div[2]/input').send_keys i[0]
                    sleep 1.0
                    # wait for result or check no result found 
                    for count in 0..2
                        if @@bot.find_elements(:xpath, '/html/body/span/section/nav/div[2]/div/div/div[2]/div[2]/div[2]/div/a[1]/div/div/div[2]').size==0
                            @@bot.find_element(:xpath, '/html/body/span/section/nav/div[2]/div/div/div[2]/input').clear
                            @@bot.find_element(:xpath, '/html/body/span/section/nav/div[2]/div/div/div[2]/input').send_keys i[0]
                            sleep 1.0
                        else 
                            break
                        end
                    end
                    #hashtags -global use
                    if @@bot.find_elements(:xpath, '/html/body/span/section/nav/div[2]/div/div/div[2]/div[2]/div[2]/div/div').size > 0
                        appearance_time = 0
                    else
                        appearance_time = @@bot.find_element(:xpath, '/html/body/span/section/nav/div[2]/div/div/div[2]/div[2]/div[2]/div/a/div/div/div[2]/span/span').text
                        appearance_time =appearance_time.gsub(',','').to_i

                    end
                    #get availability
                    if appearance_time.to_i > 0.16*followers
                         availability = "X"
                    else
                         availability = "0"
                    end
                        #get sum 
                    if availability =="0" && appearance.index(i) < 5
                        sum = sum + i[1] * appearance_time.to_i
                    end
                    @user.hashtags.new(
                        hashtags: i[0], 
                        use_by_user:i[1],
                        use_by_global: appearance_time,
                        avai: availability
                        )
                    #catach an emoji hashtag
                    rescue 
                        begin
                        url=URI.parse "https://www.instagram.com/explore/tags/#{URI.encode(i[0].remove("#"))}"
                        doc = Nokogiri::HTML(open(url))
                        appearance_time = doc.text
                        appearance_time = appearance_time.split('"edge_hashtag_to_media":{"count":')[1]
                        appearance_time = appearance_time.split(',"page_info":{"')[0]
                        #get availability
                        if appearance_time.to_i > 0.16*followers
                            availability = "X"
                        else
                            availability = "0"
                        end
                        #get sum 
                        if availability =="0" && appearance.index(i) < 5
                            sum = sum + i[1] * appearance_time.to_i
                        end
                        @user.hashtags.new(
                            hashtags: i[0], 
                            use_by_user:i[1],
                            use_by_global: appearance_time,
                            avai: availability
                            )
                        #avoid another http error
                        rescue OpenURI::HTTPError =>e
                            @user.hashtags.new(
                                hashtags: i[0], 
                                use_by_user:i[1],
                                use_by_global: 0,
                                avai: "null"
                                )
                        end
                    end
                end
                @@bot.quit()
                #get score
                score = sum.to_f/followers
                #get level
                case score
                when 0..0.02
                level = "C-"
                when 0.02..0.06
                    level = "C"
                when 0.06..0.1
                    level = "C+"
                when 0.1..0.25
                    level = "B-"
                when 0.25..0.5
                    level = "B"
                when 0.5..1
                    level = "B+"
                when 1..2
                    level = "A-"
                when 2..5
                    level = "A"
                else
                level = "A+"
                end
                #remove data of existing account 
                User.find_each { |c| c.destroy if c.username==username}
                #calculate respond percentage
                total_reply_times=0
                all_cm= 0
                for post in @user.percentages
                    total_reply_times = total_reply_times + post.reply_time
                    all_cm = all_cm + post.total_cm
                end
                # avoiding divide 0
                if all_cm == 0
                    all_cm = 1
                end
                respond_percentage = total_reply_times.to_f/all_cm
                #save user 
                    @user.username = username
                    @user.date_start = date[0]
                    @user.date_end =  date[1]
                    @user.followers= followers
                    @user.sum = sum
                    @user.score = score
                    @user.level = level
                    @user.repond_percentage = respond_percentage
                @user.save
                account.update_attribute(:status,'Done')
            else 
                account.update_attribute(:status,'Invalid ID')
                @@bot.quit()
            end
        end
        redirect_to status_path
    end
end
