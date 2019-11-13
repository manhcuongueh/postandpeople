class HashtagsController < ApplicationController
    def index
        @hash = nil
    end

    def count
        text = params[:hashtag].delete(" ").delete(",")
        arr = text.split("#").drop(1).sort
        @hash = arr.each_with_object(Hash.new(0)) { |name, hash| hash[name] += 1 }
        render "index"
    end
end
