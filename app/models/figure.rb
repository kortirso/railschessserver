class Figure < ActiveRecord::Base
    self.inheritance_column = nil

    belongs_to :cell

    validates :type, :color, presence: true
    validates :type, inclusion: { in: %w(k q r n b p) }
    validates :color, inclusion: { in: %w(white black) }

    def self.build
        %w(white black).each do |color|
            (1..8).each do |number|
                create type: 'p', color: color
            end
            (1..2).each do |number|
                %w(r n b).each do |type|
                    create type: type, color: color
                end
            end
            %w(k q).each do |type|
                create type: type, color: color
            end
        end
    end
end
