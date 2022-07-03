module Pod
  module UserInterface
    class << self
      # Override UI.warn 解决部分库有重复文件导致输出大量Pod警告的问题
      def warn(message, actions = [], verbose_only = false)
          tips = "[Xcodeproj] Generated duplicate UUIDs"
          if message.start_with? tips
              new_message = "#{tips}\n"
              project_name_regex = /([a-zA-Z\-+]+\.xcodeproj)/
              file_name_regex = /([0-9a-zA-Z\-+]+\.(h|mm|m|swift))/ # 这个正则写的不好, 不应该把后缀匹配进来的, 暂时在后面的步骤去掉
              warnings_array = message
                                    .split("PBXBuildFile -- ")
                                    .map { |item| item.scan(project_name_regex).count > 0 ? item : nil }
                                    .compact
#              File.open("test.txt", "w+") do |file|
#                file.puts warnings_array
#              end
              index = 0
              warnings_array.each do |warning|
                  project_name = warning
                                    .scan(project_name_regex)
                                    .join
                  all_duplicate_file_name = warning
                                                .scan(file_name_regex)
                                                .reduce_extend # 去掉后缀匹配结果
                                                .flatten
                                                .compact
                                                .find_dups # 取出重复的
                                                .join(", ")
                  
                  new_message = new_message + "#{project_name} may contain files with duplicate names that will cause warnings: #{all_duplicate_file_name}"
                  
                  new_message = new_message + "\n" if index < warnings_array.count - 1
                  index += 1
              end
              warnings << { :message => new_message, :actions => actions, :verbose_only => verbose_only }
          else
              warnings << { :message => message, :actions => actions, :verbose_only => verbose_only }
          end
      end
    end
  end
end

class Array
    def find_dups
        uniq.map { |v| (self - [v]).size < (self.size - 1) ? v : nil }.compact
    end
    def reduce_extend
        extend_array = ["h", "m", "mm", "swift"]
        map { |item| item - extend_array }
    end
end
