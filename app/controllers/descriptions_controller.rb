class DescriptionsController < ApplicationController
    def index
        @des = nil
    end

    def count
        text = params[:description].gsub(/#(\w*[A-Za-z_\u3131-\uD79D]+\w*)/, "")
        arr = text.gsub("\r\n", " ").split(" ").sort
        @des = arr.each_with_object(Hash.new(0)) { |name, hash| hash[name] += 1 }
        render "index"
    end
end
