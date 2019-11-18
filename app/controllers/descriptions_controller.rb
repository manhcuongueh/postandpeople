class DescriptionsController < ApplicationController
    def index
        @des = nil
    end

    def count
        text = params[:description].gsub(/#(\w*[A-Za-z_]+\w*)/, "")
        @des = text.delete(" ").delete("\r\n").length
        @des_word = text.scan(/[\w-]+/).length
        render "index"
    end
end
