class PostsController < ApplicationController
    def index 
        @hashtags = Hashtag.all
    end

    def crawl
        selenium_code
        redirect_to "/"
    end

    def hashtag

    end

    def description
        
    end

    def destroy
        hashtag = Hashtag.find(params[:id])
        hashtag.destroy
        redirect_to "/"
    end

    def posts_download
        hashtag = Hashtag.find(params[:id])
        workbook = RubyXL::Workbook.new
        worksheet=workbook[0]

        #save information for all post
        worksheet.add_cell(0, 0, "ID")
        worksheet.add_cell(0, 1, "Image_Link")
        worksheet.add_cell(0, 2, "Description")
        worksheet.add_cell(0, 3, "Likes")
        worksheet.add_cell(0, 4, "Comments")
        worksheet.add_cell(0, 5, "Dates")
        worksheet.add_cell(0, 6, "Hashtags")

        hashtag.posts.each_with_index do |post, index|
            worksheet.add_cell(index+1, 0, post.username)
            worksheet.add_cell(index+1, 1, post.image)
            worksheet.add_cell(index+1, 2, post.description)
            worksheet.add_cell(index+1, 3, post.likes)
            worksheet.add_cell(index+1, 4, post.comments)
            worksheet.add_cell(index+1, 5, post.date)
            worksheet.add_cell(index+1, 6, post.hashtags)
        end
        
        #send
        send_data( workbook.stream.string, :filename => "Posts - #{hashtag.tag} - #{hashtag.date}.xlsx" )    
    end
    
    def people_download
        hashtag = Hashtag.find(params[:id])
        workbook = RubyXL::Workbook.new
        worksheet=workbook[0]
        
        #save information for all post
        worksheet.add_cell(0, 0, "ID")
        worksheet.add_cell(0, 1, "Url")
        worksheet.add_cell(0, 2, "Posts")
        worksheet.add_cell(0, 3, "Followers")
        worksheet.add_cell(0, 4, "Followings")
        worksheet.add_cell(0, 5, "Bio")

        hashtag.persons.each_with_index do |post, index|
            worksheet.add_cell(index+1, 0, post.username)
            worksheet.add_cell(index+1, 1, post.url)
            worksheet.add_cell(index+1, 2, post.posts)
            worksheet.add_cell(index+1, 3, post.followers)
            worksheet.add_cell(index+1, 4, post.followings)
            worksheet.add_cell(index+1, 5, post.bio)
        end
        
        #send
        send_data( workbook.stream.string, :filename => "People - #{hashtag.tag} - #{hashtag.date}.xlsx" )    
    end

    ##Selenium Code
    def selenium_code
        # kill other chrome process
        system("killall chrome")
        @hashtag = Hashtag.new(date: Time.now.to_date, tag: params[:hashtag])
        post_dom=[]
        #run chrome
        # options = Selenium::WebDriver::Chrome::Options.new
        # options.add_argument('--headless')
        # options.add_argument('--no-sandbox')
        # @@bot = Selenium::WebDriver.for :chrome, options: options
        @@bot = Selenium::WebDriver.for :chrome
        @@bot.manage.window.maximize
        @@bot.navigate.to "https://www.instagram.com/accounts/login/?force_classic_login"
        sleep 0.5
        #using username and password to login
        @@bot.find_element(:id, 'id_username').send_keys 'minhho402'
        @@bot.find_element(:id, 'id_password').send_keys '515173'
        @@bot.find_element(:class, 'button-green').click
        # sleep 1
        @@bot.navigate.to "https://www.instagram.com/explore/tags/#{params[:hashtag]}/"
        sleep 2  
        if @@bot.find_elements(:xpath, '/html/body/span/section/main/article/div/div/div/div/div').size >0
            no_of_posts = @@bot.find_element(:xpath, '/html/body/span/section/main/header/div[2]/div[1]/div[2]/span/span').text
            top_dom = @@bot.find_elements(:xpath, '/html/body/span/section/main/article/div/div/div/div/div')
            for i in  top_dom
                if i.find_elements(:tag_name,'a').size > 0
                    dom=[];
                    dom[0]=i.find_element(:tag_name,'a')['href']
                    dom[1]=i.find_element(:tag_name,'img')['src']
                    post_dom.push(dom) 
                end    
            end 
            for i in 0..100
                @@bot.action.send_keys(:end).perform
                sleep 1
                #save dom after 8 times press page down button 
                if i%3==0
                    # elements contain the content of a post
                    dom = @@bot.find_elements(:xpath, '/html/body/span/section/main/article/div[2]/div/div/div')
                    for i in dom 
                        if i.find_elements(:tag_name,'a').size > 0
                            dom=[];
                            dom[0]=i.find_element(:tag_name,'a')['href']
                            dom[1]=i.find_element(:tag_name,'img')['src']
                            post_dom.push(dom) 
                            post_dom = post_dom.uniq
                        end    
                    end 
                end
                break if no_of_posts.remove(",").to_i <= post_dom.size || post_dom.size > 1000
            end

            @@flag = true
            count = 0
            post_dom.each_with_index do |post, index|
                puts index
                puts count
                if count > 5
                    break
                end

                begin
                    @@bot.navigate.to post[0]
                    count += check?(post[0])
                    page_source = @@bot.page_source
                    username = @@bot.find_element(:xpath, '/html/body/span/section/main/div/div/article/header/div[2]/div[1]/div[1]/h2/a').text
                    post_comments =  page_source.split('"edge_media_to_parent_comment":{"count":')[1]
                    post_comments =  post_comments.split(',"page_info":{')[0]
                    post_likes = page_source.split('"edge_media_preview_like":{"count":')[1]
                    post_likes = post_likes.split(',"edges":[{"node":')[0]
                    post_date = @@bot.find_element(:xpath, '/html/body/span/section/main/div/div/article/div[2]/div/a/time')['title']
                    post_detail = @@bot.find_element(:xpath, '/html/body/span/section/main/div/div/article/div[2]/div[1]/ul/div/li/div/div/div[2]/span')
                    post_text = post_detail.text
                    hashtag_elements = post_detail.find_elements(:xpath, "a[contains(@href,'explore/tags')]")
                    hashtags = ''
                    hashtag_elements.each_with_index do |e, index|
                        if index == 0 
                            hashtags.concat("#{e.text}")
                        else
                            hashtags.concat(", #{e.text}")
                        end
                    end
                    @hashtag.posts.new(username: username, image: post[1], description: post_text, likes: post_likes,
                        comments: post_comments, date: post_date, hashtags: hashtags)

                    #people
                    url = @@bot.find_element(:xpath, '/html/body/span/section/main/div/div/article/header/div[2]/div[1]/div[1]/h2/a')['href']
                    doc =  @@bot.navigate.to url
                    count += check?(url)
                    doc = @@bot.page_source
                    people_posts = doc.split('"edge_owner_to_timeline_media":{"count":')[1]
                    people_posts = people_posts.split(',"page_info":')[0]
                    people_followers = doc.split('"edge_followed_by":{"count":')[1]
                    people_followers = people_followers.split('},"followed_by_viewer"')[0]
                    people_followings = doc.split('"edge_follow":{"count":')[1]
                    people_followings = people_followings.split('},"follows_viewer"')[0]
                    people_bio = doc.split('{"user":{"biography":"')[1]
                    people_bio = people_bio.split('","blocked_by_viewer":')[0]
                    people_link_in_bio = doc.split('"external_url":"')[1]
                    people_link_in_bio = people_link_in_bio.split('","external_url_linkshimmed"')[0] if people_link_in_bio.present?
                    @hashtag.persons.new(username: username, url: url, posts: people_posts, followers: people_followers,
                        followings: people_followings, bio: people_bio, link_in_bio: people_link_in_bio)
                rescue => exception
                    puts exception
                end               
            end
            if count > 5 
                flash[:danger] = "Please wait for few hours to refresh Instagram account"
            else
                @hashtag.save!
            end
        else
           flash[:danger] = "Something went wrong, please try again!"
        end
        @@bot.quit()  
    end
        
    def check?(url)
        if @@bot.find_elements(:class, "error-container").size > 0
            if @@flag
                @@bot.quit
                @@bot = Selenium::WebDriver.for :chrome
                @@bot.manage.window.maximize
                @@bot.navigate.to "https://www.instagram.com/accounts/login/?force_classic_login"
                sleep 0.5
                #using username and password to login
                @@bot.find_element(:id, 'id_username').send_keys 'cuongmanh2408'
                @@bot.find_element(:id, 'id_password').send_keys '515173'
                @@bot.find_element(:class, 'button-green').click
                @@bot.navigate.to url
                sleep 1
                @@flag = false
            else
                @@bot.quit
                @@bot = Selenium::WebDriver.for :chrome
                @@bot.manage.window.maximize
                @@bot.navigate.to "https://www.instagram.com/accounts/login/?force_classic_login"
                sleep 0.5
                #using username and password to login
                @@bot.find_element(:id, 'id_username').send_keys 'minhho402'
                @@bot.find_element(:id, 'id_password').send_keys '515173'
                @@bot.find_element(:class, 'button-green').click
                @@bot.navigate.to url
                sleep 1
                @@flag = true
            end 
            return 1
        end
        return 0
    end
end
